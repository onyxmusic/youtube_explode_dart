import 'dart:collection';

import 'package:logging/logging.dart';

import '../../exceptions/exceptions.dart';
import '../../extensions/helpers_extension.dart';
import '../../retry.dart';
import '../../reverse_engineering/challenges/js_challenge.dart';
import '../../reverse_engineering/heuristics.dart';
import '../../reverse_engineering/models/stream_info_provider.dart';
import '../../reverse_engineering/pages/watch_page.dart';
import '../../reverse_engineering/youtube_http_client.dart';
import '../video_id.dart';
import '../youtube_api_client.dart';
import 'stream_controller.dart';
import 'streams.dart';

/// Queries related to media streams of YouTube videos.
class StreamClient {
  static final _logger = Logger('YoutubeExplode.StreamsClient');
  final YoutubeHttpClient _httpClient;
  final StreamController _controller;
  final BaseJSChallengeSolver? _jsChallengeSolver;

  /// Initializes an instance of [StreamClient]
  StreamClient(this._httpClient, {BaseJSChallengeSolver? jsSolver})
      : _controller = StreamController(_httpClient),
        _jsChallengeSolver = jsSolver;

  /// Gets the manifest that contains information
  /// about available streams in the specified video.
  Future<StreamManifest> getManifest(dynamic videoId,
      {@Deprecated('Use the ytClient parameter instead')
      bool fullManifest = false,
      List<YoutubeApiClient>? ytClients,
      bool requireWatchPage = true}) async {
    assert(ytClients == null || ytClients.isNotEmpty,
        'ytClients cannot be an empty list');

    videoId = VideoId.fromString(videoId);

    // 🚀 Varsayılan olarak canlı akışta 403 yemeyen visionOS kullanılır
    final clients = ytClients ?? [YoutubeApiClient.visionos];

    if (_jsChallengeSolver != null && ytClients == null) {
      clients.add(YoutubeApiClient.safari);
    }

    final uniqueStreams = LinkedHashSet<StreamInfo>(
      equals: (a, b) {
        if (a.runtimeType != b.runtimeType) return false;
        if (a is AudioStreamInfo && b is AudioStreamInfo) {
          return a.tag == b.tag && a.audioTrack == b.audioTrack;
        }
        return a.tag == b.tag;
      },
      hashCode: (e) {
        if (e is AudioStreamInfo) {
          return e.tag.hashCode ^ e.audioTrack.hashCode;
        }
        return e.tag.hashCode;
      },
    );

    Object? lastException;

    for (final client in clients) {
      _logger.fine(
          'Getting stream manifest for video $videoId with client: ${client.payload['context']['client']['clientName']}');
      try {
        await retry(_httpClient, () async {
          final streams = (await _getStreams(
            videoId,
            ytClient: client,
            requireWatchPage: requireWatchPage,
          ).toList())
              .where(_hasPlayableUrl)
              .toList();

          if (streams.isEmpty) {
            throw VideoUnavailableException(
              'Video "$videoId" does not contain any playable streams.',
            );
          }

          // 🚀 KRİTİK DÜZELTME: Yanlış 403 hatası verdiren HEAD istekleri kaldırıldı
          uniqueStreams.addAll(streams);
        });
      } catch (e, s) {
        _logger.severe(
            'Failed to get stream manifest for video $videoId with client: ${client.payload['context']['client']['clientName']}. Reason: $e\n',
            e,
            s);
        lastException = e;
      }
    }

    // Eğer visionOS akış veremezse yedek olarak androidSdkless ile dene
    if (uniqueStreams.isEmpty && ytClients == null) {
      return getManifest(videoId, ytClients: [YoutubeApiClient.androidSdkless]);
    }

    if (uniqueStreams.isEmpty) {
      if (lastException is Error && lastException.stackTrace != null) {
        throw Error.throwWithStackTrace(
            lastException, lastException.stackTrace!);
      }
      throw lastException ??
          VideoUnavailableException(
              'Video "$videoId" has no available streams');
    }
    return StreamManifest(uniqueStreams.toList());
  }

  /// Gets the HTTP Live Stream (HLS) manifest URL for live videos.
  Future<String> getHttpLiveStreamUrl(VideoId videoId) async {
    final watchPage = await WatchPage.get(_httpClient, videoId.value);
    final playerResponse = watchPage.playerResponse;

    if (playerResponse == null) {
      throw TransientFailureException(
        "Couldn't extract the playerResponse from the Watch Page!",
      );
    }

    if (!playerResponse.isVideoPlayable) {
      throw VideoUnplayableException.unplayable(
        videoId,
        reason: playerResponse.videoPlayabilityError ?? '',
      );
    }

    final hlsManifest = playerResponse.hlsManifestUrl;
    if (hlsManifest == null) {
      throw VideoUnplayableException.notLiveStream(videoId);
    }
    return hlsManifest;
  }

  /// Gets the actual stream bytes.
  Stream<List<int>> get(StreamInfo streamInfo) =>
      _httpClient.getStream(streamInfo, streamClient: this);

  Stream<StreamInfo> _getStreams(VideoId videoId,
      {required YoutubeApiClient ytClient,
      bool requireWatchPage = true}) async* {
    await for (final stream
        in _getStream(videoId, ytClient, requireWatchPage: requireWatchPage)) {
      yield stream;
    }
  }

  Stream<StreamInfo> _getStream(VideoId videoId, YoutubeApiClient ytClient,
      {bool requireWatchPage = true}) async* {
    WatchPage? watchPage;
    if (requireWatchPage) {
      try {
        watchPage = await WatchPage.get(_httpClient, videoId.value);
      } catch (_) {}
    }
    final playerResponse = await _controller
        .getPlayerResponse(videoId, ytClient, watchPage: watchPage);

    if (!playerResponse.previewVideoId.isNullOrWhiteSpace) {
      throw VideoRequiresPurchaseException.preview(
        videoId,
        VideoId(playerResponse.previewVideoId!),
      );
    }

    if (playerResponse.videoPlayabilityError?.contains('payment') ?? false) {
      throw VideoRequiresPurchaseException(videoId);
    }

    if (!playerResponse.isVideoPlayable) {
      throw VideoUnplayableException.unplayable(
        videoId,
        reason: playerResponse.videoPlayabilityError ?? '',
      );
    }
    yield* _parseStreamInfo(playerResponse.streams,
        watchPage: watchPage, videoId: videoId);

    if (!playerResponse.dashManifestUrl.isNullOrWhiteSpace) {
      final dashManifest =
          await _controller.getDashManifest(playerResponse.dashManifestUrl!);
      yield* _parseStreamInfo(dashManifest.streams,
          watchPage: watchPage, videoId: videoId);
    }
    if (!playerResponse.hlsManifestUrl.isNullOrWhiteSpace) {
      final hlsManifest =
          await _controller.getHlsManifest(playerResponse.hlsManifestUrl!);
      yield* _parseStreamInfo(hlsManifest.streams,
          watchPage: watchPage, videoId: videoId);
    }
  }

  Stream<StreamInfo> _parseStreamInfo(Iterable<StreamInfoProvider> streams,
      {WatchPage? watchPage, VideoId? videoId}) async* {
    final nChallenges = <String>{};
    final sigChallenges = <String>{};

    final solver = _jsChallengeSolver;
    if (solver != null) {
      for (final stream in streams) {
        try {
          final url = Uri.parse(stream.url);
          if (url.queryParameters.containsKey('n')) {
            nChallenges.add(url.queryParameters['n']!);
          }
          if (stream.signatureParameter != null) {
            sigChallenges.add(stream.signature!);
          }
        } catch (_) {}
      }
    }

    final solvedChallenges = <String, String?>{};
    if (watchPage != null &&
        solver != null &&
        (nChallenges.isNotEmpty || sigChallenges.isNotEmpty)) {
      final requests = <JSChallengeType, List<String>>{};
      if (nChallenges.isNotEmpty) {
        requests[JSChallengeType.n] = nChallenges.toList();
      }
      if (sigChallenges.isNotEmpty) {
        requests[JSChallengeType.sig] = sigChallenges.toList();
      }

      try {
        solvedChallenges
            .addAll(await solver.solveBulk(watchPage.sourceUrl!, requests));
      } catch (e) {
        _logger.warning('Could not bulk solve challenges: $e');
      }
    }

    for (final stream in streams) {
      final itag = stream.tag;
      late Uri url;
      try {
        url = Uri.parse(stream.url);
      } catch (e) {
        continue;
      }

      if (!_isAbsoluteHttpUrl(url)) {
        continue;
      }

      if (solver != null && watchPage != null) {
        if (url.queryParameters.containsKey('n')) {
          final nParam = url.queryParameters['n']!;
          final decoded = solvedChallenges[nParam];
          if (decoded != null) {
            url = url.setQueryParam('n', decoded);
          }
        }
        if (stream.signatureParameter != null) {
          final sigParam = stream.signatureParameter!;
          final sig = stream.signature!;
          final decoded = solvedChallenges[sig];
          if (decoded != null) {
            url = url.setQueryParam(sigParam, decoded);
          }
        }
      }

      final contentLength = stream.contentLength ?? 0;
      final container = StreamContainer.parse(stream.container ?? 'mp4');
      final fileSize = FileSize(contentLength);
      final bitrate = Bitrate(stream.bitrate ?? 128000);

      final audioCodec = stream.audioCodec;
      final videoCodec = stream.videoCodec;

      // HLS Akışları (Apple visionOS akışları)
      if (stream.source == StreamSource.hls) {
        if (stream.audioOnly) {
          yield HlsAudioStreamInfo(
            videoId ?? watchPage?.videoId ?? VideoId(''),
            itag,
            url,
            container,
            fileSize,
            bitrate,
            '',
            '',
            stream.codec,
          );
          continue;
        }

        final framerate = Framerate(stream.framerate ?? 24);
        final videoQuality = VideoQualityUtil.fromLabel(stream.qualityLabel);
        final videoWidth = stream.videoWidth;
        final videoHeight = stream.videoHeight;
        final videoResolution = videoWidth != null && videoHeight != null
            ? VideoResolution(videoWidth, videoHeight)
            : videoQuality.toVideoResolution();

        if (stream.videoOnly) {
          yield HlsVideoStreamInfo(
            videoId ?? watchPage?.videoId ?? VideoId(''),
            itag,
            url,
            container,
            fileSize,
            bitrate,
            videoCodec ?? '',
            videoQuality.qualityString,
            videoQuality,
            videoResolution,
            framerate,
            stream.codec,
            stream.audioItag,
          );
        } else {
          yield HlsMuxedStreamInfo(
            videoId ?? watchPage?.videoId ?? VideoId(''),
            itag,
            url,
            container,
            fileSize,
            bitrate,
            audioCodec ?? '',
            videoCodec ?? '',
            videoQuality.qualityString,
            videoQuality,
            videoResolution,
            framerate,
            stream.codec,
          );
        }
        continue;
      }

      // Standart Progressive / Muxed (Tek Parça İndirilebilir MP4 Akışları)
      if (!videoCodec.isNullOrWhiteSpace) {
        final framerate = Framerate(stream.framerate ?? 24);
        final videoQuality = VideoQualityUtil.fromLabel(stream.qualityLabel);
        final videoWidth = stream.videoWidth;
        final videoHeight = stream.videoHeight;
        final videoResolution = videoWidth != null && videoHeight != null
            ? VideoResolution(videoWidth, videoHeight)
            : videoQuality.toVideoResolution();

        if (!audioCodec.isNullOrWhiteSpace &&
            stream.source != StreamSource.adaptive) {
          yield MuxedStreamInfo(
            videoId ?? watchPage?.videoId ?? VideoId(''),
            itag,
            url,
            container,
            fileSize,
            bitrate,
            audioCodec!,
            videoCodec!,
            videoQuality.qualityString,
            videoQuality,
            videoResolution,
            framerate,
            stream.codec,
          );
          continue;
        }

        yield VideoOnlyStreamInfo(
          videoId ?? watchPage?.videoId ?? VideoId(''),
          itag,
          url,
          container,
          fileSize,
          bitrate,
          videoCodec!,
          videoQuality.qualityString,
          videoQuality,
          videoResolution,
          framerate,
          stream.fragments ?? const [],
          stream.codec,
        );
        continue;
      } else if (!audioCodec.isNullOrWhiteSpace || stream.audioOnly) {
        yield AudioOnlyStreamInfo(
          videoId ?? watchPage?.videoId ?? VideoId(''),
          itag,
          url,
          container,
          fileSize,
          bitrate,
          audioCodec ?? 'mp4a.40.2',
          stream.qualityLabel ?? 'AUDIO_QUALITY_MEDIUM',
          stream.fragments ?? const [],
          stream.codec,
          stream.audioTrack,
        );
      }
    }
  }

  static bool _isAbsoluteHttpUrl(Uri url) =>
      (url.scheme == 'http' || url.scheme == 'https') && url.host.isNotEmpty;

  static bool _hasPlayableUrl(StreamInfo stream) =>
      _isAbsoluteHttpUrl(stream.url);
}
