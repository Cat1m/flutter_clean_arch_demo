import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/user/models/user_model.dart';
import 'package:reqres_in/src/features/user/presentation/bloc/user_cubit.dart';
import 'package:reqres_in/src/features/user/presentation/bloc/user_state.dart';
import 'package:reqres_in/src/features/user/repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

User _buildUser() {
  const address = Address(
    address: '123 Main St',
    city: 'Ho Chi Minh',
    state: 'HCM',
    stateCode: 'HCM',
    postalCode: '700000',
    coordinates: Coordinates(lat: 10.0, lng: 20.0),
    country: 'VN',
  );

  return const User(
    id: 1,
    firstName: 'Emily',
    lastName: 'Johnson',
    maidenName: '',
    age: 28,
    gender: 'female',
    email: 'emily@x.com',
    phone: '0123456789',
    username: 'emilys',
    password: 'secret',
    birthDate: '1996-05-30',
    image: 'https://x/img.png',
    bloodGroup: 'O-',
    height: 170,
    weight: 55,
    eyeColor: 'brown',
    hair: Hair(color: 'brown', type: 'curly'),
    ip: '127.0.0.1',
    address: address,
    macAddress: '00:00:00:00:00:00',
    university: 'ABC University',
    bank: Bank(
      cardExpire: '10/26',
      cardNumber: '1234567890123456',
      cardType: 'Visa',
      currency: 'USD',
      iban: 'IBAN123456',
    ),
    company: Company(
      department: 'IT',
      name: 'ABC Corp',
      title: 'Engineer',
      address: address,
    ),
    ein: '123-45-6789',
    ssn: '987-65-4321',
    userAgent: 'test-agent',
    crypto: Crypto(coin: 'BTC', wallet: 'wallet123', network: 'BTC'),
    role: 'admin',
  );
}

void main() {
  late MockUserRepository repository;
  final user = _buildUser();

  setUp(() {
    repository = MockUserRepository();
  });

  group('UserCubit', () {
    blocTest<UserCubit, UserState>(
      'fetchUser thành công → UserLoading rồi UserSuccess',
      build: () {
        when(() => repository.getMe()).thenAnswer((_) async => Right(user));
        return UserCubit(repository);
      },
      act: (cubit) => cubit.fetchUser(),
      expect: () => [isA<UserLoading>(), UserSuccess(user)],
    );

    blocTest<UserCubit, UserState>(
      'fetchUser thất bại → UserLoading rồi UserFailure chứa đúng Failure gốc',
      build: () {
        when(() => repository.getMe()).thenAnswer(
          (_) async => const Left(ServerFailure('Lỗi server', statusCode: 500)),
        );
        return UserCubit(repository);
      },
      act: (cubit) => cubit.fetchUser(),
      expect: () => [
        isA<UserLoading>(),
        isA<UserFailure>().having(
          (s) => s.failure,
          'failure',
          isA<ServerFailure>(),
        ),
      ],
    );
  });
}
