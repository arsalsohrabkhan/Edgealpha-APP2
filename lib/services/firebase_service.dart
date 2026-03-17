import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/client_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Client? _client;
  bool    _isAdmin = false;
  bool    _loading = false;
  String? _error;

  Client? get client   => _client;
  bool    get isAdmin  => _isAdmin;
  bool    get loading  => _loading;
  String? get error    => _error;
  bool    get loggedIn => _client != null || _isAdmin;

  // ── Client login — password always from Firestore clients collection ──
  Future<bool> loginClient(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final snap = await _db
          .collection('clients')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _error = 'No account found with that email.';
        _loading = false; notifyListeners(); return false;
      }

      final doc  = snap.docs.first;
      final data = doc.data();

      if (data['password'] != password.trim()) {
        _error = 'Incorrect password.';
        _loading = false; notifyListeners(); return false;
      }

      _client  = Client.fromFirestore(doc);
      _isAdmin = false;
      _loading = false; notifyListeners(); return true;

    } catch (e) {
      _error = 'Connection error. Check your internet and try again.';
      _loading = false; notifyListeners(); return false;
    }
  }

  // ── Admin login — password ONLY from Firestore settings/admin ──
  Future<bool> loginAdmin(String password) async {
    _loading = true; _error = null; notifyListeners();

    final entered = password.trim();

    if (entered.isEmpty) {
      _error = 'Please enter the admin password.';
      _loading = false; notifyListeners(); return false;
    }

    try {
      final doc = await _db
          .collection('settings')
          .doc('admin')
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        _error = 'Admin config not found. Contact support.';
        _loading = false; notifyListeners(); return false;
      }

      final correct = (doc.data()?['password'] ?? '').toString().trim();

      if (entered == correct) {
        _isAdmin = true; _client = null;
        _loading = false; notifyListeners(); return true;
      }

      _error = 'Wrong admin password.';
      _loading = false; notifyListeners(); return false;

    } catch (e) {
      _error = 'Connection error. Check your internet and try again.';
      _loading = false; notifyListeners(); return false;
    }
  }

  void logout() {
    _client = null; _isAdmin = false; _error = null;
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}

// ── Firestore Data Service ────────────────────────────────
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Client>> streamAllClients() => _db
      .collection('clients')
      .snapshots()
      .map((s) => s.docs.map((d) => Client.fromFirestore(d)).toList());

  Stream<Client?> streamClient(String docId) => _db
      .collection('clients')
      .doc(docId)
      .snapshots()
      .map((d) => d.exists ? Client.fromFirestore(d) : null);

  Future<Client?> getClientByEmail(String email) async {
    final snap = await _db
        .collection('clients')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Client.fromFirestore(snap.docs.first);
  }

  Future<void> sendMessage({
    required String clientDocId,
    required String from,
    required String text,
  }) async {
    final now = DateTime.now();
    const months = ['','Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour  = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ampm  = now.hour < 12 ? 'AM' : 'PM';
    final timeStr = '${months[now.month]} ${now.day}, ${now.year} · '
        '${hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')} $ampm';

    final newMsg = {
      'id':   'm${now.millisecondsSinceEpoch}',
      'from': from,
      'text': text.trim(),
      'time': timeStr,
    };

    await _db.collection('clients').doc(clientDocId).update({
      'messages': FieldValue.arrayUnion([newMsg]),
    });
  }

  Future<void> addTrade({
    required String clientDocId,
    required Map<String, dynamic> trade,
  }) async {
    await _db.collection('clients').doc(clientDocId).update({
      'trades': FieldValue.arrayUnion([trade]),
    });
  }

  Future<List<Client>> getAllClients() async {
    final snap = await _db.collection('clients').get();
    return snap.docs.map((d) => Client.fromFirestore(d)).toList();
  }
}
