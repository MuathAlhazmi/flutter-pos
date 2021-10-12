import 'dart:math';

// import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

class MenuSupplier {
  Menu _m = Menu();
  Menu get menu => _m;

  final MenuIO? database;

  MenuSupplier({this.database, Menu? mockMenu}) {
    _m = mockMenu ?? database?.getMenu() ?? _defaultMenu();
  }

  Dish getDish(int index) {
    return _m.elementAt(index);
  }

  /// returns null if invalid ID
  Dish? find(int id) {
    if (_m.any((d) => d.id == id)) {
      return _m.firstWhere((d) => d.id == id);
    }
    return null;
  }

  int nextID() {
    return _m.map<int>((d) => d.id).reduce(max) + 1;
  }

  Future<void>? addDish(Dish newDish) {
    assert(newDish.dish != '');
    assert(newDish.price > 0);
    assert(!_m.contains(newDish));

    _m.add(newDish);
    return database?.setMenu(_m);
  }

  Future<void>? updateDish(Dish dish) async {
    assert(dish.dish != '');
    assert(dish.price > 0);
    assert(_m.contains(dish));

    _m.set(dish);
    return database?.setMenu(_m);
  }

  Future<void>? removeDish(Dish dish) {
    assert(_m.contains(dish));

    _m.remove(dish);
    return database?.setMenu(_m);
  }
}

Menu _defaultMenu() {
  return Menu([
    Dish.fromAsset(
      0,
      'المعكرونة الصينية',
      30,
      'assets/mae-mu-en4qp-aK1h4-unsplash.jpg',
    ),
    Dish.fromAsset(
      1,
      'عصير التفاح الاخضر',
      10,
      'assets/alexander-mils-U6dWj2nhPEA-unsplash.jpg',
    ),
    Dish.fromAsset(
      2,
      'سلطة',
      15,
      'assets/yoav-aziz-AiHJiRCwB3w-unsplash.jpg',
    ),
    Dish.fromAsset(
      3,
      'الشوقان مع الفرولة',
      27,
      'assets/alex-motoc-v77vc1iAK18-unsplash.jpg',
    ),
    Dish.fromAsset(
      4,
      'الدجاج المقلي',
      60,
      'assets/lucas-andrade-3Uj0GwVmOeY-unsplash.jpg',
    ),
  ]);
}
