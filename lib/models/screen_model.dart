import 'dart:convert';

class Screen {
  String name;
  List<Section> sections;

  Screen({required this.name, required this.sections});

  Map<String, dynamic> toJson() => {
        'name': name,
        'Sections': sections.map((e) => e.toJson()).toList(),
      };

  static Screen fromJson(Map<String, dynamic> json) => Screen(
        name: json['name'],
        sections: (json['Sections'] as List)
            .map((e) => Section.fromJson(e))
            .toList(),
      );
}

class Section {
  String name;
  String? value;
  List<Section> sections;

  Section({required this.name, this.value, required this.sections});

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'sections': sections.map((e) => e.toJson()).toList(),
      };

  static Section fromJson(Map<String, dynamic> json) => Section(
        name: json['name'],
        value: json['value'],
        sections: (json['sections'] as List)
            .map((e) => Section.fromJson(e))
            .toList(),
      );
}
