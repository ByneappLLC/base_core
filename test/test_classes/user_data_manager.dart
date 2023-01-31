import 'package:base_core/src/data_manager.dart';

import 'usecases/get_user_usecase.dart';
import 'usecases/get_users_ages.dart';
import 'usecases/update_user_usecase.dart';
import 'user_model.dart';
import 'user_usecase_generator.dart';

class UserDataManager extends DataManager<User> {
  UserDataManager(UserUseCaseGenerator generated) : super(generated);

  getUser() {
    runUseCase<GetUserUseCase, int>(3);
  }

  updateUser(String? name) {
    runUseCase<UpdateUserUseCase, String?>(name);
  }

  getUsersAges() {
    runUseCase<GetUserAges, void>(null);
  }

  @override
  void close() {
    super.close();
  }
}
