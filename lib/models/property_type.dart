class PropertyType {
  final String name;
  final List<String> unitTypes;

  const PropertyType({required this.name, required this.unitTypes});

  static List<PropertyType> get types => [
        const PropertyType(
          name: 'Residential',
          unitTypes: [
            'Single Room',
            'Bedsitter',
            '1 Bedroom',
            '2 Bedroom',
            '3 Bedroom',
            '4 Bedroom',
            '5 Bedroom',
            '6 Bedroom',
            'Bungalow',
          ],
        ),
        const PropertyType(
          name: 'Commercial',
          unitTypes: [
            'Shop',
            'Office Space',
            'Restaurant',
            'Hotel Room',
            'Mall Space',
          ],
        ),
        const PropertyType(
          name: 'Industrial',
          unitTypes: [
            'Godown',
            'Factory Space',
            'Warehouse',
            'Workshop',
          ],
        ),
        const PropertyType(
          name: 'Mixed Use',
          unitTypes: [
            'Shop + Residential',
            'Office + Residential',
            'Mall + Hotel',
          ],
        ),
      ];

  @override
  String toString() => name;

  static PropertyType fromString(String name) {
    return types.firstWhere(
      (type) => type.name == name,
      orElse: () => throw Exception('Invalid property type: $name'),
    );
  }
}
