import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

import 'test_classes/failures.dart';
import 'test_classes/usecases/get_user_usecase.dart';
import 'test_classes/usecases/get_users_ages.dart';
import 'test_classes/usecases/update_user_usecase.dart';
import 'test_classes/user_data_manager.dart';
import 'test_classes/user_model.dart';
import 'test_classes/user_usecase_generator.dart';

void main() {
  final subscription = CompositeSubscription();
  final userManager = UserDataManager(UserUseCaseGenerator());

  group('Test DataManager', () {
    setUp(() {
      subscription.add(userManager.subscriber);
    });

    test('Should emit expected data', () async {
      final subscription = userManager.stream.listen(expectAsync1((event) {
        expect(event.runtimeType, User);
      }));

      userManager.getUser();

      await userManager.waitDone;
      subscription.cancel();
    });

    test('Should update name', () async {
      expect(userManager.stream.map(User.name.get),
          emitsInOrder([WRONG_NAME, FIXED_NAME]));

      userManager.updateUser(FIXED_NAME);

      await userManager.waitDone;
    });

    test('Should emit loading', () async {
      expect(userManager.isLoading, emitsInOrder([false, true, false, true]));

      userManager.getUser();

      await userManager.waitDone;

      userManager.getUser();
      await userManager.waitDone;
    });

    test('Should emit failure', () async {
      userManager.onFailure.listen(expectAsync1((event) {
        expect(event.runtimeType, NotFound);
      }));

      userManager.updateUser(null);
      await userManager.waitDone;
    });

    test('Should map using map function', () async {
      expect(
          userManager.stream.map(User.age.get),
          emitsInOrder([
            INITIAL_AGE,
            UPDATED_AGE,
          ]));

      userManager.getUsersAges();
      await userManager.waitDone;
    });

    tearDown(() {
      subscription.clear();
    });
  });
}
