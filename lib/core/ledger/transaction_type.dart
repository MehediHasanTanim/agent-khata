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
  adjustment('adjustment');

  const TransactionType(this.dbName);

  final String dbName;

  static TransactionType fromDb(String value) =>
      TransactionType.values.firstWhere((t) => t.dbName == value);
}
