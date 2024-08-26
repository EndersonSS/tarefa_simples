import 'package:flutter/material.dart';

class Group {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  Group({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryTitle': title,
      'color': color.value,
    };
  }

  Group addId(String id) {
    return Group(
      id: id,
      title: this.title,
      color: this.color,
      icon: Icons.abc,
    );
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
        id: map['id'],
        title: map['categoryTitle'],
        color: Color(map['color']),
        icon: Icons.abc);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
