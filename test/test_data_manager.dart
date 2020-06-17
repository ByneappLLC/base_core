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
  final userManager = DataManager<int, User, GetUserUseCase>(useCase);

  group('Test DataManager', () {
    setUp(() {
      subscription.add(userManager.subscriber);
    });

    test('Should emit expected data', () async {
      final subscription = userManager.stream.listen(expectAsync1((event) {
        expect(event.runtimeType, User);
        expect(event.name, 'name');
      }));

      userManager.load(3);

      await Future.delayed(Duration(milliseconds: 550));
      subscription.cancel();
    });

    test('Should emait failure', () {
      userManager.onFailure.listen(expectAsync1((event) {
        expect(event.runtimeType, NotFound);
      }));

      userManager.load();
    });

    test('Should emit loading', () async {
      expect(userManager.isLoading, emitsInOrder([false, true, false, true]));

      userManager.load(3);

      await Future.delayed(
          Duration(milliseconds: 510)); // wait for the previous call to finish

      userManager.load(3);
    });

    test('Should update name with update function', () async {
      final nameSteam = userManager.stream.map((event) => event.name);

      expect(nameSteam, emitsInOrder(['name', 'newName']));

      userManager.update(User('newName', '23'));
    });

    tearDown(() {
      subscription.clear();
    });
  });
}
