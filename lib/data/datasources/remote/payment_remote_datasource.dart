import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/payment_result_entity.dart';

abstract class PaymentRemoteDatasource {
  Future<({double balance, double amount})> topup(double amount);
  Future<TransferResultEntity> transfer({
    required double amount,
    required String description,
    required String otpCode,
    required String otpType,
  });
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final ApiClient _client;
  PaymentRemoteDatasourceImpl(this._client);

  @override
  Future<({double balance, double amount})> topup(double amount) async {
    final response = await _client.post(ApiEndpoints.topup, data: {'amount': amount});
    final data = response['data'] as Map<String, dynamic>;
    return (
      balance: (data['sisa_saldo'] as num).toDouble(),
      amount: amount,
    );
  }

  @override
  Future<TransferResultEntity> transfer({
    required double amount,
    required String description,
    required String otpCode,
    required String otpType,
  }) async {
    final response = await _client.post(ApiEndpoints.transfer, data: {
      'amount': amount,
      'order_id': description,
      // Kirim PIN/OTP ke backend untuk validasi keamanan
      if (otpCode.isNotEmpty) 'pin': otpCode,
      if (otpType.isNotEmpty) 'otp_type': otpType,
    });

    final data = response['data'] as Map<String, dynamic>;

    // Parse transaction ID dari berbagai kemungkinan field backend PHP
    // Backend mungkin menggunakan nama field yang berbeda
    final rawId = data['id']
        ?? data['transaction_id']
        ?? data['id_transaksi']
        ?? data['trx_id'];

    // Jika backend tidak mengembalikan ID, buat ID unik berbasis timestamp
    final String transactionId = rawId != null
        ? rawId.toString()
        : DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    // Parse saldo sebelum (jika ada di response)
    final double balanceBefore = (data['saldo_sebelum'] as num?)?.toDouble()
        ?? (data['balance_before'] as num?)?.toDouble()
        ?? 0.0;

    return TransferResultEntity(
      transactionId: transactionId,
      amount: amount,
      description: 'Pembayaran order ${data['order_id'] ?? description}',
      balanceBefore: balanceBefore,
      balanceAfter: (data['sisa_saldo'] as num).toDouble(),
      createdAt: DateTime.now(),
    );
  }
}
