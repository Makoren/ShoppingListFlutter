class Item {
  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    this.section,
    this.isCompleted = false,
    this.isMarkedForGenerate = false,
  });

  String description;
  int id;
  bool isCompleted;
  bool isMarkedForGenerate;
  String name;
  int quantity;
  String? section;

  /// Creates a copy of the item. Any arguments given will override the existing property.
  ///
  /// This is useful if you have two very similar items, but you don't want to write all the properties again.
  Item copyWith({
    int? id,
    String? name,
    String? description,
    int? quantity,
    String? section,
    bool? isCompleted,
    bool? isMarkedForGenerate,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      section: section ?? this.section,
      isCompleted: isCompleted ?? this.isCompleted,
      isMarkedForGenerate: isMarkedForGenerate ?? this.isMarkedForGenerate,
    );
  }

  /// Converts a map into an item. Throws an exception if the map can't be converted.
  static Item fromMap(Map<String, Object?> map) {
    try {
      return Item(
        id: map['id'] as int,
        name: map['name'].toString(),
        description: map['description'].toString(),
        quantity: map['quantity'] as int,
        section: map['section']?.toString().toLowerCase(),
        isCompleted: map['isCompleted'] == 1,
        isMarkedForGenerate: map['isMarkedForGenerate'] == 1,
      );
    } catch (e) {
      throw Exception(
          'Could not convert map to Item. Double check your properties.');
    }
  }

  /// Converts an item into a map. Used for inserting into a database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'section': section?.toLowerCase(),
      'isCompleted': isCompleted ? 1 : 0,
      'isMarkedForGenerate': isMarkedForGenerate ? 1 : 0,
    };
  }
}

// "section" should be nullable, because the string is used to find that specfic
// section in the sections list, and the items that don't have a section are
// null checked, not empty string checked.

// The sections list can't be a map because it gets plugged into a ReorderableListView.
