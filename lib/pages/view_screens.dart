import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:html' as html;

import 'package:sdui_builder/helpers/storage_helper.dart';

class ViewScreens extends StatefulWidget {
  @override
  _ViewScreensState createState() => _ViewScreensState();
}

class _ViewScreensState extends State<ViewScreens> {
  List<Map<String, dynamic>> screens = [];

  @override
  void initState() {
    super.initState();
    loadScreens();
  }

  void loadScreens() async {
    final loadedScreens = await LocalStorageService.loadScreens();
    setState(() {
      screens = loadedScreens;
    });
  }

  void deleteScreen(int index) async {
    setState(() {
      screens.removeAt(index);
    });
    await LocalStorageService.saveScreens(screens);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screen deleted successfully!')),
    );
  }

  void showDeleteConfirmation(
      BuildContext context, String screenName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $screenName screen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Yes, Delete'),
            ),
          ],
        );
      },
    );
  }

  void showJsonModal(BuildContext context, Map<String, dynamic> screen) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Screen JSON',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Text(
                        const JsonEncoder.withIndent('  ').convert(screen),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                // Positioned Download Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        final jsonString = jsonEncode(screen);
                        final blob =
                            html.Blob([jsonString], 'application/json');
                        final url = html.Url.createObjectUrlFromBlob(blob);
                        final anchor = html.AnchorElement(href: url)
                          ..setAttribute('download', '${screen['screen_title']}.json')
                          ..click();
                        html.Url.revokeObjectUrl(url);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Download JSON',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                          const Icon(Icons.download, color: Colors.black)
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Screens',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF689F38),
      ),
      body: screens.isEmpty
          ? const Center(
              child:
                  Text('No screens available, please create/upload a screen'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: screens.asMap().entries.map((entry) {
                  final index = entry.key;
                  final screen = entry.value;

                  return _HoverableCard(
                    title: screen['screen_title'],
                    onEdit: () => Navigator.pushNamed(context, '/create',
                        arguments: screen),
                    onDelete: () => showDeleteConfirmation(
                        context, screen['screen_title'], () => deleteScreen(index)),
                    onView: () => showJsonModal(context, screen),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _HoverableCard extends StatefulWidget {
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _HoverableCard({
    Key? key,
    required this.title,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  }) : super(key: key);

  @override
  _HoverableCardState createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          color: isHovered ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isHovered ? Colors.grey.shade500 : Colors.grey.shade300,
              blurRadius: isHovered ? 12 : 6,
              spreadRadius: isHovered ? 4 : 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isHovered)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: widget.onEdit,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.remove_red_eye, color: Colors.green),
                      onPressed: widget.onView,
                      tooltip: 'View',
                    ),
                  ],
                ),
              ),
            if (!isHovered)
              Center(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
