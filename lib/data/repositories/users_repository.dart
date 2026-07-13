import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

abstract class UsersRepository {
  List<User> fetchUsers();

  User getCurrentUser();
}

class InMemoryUsersRepository implements UsersRepository {
  InMemoryUsersRepository();

  final List<User> _users = const <User>[
    User(id: 'user-alex', name: 'Alex Rivera', email: 'alex@tripsplit.app'),
    User(
      id: 'user-jordan',
      name: 'Jordan Smith',
      email: 'jordan@tripsplit.app',
    ),
    User(id: 'user-casey', name: 'Casey Wong', email: 'casey@tripsplit.app'),
    User(id: 'user-sarah', name: 'Sarah Chen', email: 'sarah@tripsplit.app'),
  ];

  @override
  List<User> fetchUsers() => List<User>.unmodifiable(_users);

  @override
  User getCurrentUser() => _users.first;
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return InMemoryUsersRepository();
});

final usersProvider = Provider<List<User>>((ref) {
  return ref.watch(usersRepositoryProvider).fetchUsers();
});

final currentUserProvider = Provider<User>((ref) {
  return ref.watch(usersRepositoryProvider).getCurrentUser();
});
