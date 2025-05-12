import 'package:cloud_firestore/cloud_firestore.dart';

class ContractService {
  final _contracts = FirebaseFirestore.instance.collection('contracts');

  Stream<List<Map<String, dynamic>>> getContractsByUserId(
    String userId,
    bool isClient,
  ) {
    final field = isClient ? 'clientId' : 'freelancerId';
    return _contracts
        .where(field, isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList(),
        );
  }

  Future<Map<String, dynamic>?> getContractById(String id) async {
    final doc = await _contracts.doc(id).get();
    return doc.exists ? doc.data() : null;
  }
}
