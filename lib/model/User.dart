class User {
  final int UserID;
  final String Name;
  final String UserName;
  final String Password;
  final String Email;
  final String DateofBirth;
  final String Geneder;
  final int PhoneNo;
  final String Address;
  final String UserType;

  User({
    required this.UserID,
    required this.Name,
    required this.UserName,
    required this.Password,
    required this.Email,
    required this.DateofBirth,
    required this.Geneder,
    required this.PhoneNo,
    required this.Address,
    required this.UserType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      UserID: json['UserID'],
      Name: json['Name'],
      UserName: json['UserName'],
      Password: json['Password'],
      Email: json['Email'],
      DateofBirth: json['dateofBirth'],
      Geneder: json['geneder'],
      PhoneNo: json['phoneNo'],
      Address: json['address'],
      UserType: json['userType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': UserID,
      'Name': Name,
      'UserName': UserName,
      'Password': Password,
      'Email': Email,
      'dateofBirth': DateofBirth,
      'geneder': Geneder,
      'phoneNo': PhoneNo,
      'address': Address,
      'userType': UserType,
    };
  }
}
