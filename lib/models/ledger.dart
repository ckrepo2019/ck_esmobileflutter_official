class Ledger {
  final String particulars;
  final String amount;
  final String payment;
  final String balance;

  Ledger({
    required this.particulars,
    required this.amount,
    required this.payment,
    required this.balance,
  });

  factory Ledger.fromJson(Map<String, dynamic> json) {
    return Ledger(
      particulars: json['particulars'] ?? '',
      amount: json['amount'] ?? '',
      payment: json['payment'] ?? '',
      balance: json['balance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'particulars': particulars,
      'amount': amount,
      'payment': payment,
      'balance': balance,
    };
  }

  @override
  String toString() {
    return 'Ledger(particulars: $particulars, amount: $amount, payment: $payment, balance: $balance)';
  }
}
