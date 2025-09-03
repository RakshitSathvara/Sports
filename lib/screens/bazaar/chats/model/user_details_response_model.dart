class UserDetails {
  final int sysUserId;
  final String userName;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String userType;

  UserDetails({
    required this.sysUserId,
    required this.userName,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.userType,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      sysUserId: json['SysUserId'] ?? 0,
      userName: json['UserName'] ?? '',
      fullName: json['FullName'] ?? '',
      mobileNumber: json['MobileNumber'] ?? '',
      email: json['Email'] ?? '',
      userType: json['UserType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SysUserId': sysUserId,
      'UserName': userName,
      'FullName': fullName,
      'MobileNumber': mobileNumber,
      'Email': email,
      'UserType': userType,
    };
  }

  @override
  String toString() {
    return 'UserDetails(sysUserId: $sysUserId, userName: $userName, fullName: $fullName, '
        'mobileNumber: $mobileNumber, email: $email, userType: $userType)';
  }
}
