enum TransactionType {
  cashIn('cash_in'),
  cashOut('cash_out'),
  sendMoney('send_money'),
  billPay('bill_pay'),
  flexiload('flexiload'),
  floatPurchase('float_purchase'),
  floatTransfer('float_transfer'),
  bankDeposit('bank_deposit'),
  expense('expense'),
  adjustment('adjustment'),

  /// Credit given: the agent paid out (cash/e-money/load) and the customer
  /// owes it (baki).
  dueGiven('due_given'),

  /// A customer paid back (part of) what they owed.
  dueSettled('due_settled'),

  /// A customer left money with the agent, which the agent owes back.
  dueTaken('due_taken'),

  /// The agent returned money held for a customer.
  duePaid('due_paid'),

  /// The provider credited commission to the wallet.
  commissionReceived('commission_received');

  const TransactionType(this.dbName);

  final String dbName;

  static TransactionType fromDb(String value) =>
      TransactionType.values.firstWhere((t) => t.dbName == value);
}
