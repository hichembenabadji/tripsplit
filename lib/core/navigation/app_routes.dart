abstract final class AppRoutes {
  static const signIn = '/sign-in';

  static const calculator = '/calculator';
  static const settleUp = 'settle-up';

  static const trips = '/trips';
  static const createTrip = 'create';
  static const tripId = 'tripId';
  static const addExpense = 'expenses/new';
  static const splitDetails = 'split-details';

  static const profile = '/profile';

  static String tripLocation(String tripId) => '$trips/$tripId';

  static String addExpenseLocation(String tripId) =>
      '${tripLocation(tripId)}/$addExpense';

  static String splitDetailsLocation(String tripId) =>
      '${tripLocation(tripId)}/$splitDetails';
}
