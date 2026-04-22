//해당 IP값 아님

class ApiConfig {
  static const String serverIp = 'ip'; // 본인 노트북 IP
  static const String serverPort = 'spring port';      // 스프링 포트
  static const String baseUrl = 'http://$serverIp:$serverPort/api';
}