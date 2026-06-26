import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.balance,
    required super.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: (json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] as num?)?.toInt() ?? 0),
      userId: (json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] as num?)?.toInt() ?? 0),
      balance: (json['saldo'] as num?)?.toDouble() ?? (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
