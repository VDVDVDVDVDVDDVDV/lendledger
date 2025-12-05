class AuditLog {
  final String id;
  final String actionType; // 'CREATE', 'UPDATE', 'DELETE'
  final String recordType; // 'LOAN', 'PAYMENT'
  final String recordId;
  final String dataSnapshot; // JSON string of the record data
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.actionType,
    required this.recordType,
    required this.recordId,
    required this.dataSnapshot,
    required this.timestamp,
  });

  // Convert AuditLog to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action_type': actionType,
      'record_type': recordType,
      'record_id': recordId,
      'data_snapshot': dataSnapshot,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create AuditLog from Map (database retrieval)
  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as String,
      actionType: map['action_type'] as String,
      recordType: map['record_type'] as String,
      recordId: map['record_id'] as String,
      dataSnapshot: map['data_snapshot'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'AuditLog{id: $id, actionType: $actionType, recordType: $recordType, timestamp: $timestamp}';
  }
}