enum ProofStatus { pending, confirmed, failed }

class ProofModel {
  final String id;
  final String postId;
  final String creatorId;
  final String fileHash;
  final String? txId;
  final String? blockNumber;
  final String? contractAddress;
  final ProofStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String networkName;
  final String? qrCodeUrl;

  const ProofModel({
    required this.id,
    required this.postId,
    required this.creatorId,
    required this.fileHash,
    this.txId,
    this.blockNumber,
    this.contractAddress,
    this.status = ProofStatus.pending,
    required this.createdAt,
    this.confirmedAt,
    this.networkName = 'Polygon Mainnet',
    this.qrCodeUrl,
  });

  factory ProofModel.fromJson(Map<String, dynamic> json) {
    return ProofModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      creatorId: json['creatorId'] as String,
      fileHash: json['fileHash'] as String,
      txId: json['txId'] as String?,
      blockNumber: json['blockNumber'] as String?,
      contractAddress: json['contractAddress'] as String?,
      status: ProofStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProofStatus.pending,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      networkName: json['networkName'] as String? ?? 'Polygon Mainnet',
      qrCodeUrl: json['qrCodeUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'creatorId': creatorId,
      'fileHash': fileHash,
      'txId': txId,
      'blockNumber': blockNumber,
      'contractAddress': contractAddress,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'networkName': networkName,
      'qrCodeUrl': qrCodeUrl,
    };
  }
}
