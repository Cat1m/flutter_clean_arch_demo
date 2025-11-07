import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

// --- Main User Model ---
@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String firstName,
    required String lastName,
    required String maidenName,
    required int age,
    required String gender,
    required String email,
    required String phone,
    required String username,
    required String password,
    required String birthDate,
    required String image,
    required String bloodGroup,
    required double height,
    required double weight,
    required String eyeColor,
    required Hair hair,
    required String ip,
    required Address address,
    required String macAddress,
    required String university,
    required Bank bank,
    required Company company,
    required String ein,
    required String ssn,
    required String userAgent,
    required Crypto crypto,
    required String role,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// --- Sub-Models ---

@freezed
abstract class Hair with _$Hair {
  const factory Hair({required String color, required String type}) = _Hair;

  factory Hair.fromJson(Map<String, dynamic> json) => _$HairFromJson(json);
}

@freezed
abstract class Address with _$Address {
  const factory Address({
    required String address,
    required String city,
    required String state,
    required String stateCode,
    required String postalCode,
    required Coordinates coordinates,
    required String country,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

@freezed
abstract class Coordinates with _$Coordinates {
  const factory Coordinates({required double lat, required double lng}) =
      _Coordinates;

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);
}

@freezed
abstract class Bank with _$Bank {
  const factory Bank({
    required String cardExpire,
    required String cardNumber,
    required String cardType,
    required String currency,
    required String iban,
  }) = _Bank;

  factory Bank.fromJson(Map<String, dynamic> json) => _$BankFromJson(json);
}

@freezed
abstract class Company with _$Company {
  const factory Company({
    required String department,
    required String name,
    required String title,
    required Address address, // Tái sử dụng Address model
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
}

@freezed
abstract class Crypto with _$Crypto {
  const factory Crypto({
    required String coin,
    required String wallet,
    required String network,
  }) = _Crypto;

  factory Crypto.fromJson(Map<String, dynamic> json) => _$CryptoFromJson(json);
}
