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

class UpdateUserUseCase extends DataManagerUseCase<String, User> {
  @override
  Future<Either<Failure, User>> execute(Tuple2<String, User> params) async {
    if (params == null) {
      return left(NotFound());
    } else {
      final res = await Future.delayed(
          Duration(milliseconds: 500), () => User(params.value1, '11'));

      return right(res);
    }
  }
}

class UserDataManager extends DataManager<User> {
  UserDataManager() : super([GetUserUseCase(), UpdateUserUseCase()]);

  getUser() {
    runUseCase<GetUserUseCase, int>(3);
  }

  updateUser() {
    runUseCase<UpdateUserUseCase, Tuple2<String, User>>(tuple2('fredo', value));
  }

  throwError() {
    runUseCase<GetUserUseCase, int>(null);
  }

  getUserWithModification() {
    asyncMapFn = (user) async {
      final newUser = User('New User', '100');
      return await Future.delayed(Duration(milliseconds: 100), () => newUser);
    };

    runUseCase<GetUserUseCase, int>(3);
  }

  @override
  void close() {
    super.close();
  }
}

void main() {
  final subscription = CompositeSubscription();
  final userManager = UserDataManager();

  group('Test DataManager', () {
    setUp(() {
      subscription.add(userManager.subscriber);
    });

    test('Should emit expected data', () async {
      final subscription = userManager.stream.listen(expectAsync1((event) {
        expect(event.runtimeType, User);
        expect(event.name, 'name');
      }));

      userManager.getUser();

      await userManager.waitDone;
      subscription.cancel();
    });

    test('Should emait failure', () async {
      userManager.onFailure.listen(expectAsync1((event) {
        expect(event.runtimeType, NotFound);
      }));

      userManager.throwError();

      await userManager.waitDone;
    });

    test('Should emit loading', () async {
      expect(userManager.isLoading, emitsInOrder([false, true, false, true]));

      userManager.getUser();

      await userManager.waitDone;

      userManager.getUser();
      await userManager.waitDone;
    });

    test('Should update name with update function', () async {
      final nameSteam = userManager.stream.map((event) => event.name);

      expect(nameSteam, emitsInOrder(['name', 'fredo']));

      userManager.updateUser();
      await userManager.waitDone;
    });

    test(
        'Should run the AsyncMap to modify age, and automatically clear the fn',
        () async {
      final ageStream = userManager.stream.map((event) => event.age);

      expect(ageStream, emitsInOrder(['11', '100']));

      userManager.getUserWithModification();

      await userManager.waitDone;
    });

    test('Should and automatically clear the fn', () async {
      final ageStream = userManager.stream.map((event) => event.age);

      expect(ageStream, emitsInOrder(['100', 'age']));
      userManager.getUser();

      await userManager.waitDone;
    });

    tearDown(() {
      subscription.clear();
    });
  });
}
