class Ledger {
  final String particulars;
  final String amount;
  final String payment;
  final String balance;
  final bool isVoided;

  Ledger({
    required this.particulars,
    required this.amount,
    required this.payment,
    required this.balance,
    this.isVoided = false,
  });

  factory Ledger.fromJson(Map<String, dynamic> json) {
    return Ledger(
      particulars: json['particulars'] ?? '',
      amount: json['amount'] ?? '',
      payment: json['payment'] ?? '',
      balance: json['balance'] ?? '',
      isVoided: (json['voided'] == 1 || json['voided'] == true) ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'particulars': particulars,
      'amount': amount,
      'payment': payment,
      'balance': balance,
      'voided': isVoided ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Ledger(particulars: $particulars, amount: $amount, payment: $payment, balance: $balance, isVoided: $isVoided)';
  }
}
