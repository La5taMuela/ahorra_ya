class UserData {
  final String nombre;
  final double sueldo;
  final double gastosFijos;
  final double gastosVariables;
  final double metaAhorro;

  // Nuevos campos para el modelo de ahorro cuadrático: A(t) = a*t^2 + b*t + c
  final double ahorroCoefA; // Coeficiente 'a' (aceleración del ahorro)
  final double ahorroCoefB; // Coeficiente 'b' (ahorro mensual base)
  final double ahorroCoefC; // Coeficiente 'c' (ahorro inicial)

  UserData({
    required this.nombre,
    required this.sueldo,
    required this.gastosFijos,
    required this.gastosVariables,
    required this.metaAhorro,
    this.ahorroCoefA = 0.0, // Valores por defecto
    this.ahorroCoefB = 0.0,
    this.ahorroCoefC = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'sueldo': sueldo,
      'gastosFijos': gastosFijos,
      'gastosVariables': gastosVariables,
      'metaAhorro': metaAhorro,
      'ahorroCoefA': ahorroCoefA,
      'ahorroCoefB': ahorroCoefB,
      'ahorroCoefC': ahorroCoefC,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nombre: json['nombre'] ?? '',
      sueldo: json['sueldo']?.toDouble() ?? 0.0,
      gastosFijos: json['gastosFijos']?.toDouble() ?? 0.0,
      gastosVariables: json['gastosVariables']?.toDouble() ?? 0.0,
      metaAhorro: json['metaAhorro']?.toDouble() ?? 0.0,
      ahorroCoefA: json['ahorroCoefA']?.toDouble() ?? 0.0,
      ahorroCoefB: json['ahorroCoefB']?.toDouble() ?? 0.0,
      ahorroCoefC: json['ahorroCoefC']?.toDouble() ?? 0.0,
    );
  }

  // Método para crear una copia con nuevos valores
  UserData copyWith({
    String? nombre,
    double? sueldo,
    double? gastosFijos,
    double? gastosVariables,
    double? metaAhorro,
    double? ahorroCoefA,
    double? ahorroCoefB,
    double? ahorroCoefC,
  }) {
    return UserData(
      nombre: nombre ?? this.nombre,
      sueldo: sueldo ?? this.sueldo,
      gastosFijos: gastosFijos ?? this.gastosFijos,
      gastosVariables: gastosVariables ?? this.gastosVariables,
      metaAhorro: metaAhorro ?? this.metaAhorro,
      ahorroCoefA: ahorroCoefA ?? this.ahorroCoefA,
      ahorroCoefB: ahorroCoefB ?? this.ahorroCoefB,
      ahorroCoefC: ahorroCoefC ?? this.ahorroCoefC,
    );
  }
}
