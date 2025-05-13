class Camera {
  final int id;
  final String name;
  final String code;

  Camera({required this.id, required this.name, required this.code});

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}
