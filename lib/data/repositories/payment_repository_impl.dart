import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/payment_result_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/remote/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource _remote;
  PaymentRepositoryImpl(this._remote);

  @override
  Future<({double balance, double amount})> topup(double amount) async {
    try {
      return await _remote.topup(amount);
    } on UnauthorizedException catch (e) {
      // Sesi expired atau token tidak valid
      throw AuthFailure(e.message, errorCode: e.errorCode);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, errorCode: e.errorCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Terjadi kesalahan saat top up.');
    }
  }

  @override
  Future<TransferResultEntity> transfer({
    required double amount,
    required String description,
    required String otpCode,
    required String otpType,
  }) async {
    try {
      return await _remote.transfer(
        amount: amount,
        description: description,
        otpCode: otpCode,
        otpType: otpType,
      );
    } on InvalidOtpException catch (e) {
      // PIN atau OTP salah
      throw InvalidOtpFailure(e.message);
    } on InsufficientBalanceException catch (e) {
      throw InsufficientBalanceFailure(
        balance: e.balance ?? 0,
        amount: e.amount ?? 0,
        message: e.message,
      );
    } on UnauthorizedException catch (e) {
      // Jika error code menunjukkan PIN salah, perlakukan sebagai InvalidOtp
      // agar UI menampilkan pesan yang tepat
      if (e.errorCode == 'INVALID_PIN' || e.errorCode == 'WRONG_PIN') {
        throw const InvalidOtpFailure('PIN yang Anda masukkan salah.');
      }
      throw AuthFailure(e.message, errorCode: e.errorCode);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, errorCode: e.errorCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Terjadi kesalahan saat memproses transaksi.');
    }
  }
}
