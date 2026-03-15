import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/client_model.dart';

class AuthService extends ChangeNotifier {
  
  final FirebaseFirestore _db   = FirebaseFirestore.instance;

  Client? _client;
  bool    _isAdmin  = false;
  bool    _loading  = false;
  String? _error;

  Client? get client   => _client;
  bool    get isAdmin  => _isAdmin;
  bool    get loading  => _loading;
  String? get error    => _error;
  bool    get loggedIn => _client != null || _isAdmin;

  // ── Client login (email + password stored in Firestore) ──
  Future<bool> loginClient(String email, String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      // Query Firestore for client with matching email
      final snap = await _db
          .collection('clients')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _error = 'No account found with that email.';
        _loading = false;
        notifyListeners();
        return false;
      }

      final doc  = snap.docs.first;
      final data = doc.data();

      if (data['password'] != password.trim()) {
        _error = 'Incorrect password.';
        _loading = false;
        notifyListeners();
        return false;
      }

      _client  = Client.fromFirestore(doc);
      _isAdmin = false;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error   = 'Login failed. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Admin login ───────────────────────────────────────────
  Future<bool> loginAdmin(String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final doc = await _db.collection('config').doc('admin').get();
      final correct = doc.data()?['password'] ?? 'admin2026';

      if (password.trim() == correct) {
        _isAdmin = true;
        _client  = null;
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error   = 'Invalid admin password.';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Fallback hardcoded
      if (password.trim() == 'admin2026') {
        _isAdmin = true;
        _loading = false;
        notifyListeners();
        return true;
      }
      _error   = 'Admin login failed.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _client  = null;
    _isAdmin = false;
    _error   = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// ── Firestore Data Service ────────────────────────────────
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Clients ───────────────────────────────────────────────
  Stream<List<Client>> streamAllClients() {
    return _db.collection('clients').snapshots().map(
      (snap) => snap.docs.map((d) => Client.fromFirestore(d)).toList(),
    );
  }

  Stream<Client?> streamClient(String docId) {
    return _db.collection('clients').doc(docId).snapshots().map(
      (doc) => doc.exists ? Client.fromFirestore(doc) : null,
    );
  }

  Future<Client?> getClientByEmail(String email) async {
    final snap = await _db
        .collection('clients')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Client.fromFirestore(snap.docs.first);
  }

  // ── Messages ──────────────────────────────────────────────
  Future<void> sendMessage({
    required String clientDocId,
    required String from,
    required String text,
  }) async {
    final docRef = _db.collection('clients').doc(clientDocId);
    final now    = DateTime.now();
    final timeStr = '${_monthName(now.month)} ${now.day}, ${now.year} · '
        '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')} '
        '${now.hour < 12 ? 'AM' : 'PM'}';

    final newMsg = {
      'id':   'm${now.millisecondsSinceEpoch}',
      'from': from,
      'text': text.trim(),
      'time': timeStr,
    };

    await docRef.update({
      'messages': FieldValue.arrayUnion([newMsg]),
    });
  }

  // ── Trades ────────────────────────────────────────────────
  Future<void> addTrade({
    required String clientDocId,
    required Map<String, dynamic> trade,
  }) async {
    await _db.collection('clients').doc(clientDocId).update({
      'trades': FieldValue.arrayUnion([trade]),
    });
  }

  // ── Admin helpers ─────────────────────────────────────────
  Future<List<Client>> getAllClients() async {
    final snap = await _db.collection('clients').get();
    return snap.docs.map((d) => Client.fromFirestore(d)).toList();
  }

  String _monthName(int m) {
    const names = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[m];
  }
}
