import 'dart:ui' show Color;

class Section {
  Section({
    required this.id,
    required this.title,
    required this.color,
  });

  Color color;
  int id;
  String title;

  static Section fromMap(Map<String, Object?> map) {
    try {
      return Section(
        id: map['id'] as int,
        title: map['title'].toString(),
        color: Color(map['color'] as int),
      );
    } catch (e) {
      throw Exception(
          'Could not convert map to Section. Double check your properties.');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title.toLowerCase(),
      'color': color.value,
    };
  }
}
