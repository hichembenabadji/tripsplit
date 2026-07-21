import 'package:cloud_firestore/cloud_firestore.dart';

class UserDirectoryEntry {
  const UserDirectoryEntry({
    required this.userId,
    required this.email,
    required this.displayName,
    this.createdAt,
  });

  final String userId;
  final String email;
  final String displayName;
  final DateTime? createdAt;
}

class UserDirectoryFailure implements Exception {
  const UserDirectoryFailure(this.message);

  final String message;

  @override
  String toString() => 'UserDirectoryFailure(message: $message)';
}

abstract class UserDirectoryRepository {
  Future<void> ensureUserDocument({
    required String userId,
    required String email,
    String? displayName,
    DateTime? createdAt,
  });

  Future<UserDirectoryEntry?> findUserByEmail(String email);

  Future<Map<String, UserDirectoryEntry>> fetchUsersByIds(
    Iterable<String> userIds,
  );
}

class FirestoreUserDirectoryRepository implements UserDirectoryRepository {
  FirestoreUserDirectoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<void> ensureUserDocument({
    required String userId,
    required String email,
    String? displayName,
    DateTime? createdAt,
  }) async {
    final String normalizedEmail = _normalizeEmail(email);
    final String resolvedDisplayName = _resolveDisplayName(
      displayName: displayName,
      email: normalizedEmail,
    );
    final DocumentReference<Map<String, dynamic>> userRef = _users.doc(userId);

    try {
      final DocumentSnapshot<Map<String, dynamic>> existingSnapshot =
          await userRef.get();
      final Object createdAtValue = createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt);

      if (!existingSnapshot.exists) {
        await userRef.set(<String, Object>{
          'email': normalizedEmail,
          'displayName': resolvedDisplayName,
          'createdAt': createdAtValue,
        });
        return;
      }

      final Map<String, dynamic> existingData =
          existingSnapshot.data() ?? <String, dynamic>{};
      final Map<String, Object> updates = <String, Object>{};

      if (existingData['email'] != normalizedEmail) {
        updates['email'] = normalizedEmail;
      }

      if (existingData['displayName'] != resolvedDisplayName) {
        updates['displayName'] = resolvedDisplayName;
      }

      if (!existingData.containsKey('createdAt') ||
          existingData['createdAt'] == null) {
        updates['createdAt'] = createdAtValue;
      }

      if (updates.isNotEmpty) {
        await userRef.set(updates, SetOptions(merge: true));
      }
    } on FirebaseException catch (error) {
      throw UserDirectoryFailure(
        error.message ?? 'Unable to keep the user directory in sync.',
      );
    }
  }

  @override
  Future<UserDirectoryEntry?> findUserByEmail(String email) async {
    final String normalizedEmail = _normalizeEmail(email);

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _users
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return _entryFromSnapshot(snapshot.docs.single);
    } on FirebaseException catch (error) {
      throw UserDirectoryFailure(
        error.message ?? 'Unable to look up that TripSplit account.',
      );
    }
  }

  @override
  Future<Map<String, UserDirectoryEntry>> fetchUsersByIds(
    Iterable<String> userIds,
  ) async {
    final List<String> normalizedUserIds = userIds
        .where((String id) => id.trim().isNotEmpty)
        .map((String id) => id.trim())
        .toSet()
        .toList(growable: false);

    if (normalizedUserIds.isEmpty) {
      return <String, UserDirectoryEntry>{};
    }

    final Map<String, UserDirectoryEntry> usersById =
        <String, UserDirectoryEntry>{};

    try {
      for (int index = 0; index < normalizedUserIds.length; index += 30) {
        final int end = (index + 30 > normalizedUserIds.length)
            ? normalizedUserIds.length
            : index + 30;
        final List<String> batch = normalizedUserIds.sublist(index, end);

        final QuerySnapshot<Map<String, dynamic>> snapshot = await _users
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in snapshot.docs) {
          final UserDirectoryEntry entry = _entryFromSnapshot(doc);
          usersById[entry.userId] = entry;
        }
      }

      return usersById;
    } on FirebaseException catch (error) {
      throw UserDirectoryFailure(
        error.message ?? 'Unable to load participant details right now.',
      );
    }
  }

  UserDirectoryEntry _entryFromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data();
    return UserDirectoryEntry(
      userId: snapshot.id,
      email: (data['email'] as String? ?? '').trim(),
      displayName: _resolveDisplayName(
        displayName: data['displayName'] as String?,
        email: data['email'] as String? ?? '',
      ),
      createdAt: _readDateTime(data['createdAt']),
    );
  }
}

String _normalizeEmail(String email) => email.trim().toLowerCase();

String _resolveDisplayName({
  required String? displayName,
  required String email,
}) {
  final String normalizedDisplayName = (displayName ?? '').trim();
  if (normalizedDisplayName.isNotEmpty) {
    return normalizedDisplayName;
  }

  final String localPart = _normalizeEmail(email).split('@').first.trim();
  if (localPart.isEmpty) {
    return 'Traveler';
  }

  final List<String> parts = localPart
      .split(RegExp(r'[._-]+'))
      .where((String token) => token.isNotEmpty)
      .map(_capitalizeToken)
      .toList(growable: false);

  if (parts.isEmpty) {
    return 'Traveler';
  }

  return parts.join(' ');
}

DateTime? _readDateTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  return null;
}

String _capitalizeToken(String value) {
  if (value.isEmpty) {
    return value;
  }

  return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
}
