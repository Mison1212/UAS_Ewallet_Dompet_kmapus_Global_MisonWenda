import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.accountId,
    required super.amount,
    required super.type,
    required super.description,
    required super.balanceBefore,
    required super.balanceAfter,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? json['tipe'] ?? '').toString().toLowerCase();
    final isCredit = rawType == 'credit' ||
        rawType == 'topup' ||
        rawType == 'top up' ||
        rawType == 'received' ||
        rawType == 'deposit';
    final description = (json['description'] ??
            json['keterangan'] ??
            json['order_id_marketplace'] ??
            _labelFromType(rawType))
        .toString();

    return TransactionModel(
      id: _toInt(json['ID'] ?? json['id']),
      accountId: _toInt(json['account_id'] ?? json['user_id']),
      amount: _toDouble(json['amount'] ?? json['nominal']),
      type: isCredit ? TransactionType.credit : TransactionType.debit,
      description: description,
      balanceBefore: _toDouble(json['balance_before'] ?? json['saldo_sebelum']),
      balanceAfter: _toDouble(json['balance_after'] ?? json['saldo_sesudah'] ?? json['sisa_saldo']),
      createdAt:
          DateTime.tryParse((json['CreatedAt'] ?? json['created_at'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _labelFromType(String type) {
    return switch (type) {
      'topup' || 'top up' => 'Top up saldo',
      'transfer' => 'Transfer saldo',
      'payment' || 'bayar' => 'Pembayaran',
      'pulsa' => 'Pembelian pulsa',
      _ => 'Transaksi',
    };
  }
}
