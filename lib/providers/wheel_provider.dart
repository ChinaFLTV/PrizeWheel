import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/wheel_model.dart';

class WheelProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<WheelModel> _wheels = [];
  bool _isLoading = false;
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  List<WheelModel> get wheels => _wheels;
  bool get isLoading => _isLoading;
  Set<String> get selectedIds => _selectedIds;
  bool get isSelectionMode => _isSelectionMode;

  Future<void> loadWheels() async {
    _isLoading = true;
    notifyListeners();
    try {
      _wheels = await _db.getAllWheels();
    } catch (e) {
      debugPrint('Error loading wheels: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWheel(WheelModel wheel) async {
    try {
      await _db.insertWheel(wheel);
    } catch (e) {
      debugPrint('Error adding wheel: $e');
    }
    await loadWheels();
  }

  Future<void> updateWheel(WheelModel wheel) async {
    try {
      await _db.updateWheel(wheel);
    } catch (e) {
      debugPrint('Error updating wheel: $e');
    }
    await loadWheels();
  }

  Future<void> deleteWheel(String id) async {
    try {
      await _db.deleteWheel(id);
    } catch (e) {
      debugPrint('Error deleting wheel: $e');
    }
    _selectedIds.remove(id);
    await loadWheels();
  }

  Future<void> deleteSelectedWheels() async {
    if (_selectedIds.isEmpty) return;
    try {
      await _db.deleteWheels(_selectedIds.toList());
    } catch (e) {
      debugPrint('Error deleting wheels: $e');
    }
    _selectedIds.clear();
    _isSelectionMode = false;
    await loadWheels();
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    if (_selectedIds.isEmpty) {
      _isSelectionMode = false;
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.addAll(_wheels.map((w) => w.id));
    notifyListeners();
  }

  void deselectAll() {
    _selectedIds.clear();
    notifyListeners();
  }

  void enterSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();
  }
}
