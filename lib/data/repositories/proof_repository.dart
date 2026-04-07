import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/proof_model.dart';

class ProofRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProof(ProofModel proof) async {
    await _firestore.collection('proofs').doc(proof.id).set(proof.toJson());
  }

  Stream<List<ProofModel>> streamAllProofs() {
    return _firestore
        .collection('proofs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProofModel.fromJson(d.data())).toList());
  }

  Future<ProofModel?> getProofForPost(String postId) async {
    final snapshot = await _firestore
        .collection('proofs')
        .where('postId', isEqualTo: postId)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return ProofModel.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  Stream<ProofModel?> streamProofForPost(String postId) {
    return _firestore
        .collection('proofs')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snap) {
      if (snap.docs.isNotEmpty) {
        return ProofModel.fromJson(snap.docs.first.data());
      }
      return null;
    });
  }

  Future<void> markProofConfirmed(String proofId, String blockNumber) async {
    await _firestore.collection('proofs').doc(proofId).update({
      'status': ProofStatus.confirmed.name,
      'confirmedAt': DateTime.now().toIso8601String(),
      'blockNumber': blockNumber,
    });
  }
}
