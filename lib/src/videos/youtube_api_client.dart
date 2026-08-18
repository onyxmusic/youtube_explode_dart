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

  /// 🚀 TEST EDİLMİŞ VE İMZALI LİNK ÜRETEN RESMİ IOS (v20.10.4) İSTEMCİSİ
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

  static final androidSdkless = ios;
  static final android = ios;
  static final androidVr = ios;
}
