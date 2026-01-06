/// Defines the roles available in the application.
enum UserRole {
  /// Regular user (Client) who tracks their measurements.
  user,

  /// Trainer who can view their assigned users' data.
  trainer,

  /// Admin who has full access to manage users.
  admin,
}

/// Represents a user of the application.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    this.acceptedTerms = false,
    this.assignedTrainerId,
  });

  /// Unique identifier for the user.
  final String uid;

  /// User's email address.
  final String email;

  /// User's display name.
  final String name;

  /// The role assigned to the user.
  final UserRole role;

  /// Whether the user account is active.
  final bool isActive;

  /// Whether the user has accepted terms and conditions.
  final bool acceptedTerms;

  /// ID of the assigned trainer (if any).
  final String? assignedTrainerId;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    // Check if profile exists and has assignedTrainerId
    String? trainerId;
    if (map['profile'] != null && map['profile']['assignedTrainerId'] != null) {
      trainerId = map['profile']['assignedTrainerId'];
    }

    return AppUser(
      uid: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: _parseRole(map['role']),
      isActive: map['isActive'] ?? true,
      acceptedTerms: map['acceptedTerms'] ?? false,
      assignedTrainerId: trainerId,
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'ADMINISTRADOR':
        return UserRole.admin;
      case 'ENTRENADOR':
        return UserRole.trainer;
      default:
        return UserRole.user;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.role == role;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode ^ name.hashCode ^ role.hashCode;
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, name: $name, role: $role)';
  }
}
