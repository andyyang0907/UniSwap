import 'package:uuid/uuid.dart';

enum TransactionStatus {
  pendingResponse,
  pendingAppointment,
  appointed,
  inProgress,
  completed,
  cancelled,
}

class TransactionIntent {
  final String id;
  final String productId;
  final String productTitle;
  final String productImage;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String message;
  final String? swapOffer;
  final TransactionStatus status;
  final DateTime createdAt;
  final Appointment? appointment;

  TransactionIntent({
    String? id,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.message,
    this.swapOffer,
    this.status = TransactionStatus.pendingResponse,
    DateTime? createdAt,
    this.appointment,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TransactionIntent copyWith({
    TransactionStatus? status,
    Appointment? appointment,
  }) {
    return TransactionIntent(
      id: id,
      productId: productId,
      productTitle: productTitle,
      productImage: productImage,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toUserId: toUserId,
      toUserName: toUserName,
      message: message,
      swapOffer: swapOffer,
      status: status ?? this.status,
      createdAt: createdAt,
      appointment: appointment ?? this.appointment,
    );
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pendingResponse:
        return '待回应';
      case TransactionStatus.pendingAppointment:
        return '待确认预约';
      case TransactionStatus.appointed:
        return '已预约';
      case TransactionStatus.inProgress:
        return '交易进行中';
      case TransactionStatus.completed:
        return '已完成';
      case TransactionStatus.cancelled:
        return '已取消';
    }
  }
}

class Appointment {
  final String location;
  final DateTime date;
  final String timeSlot;
  final String note;

  Appointment({
    required this.location,
    required this.date,
    required this.timeSlot,
    this.note = '',
  });
}
