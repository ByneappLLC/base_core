import 'package:base_core/base_core.dart';
import 'package:base_core/src/data_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

class User {
  final String name;
  final String age;

  User(this.name, this.age);
}

class NotFound extends Failure {}

class GetUserUseCase extends UseCase<int, User> {
  @override
  Future<Either<Failure, User>> execute(int params) async {
    if (params == null) {
      return left(NotFound());
    } else {
      final res = await Future.delayed(
          Duration(milliseconds: 500), () => User('name', 'age'));

      return right(res);
    }
  }
}

void main() {
  final subscription = CompositeSubscription();
  final useCase = GetUserUseCase();
  final userManager = DataManager<User, int, GetUserUseCase>(useCase);

  group('Test DataManager', () {
    setUp(() {
      subscription.add(userManager.subscriber);
    });

    test('Should emit expected data', () {
      userManager.stream.listen(expectAsync1((event) {
        expect(event.runtimeType, User);
        expect(event.name, 'name');
      }));

      userManager.getData(3);
    });

    test('Should emait failure', () {
      userManager.onFailure.listen(expectAsync1((event) {
        expect(event.runtimeType, NotFound);
      }));

      userManager.getData();
    });

    test('Should emit loading', () async {
      expect(userManager.isLoading, emitsInOrder([false, true, false, true]));

      userManager.getData(3);

      await Future.delayed(
          Duration(milliseconds: 1200)); // wait for the previous call to finish

      userManager.getData(3);
    });

    tearDown(() {
      subscription.clear();
    });
  });
}
