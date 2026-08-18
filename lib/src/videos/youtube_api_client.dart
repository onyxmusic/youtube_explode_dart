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

  /// Working iOS client configuration with high reliability
  static final ios = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'IOS',
        'clientVersion': '20.15.1',
        'deviceMake': 'Apple',
        'deviceModel': 'iPhone16,2',
        'userAgent':
            'com.google.ios.youtube/20.15.1 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
        'hl': 'en',
        'platform': 'MOBILE',
        'osName': 'IOS',
        'osVersion': '18.1.0',
        'timeZone': 'UTC',
        'gl': 'US',
        'utcOffsetMinutes': 0
      }
    },
  }, 'https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false');

  /// Android client without androidSdkVersion field.
  static const androidSdkless = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID',
        'clientVersion': '20.15.34',
        'userAgent':
            'com.google.android.youtube/20.15.34 (Linux; U; Android 12) gzip',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
        'osName': 'Android',
        'osVersion': '12',
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  static const android = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID',
        'clientVersion': '20.10.38',
        'androidSdkVersion': 30,
        'userAgent':
            'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
        'osName': 'Android',
        'osVersion': '11',
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  static const androidMusic = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID_MUSIC',
        'clientVersion': '6.42.52',
        'androidSdkVersion': 31,
        'userAgent':
            'com.google.android.apps.youtube.music/6.42.52 (Linux; U; Android 11) gzip',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://music.youtube.com/youtubei/v1/player?key=AIzaSyAOghZGza2MQSZkY_zfZ370N-PUdXEo8AI&prettyPrint=false');

  static const androidVr = YoutubeApiClient({
    'context': {
      'client': {
        'clientName': 'ANDROID_VR',
        'clientVersion': '1.56.21',
        'deviceModel': 'Quest 3',
        'osVersion': '12',
        'osName': 'Android',
        'androidSdkVersion': '32',
        'hl': 'en',
        'timeZone': 'UTC',
        'utcOffsetMinutes': 0,
      },
    },
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  static const safari = YoutubeApiClient({
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
  }, 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false');

  static const tv = YoutubeApiClient(
      {
        'context': {
          'client': {
            'deviceMake': '',
            'deviceModel': '',
            'userAgent':
                'Mozilla/5.0 (ChromiumStylePlatform) Cobalt/Version,gzip(gfe)',
            'clientName': 'TVHTML5',
            'clientVersion': '7.20251105.10.00',
            'hl': 'en',
            'timeZone': 'UTC',
            'gl': 'US',
            'utcOffsetMinutes': 0,
            'originalUrl': 'https://www.youtube.com/tv',
            'theme': 'CLASSIC',
            'platform': 'DESKTOP',
            'clientFormFactor': 'UNKNOWN_FORM_FACTOR',
            'webpSupport': false,
            'configInfo': {},
            'tvAppInfo': {'appQuality': 'TV_APP_QUALITY_FULL_ANIMATION'},
            'acceptHeader':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
          'user': {'lockedSafetyMode': false},
          'request': {'useSsl': true},
        },
        'contentCheckOk': true,
        'racyCheckOk': true,
      },
      'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
      headers: {
        'Sec-Fetch-Mode': 'navigate',
        'Content-Type': 'application/json',
        'Origin': 'https://www.youtube.com',
      });

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
        'clientVersion': '2.20250312.04.00',
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
  static const tvSimplyEmbedded = YoutubeApiClient(
      {
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
      },
      'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
      headers: {
        'Sec-Fetch-Mode': 'navigate',
        'Content-Type': 'application/json',
        'Origin': 'https://www.youtube.com',
      });
}
