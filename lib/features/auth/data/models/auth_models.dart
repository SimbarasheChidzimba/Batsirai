import '../../domain/user.dart';

/// Response model for authentication operations
class AuthResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? message;
  final int? statusCode;

  const AuthResponse._({
    required this.success,
    this.user,
    this.token,
    this.message,
    this.statusCode,
  });

  factory AuthResponse.success({required User user, String? token}) {
    return AuthResponse._(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResponse.error({
    required String message,
    int? statusCode,
  }) {
    return AuthResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

/// Request model for registration
class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final bool isDiaspora;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    this.isDiaspora = false,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'isDiaspora': isDiaspora,
      };
}

/// Request model for login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
