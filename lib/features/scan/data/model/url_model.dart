class Device {
  final String deviceId;
  final String ip;
  final int port;
  final String type;

  Device({
    required this.deviceId,
    required this.ip,
    required this.port,
    required this.type,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      ip: json['ip'],
      port: json['port'],
      type: json['type'],
    );
  }
}
