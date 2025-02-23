import 'package:flutter/material.dart';
import 'package:sdui_builder/helpers/storage_helper.dart';
import 'package:sdui_builder/helpers/widgets_data_helper.dart';
import 'package:sdui_builder/widgets/DraggableWidget.dart';
import 'package:sdui_builder/widgets/JsonTreeView.dart';
import 'package:sdui_builder/widgets/view_types.dart';
import 'dart:convert';
import 'dart:html' as html;

class CreateScreen extends StatefulWidget {
  final Map<String, dynamic>? initialJson;

  const CreateScreen({Key? key, this.initialJson}) : super(key: key);

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  late TextEditingController _screenNameController;
  late TextEditingController _screenSlugController;
  Map<String, dynamic>? selectedWidgetData = {};

  List<String> layoutSections = [
    'screen_header',
    'screen_body',
    'screen_footer'
  ];

  Map<String, dynamic> screenJson = {
    'screen_title': '',
    'slug': '',
    'screen_actions': [],
  };

  final draggableWidgets = WidgetDataHelper().getKeys();

  @override
  void initState() {
    super.initState();
    if (widget.initialJson != null) {
      screenJson['screen_title'] = widget.initialJson!['screen_title'];
      screenJson['slug'] = widget.initialJson!['slug'];
      if (widget.initialJson!.containsKey('screen_actions')) {
        screenJson['screen_actions'] = widget.initialJson!['screen_actions'];
      }
      if (widget.initialJson!.containsKey('screen_header')) {
        screenJson['screen_header'] = widget.initialJson!['screen_header'];
      }
      if (widget.initialJson!.containsKey('screen_body')) {
        screenJson['screen_body'] = widget.initialJson!['screen_body'];
      }
      if (widget.initialJson!.containsKey('screen_footer')) {
        screenJson['screen_footer'] = widget.initialJson!['screen_footer'];
      }

      _screenNameController =
          TextEditingController(text: widget.initialJson!['screen_title']);
      _screenSlugController =
          TextEditingController(text: widget.initialJson!['slug']);
    } else {
      _screenNameController = TextEditingController();
      _screenSlugController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _screenNameController.dispose();
    _screenSlugController.dispose();
    super.dispose();
  }

  /// Uploads JSON file and updates `screen_actions`
  Future<void> uploadScreenActions() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = '.json'; // Accept only JSON files
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();

        reader.readAsText(file);
        reader.onLoadEnd.listen((event) {
          try {
            final String jsonString = reader.result as String;
            final List<dynamic> jsonActions = json.decode(jsonString);

            setState(() {
              screenJson['screen_actions'] =
                  List<Map<String, dynamic>>.from(jsonActions);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Screen actions uploaded successfully!")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid JSON file.")),
            );
          }
        });
      }
    });
  }

  void addLayoutItem(Map<String, dynamic> item) {
    // add layout item only if it's not already present
    if (layoutSections.contains(item['type']) &&
        !screenJson.containsKey(item['type'])) {
      setState(() {
        Map<String, dynamic> clonedItem = deepClone(item);
        clonedItem.remove('type');
        screenJson[item['type']] = clonedItem;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'This section is already present or dropped at invalid location!'),
        ),
      );
    }
  }

  Color getBgColor(String section) {
    switch (section) {
      case 'screen_header':
        return Colors.lightBlue[50]!;
      case 'screen_body':
        return Colors.lightGreen[50]!;
      case 'screen_footer':
        return Colors.amber[50]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Map<String, dynamic> deepClone(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, deepClone(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value
              .map((item) =>
                  item is Map<String, dynamic> ? deepClone(item) : item)
              .toList(),
        );
      } else {
        return MapEntry(key, value);
      }
    });
  }

  Future<void> saveScreen() async {
    List<Map<String, dynamic>> savedScreens =
        await LocalStorageService.loadScreens();

    final existingScreenIndex = savedScreens.indexWhere(
      (screen) => screen['screen_title'] == screenJson['screen_title'],
    );

    if (existingScreenIndex != -1) {
      savedScreens[existingScreenIndex] = screenJson;
    } else {
      savedScreens.add(screenJson);
    }
    await LocalStorageService.saveScreens(savedScreens);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingScreenIndex != -1
              ? 'Screen updated successfully!'
              : 'Screen saved successfully!',
        ),
      ),
    );
    Navigator.pop(context);
  }

  void setSelectedWidget(String section, dynamic item) {
    setState(() {
      selectedWidgetData = {
        'section': section,
        'data': item,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Tooltip(
            message: 'Save Screen', // Tooltip for save icon
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                // Open modal when save icon is clicked
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:
                          const Text('Are you sure you want to save screen?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            saveScreen();
                          },
                          child: const Text('Yes, Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
        backgroundColor: const Color(0xFF689F38),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      margin: const EdgeInsets.only(right: 10),
                      child: DragTarget<Map<String, dynamic>>(
                        onAccept: (data) => addLayoutItem(deepClone(data)),
                        builder: (context, candidateData, rejectedData) =>
                            Container(
                          color: Colors.grey[100],
                          height: double.infinity,
                          child: SingleChildScrollView(
                            child: Column(
                              children: layoutSections.map((section) {
                                if (screenJson.containsKey(section)) {
                                  final item = screenJson[section];
                                  return GestureDetector(
                                    onTap: () {
                                      setSelectedWidget(section, item);
                                    },
                                    child: Container(
                                      color: Colors.blue[100],
                                      width: double.infinity,
                                      margin: const EdgeInsets.all(4),
                                      child: DroppableContainer(
                                        containerData: item,
                                        layoutname: section,
                                        onWidgetDropped: (updatedContainer) {
                                          setState(() {
                                            screenJson[section] =
                                                updatedContainer;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  //Screen, widgets configurable properties sections
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      height: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _screenNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Screen Title',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  setState(() {
                                    screenJson['screen_title'] = value;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _screenSlugController,
                                decoration: const InputDecoration(
                                  labelText: 'Slug',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  setState(() {
                                    screenJson['slug'] = value;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// **Upload Screen JSON Button**
                            ElevatedButton(
                              onPressed: uploadScreenActions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.black, width: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)), //
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Upload screen actions',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.upload_file, color: Colors.black),
                                ],
                              ),
                            ),

                            /// **Display Uploaded JSON**
                            if (screenJson['screen_actions'].isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text("Screen Actions:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              JsonTreeView(jsonData: {
                                "screen_actions": screenJson['screen_actions']
                              }),
                            ],

                            //widget level config properties**
                            if (selectedWidgetData != null &&
                                (selectedWidgetData?['data']
                                        ?.containsKey('meta_info') ??
                                    false)) ...[
                              const SizedBox(height: 10),
                              Text(
                                selectedWidgetData?['section'] ?? 'Section',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'meta_info',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        selectedWidgetData?['data']
                                                ?['meta_info']
                                            ?.add({
                                          "path": "",
                                          "path_mapping_key": ""
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: List.generate(
                                  selectedWidgetData?['data']?['meta_info']
                                          ?.length ??
                                      0,
                                  (index) => Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                              width: 80, child: Text('Path:')),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedWidgetData?['data']
                                                          ?['meta_info']?[index]
                                                      ['path'] = value;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const SizedBox(
                                              width: 80,
                                              child: Text('path_mapping_key:')),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedWidgetData?['data']
                                                                  ?['meta_info']
                                                              ?[index]
                                                          ['path_mapping_key'] =
                                                      value;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                selectedWidgetData?['data']
                                                        ?['meta_info']
                                                    ?.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                              // const SizedBox(height: 10),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     setState(() {
                              //       screenJson[selectedWidgetData?['section']] =
                              //           selectedWidgetData?['data'];
                              //     });
                              //   },
                              //   child: const Text('Save'),
                              // ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //Draggable widgets
            Expanded(
              flex: 2,
              child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: draggableWidgets
                        .map((widgetName) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: DraggableWidget(
                                  widgetName: widgetName.toString()),
                            ))
                        .toList(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class DroppableContainer extends StatelessWidget {
  final Map<String, dynamic> containerData;
  final Function(Map<String, dynamic>) onWidgetDropped;
  final String layoutname;

  Color getBgColor(String section) {
    switch (section) {
      case 'screen_header':
        return Colors.lightBlue[50]!;
      case 'screen_body':
        return Colors.lightGreen[200]!;
      case 'screen_footer':
        return Colors.amber[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  const DroppableContainer({
    Key? key,
    required this.containerData,
    required this.onWidgetDropped,
    this.layoutname = '',
  }) : super(key: key);

  Map<String, dynamic> deepClone(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, deepClone(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value
              .map((item) =>
                  item is Map<String, dynamic> ? deepClone(item) : item)
              .toList(),
        );
      } else {
        return MapEntry(key, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (data) {
        final clonedData = deepClone(data);
        if (clonedData['type'] == 'section_container') {
          clonedData.remove('type');
          containerData['section_container']['content'].add(clonedData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This section is dropped at invalid location!'),
            ),
          );
        }
        onWidgetDropped(containerData);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
            color: getBgColor(layoutname),
            padding: EdgeInsets.all(8),
            child: Column(
              children: containerData['section_container']['content']
                  .map<Widget>((section) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(4),
                  child: DroppableSectionContainer(
                    sectionContainerData: section,
                    onWidgetDropped: (updatedSection) {
                      int index = containerData['section_container']['content']
                          .indexOf(section);
                      containerData['section_container']['content'][index] =
                          updatedSection;
                      onWidgetDropped(containerData);
                    },
                  ),
                );
              }).toList(),
            ));
      },
    );
  }
}

class DroppableSectionContainer extends StatelessWidget {
  final Map<String, dynamic> sectionContainerData;
  final Function(Map<String, dynamic>) onWidgetDropped;
  final String layoutname;

  const DroppableSectionContainer({
    Key? key,
    required this.sectionContainerData,
    required this.onWidgetDropped,
    this.layoutname = '',
  }) : super(key: key);

  Map<String, dynamic> deepClone(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, deepClone(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value
              .map((item) =>
                  item is Map<String, dynamic> ? deepClone(item) : item)
              .toList(),
        );
      } else {
        return MapEntry(key, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (data) {
        final clonedData = deepClone(data);
        if (clonedData['type'] == 'sections') {
          clonedData.remove('type');
          sectionContainerData['sections']['content'].add(clonedData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This section is dropped at invalid location!'),
            ),
          );
        }
        onWidgetDropped(sectionContainerData);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
            color: Color.fromARGB(255, 153, 212, 222),
            padding: EdgeInsets.all(8),
            child: Column(
              children: sectionContainerData['sections']['content']
                  .map<Widget>((section) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(4),
                  child: DroppableSection(
                    sectionData: section,
                    onWidgetDropped: (updatedSection) {
                      int index = sectionContainerData['sections']['content']
                          .indexOf(section);
                      sectionContainerData['sections']['content'][index] =
                          updatedSection;
                      onWidgetDropped(sectionContainerData);
                    },
                  ),
                );
              }).toList(),
            ));
      },
    );
  }
}

class DroppableSection extends StatelessWidget {
  final Map<String, dynamic> sectionData;
  final Function(Map<String, dynamic>) onWidgetDropped;
  final String layoutname;
  List<String> structureSections = [
    'screen_header',
    'screen_body',
    'screen_footer',
    'section_container',
    'sections',
  ];

  DroppableSection({
    Key? key,
    required this.sectionData,
    required this.onWidgetDropped,
    this.layoutname = '',
  }) : super(key: key);

  Map<String, dynamic> deepClone(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, deepClone(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value
              .map((item) =>
                  item is Map<String, dynamic> ? deepClone(item) : item)
              .toList(),
        );
      } else {
        return MapEntry(key, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (data) {
        if (structureSections.contains(data['type'])) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'This section is dropped at invalid location. Please drop a widget!'),
            ),
          );
          return;
        }
        final clonedData = deepClone(data);
        sectionData['section_child']['content'].add(clonedData);
        onWidgetDropped(sectionData);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
            color: Color.fromARGB(255, 88, 84, 130),
            padding: EdgeInsets.all(8),
            child: Column(
              children: sectionData['section_child']['content']
                  .map<Widget>((section) {
                final widget = ViewTypeFactory.getWidget(
                  section,
                );
                return Container(
                  padding: EdgeInsets.all(4),
                  child: widget ?? const SizedBox.shrink(),
                );
              }).toList(),
            ));
      },
    );
  }
}
