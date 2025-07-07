class UserData {
  final String nombre;
  final double sueldo;
  final double gastosFijos;
  final double gastosVariables;
  final double metaAhorro;

  UserData({
    required this.nombre,
    required this.sueldo,
    required this.gastosFijos,
    required this.gastosVariables,
    required this.metaAhorro,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'sueldo': sueldo,
      'gastosFijos': gastosFijos,
      'gastosVariables': gastosVariables,
      'metaAhorro': metaAhorro,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nombre: json['nombre'] ?? '',
      sueldo: json['sueldo']?.toDouble() ?? 0.0,
      gastosFijos: json['gastosFijos']?.toDouble() ?? 0.0,
      gastosVariables: json['gastosVariables']?.toDouble() ?? 0.0,
      metaAhorro: json['metaAhorro']?.toDouble() ?? 0.0,
    );
  }
}
