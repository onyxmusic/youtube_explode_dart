class YoutubeApiClient {
  final Map<String, dynamic> payload;
  final String apiUrl;
  final Map<String, dynamic> headers;

  const YoutubeApiClient(this.payload, this.apiUrl, {this.headers = const {}});

  YoutubeApiClient.fromJson(Map<String, dynamic> json)
      : payload = json['payload'],
        apiUrl = json['apiUrl'],
        headers = json['headers'];

  Map<String, dynamic> toJson() => {
        'payload': payload,
        'apiUrl': apiUrl,
        'headers': headers,
      };

  /// 🚀 TEST EDİLMİŞ VE DOĞRULANMIŞ RESMİ IOS (v20.10.4) İSTEMCİSİ
  static final ios = YoutubeApiClient(
    {
      'context': {
        'client': {
          'clientName': 'IOS',
          'clientVersion': '20.10.4',
          'deviceMake': 'Apple',
          'deviceModel': 'iPhone16,2',
          'userAgent':
              'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_1_0 like Mac OS X;)',
          'hl': 'en',
          'gl': 'US',
          'platform': 'MOBILE',
          'osName': 'iOS',
          'osVersion': '18.1.0.22B83',
          'timeZone': 'UTC',
          'utcOffsetMinutes': 0
        }
      },
    },
    'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
    headers: {
      'Content-Type': 'application/json',
      'User-Agent':
          'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_1_0 like Mac OS X;)',
      'Origin': 'https://www.youtube.com',
    },
  );

  /// ANDROID_SDKLESS İstemcisi
  static const androidSdkless = YoutubeApiClient(
    {
      'context': {
        'client': {
          'clientName': 'ANDROID',
          'clientVersion': '20.10.38',
          'osName': 'Android',
          'osVersion': '11',
          'hl': 'en',
          'gl': 'US',
          'timeZone': 'UTC',
          'utcOffsetMinutes': 0,
        },
      },
    },
    'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
    headers: {
      'Content-Type': 'application/json',
      'User-Agent':
          'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
      'Origin': 'https://www.youtube.com',
    },
  );

  static const android = androidSdkless;
  static const androidVr = androidSdkless;

  static const androidMusic = YoutubeApiClient(
    {
      'context': {
        'client': {
          'clientName': 'ANDROID_MUSIC',
          'clientVersion': '2.16.032',
          'userAgent':
              'com.google.android.youtube/19.29.1 (Linux; U; Android 11) gzip',
          'hl': 'en',
          'gl': 'US',
          'timeZone': 'UTC',
          'utcOffsetMinutes': 0,
        },
      },
    },
    'https://music.youtube.com/youtubei/v1/player?prettyPrint=false',
  );

  static const safari = YoutubeApiClient(
    {
      'context': {
        'client': {
          'clientName': 'WEB',
          'clientVersion': '2.20250312.04.00',
          'userAgent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15,gzip(gfe)',
          'hl': 'en',
          'timeZone': 'UTC',
          'utcOffsetMinutes': 0,
        },
      },
    },
    'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
  );

  static const tv = YoutubeApiClient(
    {
      'context': {
        'client': {
          'clientName': 'TVHTML5',
          'clientVersion': '7.20251105.10.00',
          'hl': 'en',
          'gl': 'US',
          'timeZone': 'UTC',
          'platform': 'DESKTOP',
          'osName': 'TV',
          'osVersion': '1.0',
        },
      },
    },
    'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
    headers: {
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (ChromiumStylePlatform) Cobalt/Version,gzip(gfe)',
      'Origin': 'https://www.youtube.com',
    },
  );

  static const mediaConnect = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'MEDIA_CONNECT_FRONTEND',
        'clientVersion': '0.1',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  static const mweb = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'MWEB',
        'clientVersion': '2.20240726.01.00',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  @Deprecated('Youtube always requires authentication for this client')
  static const webCreator = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'WEB_CREATOR',
        'clientVersion': '1.20240723.03.00',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  @Deprecated('Youtube always requires authentication for this client')
  static const tvSimplyEmbedded = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'TVHTML5_SIMPLY_EMBEDDED_PLAYER',
        'clientVersion': '2.0',
        'hl': 'en',
        'timeZone': 'UTC',
        'gl': 'US',
        'utcOffsetMinutes': 0
      }
    },
    'thirdParty': {'embedUrl': 'https://www.youtube.com/'},
    'contentCheckOk': true,
    'racyCheckOk': true
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');
}
