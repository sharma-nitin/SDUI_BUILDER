import 'dart:convert';
import 'dart:html' as html; // For file upload
import 'package:flutter/material.dart';
import 'package:sdui_builder/helpers/storage_helper.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SDUI Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF689F38),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            HoverableCard(
              title: 'Create Screen',
              onTap: () => Navigator.pushNamed(context, '/create'),
            ),
            HoverableCard(
              title: 'View Screen',
              onTap: () => Navigator.pushNamed(context, '/view'),
            ),
            HoverableCard(
              title: 'Upload Screen',
              onTap: () => _showUploadModal(context),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show modal for uploading JSON
  void _showUploadModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return UploadJsonModal();
      },
    );
  }
}

class HoverableCard extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const HoverableCard({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  _HoverableCardState createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
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
        height: 200,
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
        child: InkWell(
          onTap: widget.onTap,
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class UploadJsonModal extends StatefulWidget {
  @override
  _UploadJsonModalState createState() => _UploadJsonModalState();
}

class _UploadJsonModalState extends State<UploadJsonModal> {
  bool isFileUploaded = false;
  Map<String, dynamic>? uploadedJson;
  String? uploadedFileName;

  // Function to handle file upload
  void _handleFileUpload(html.File file) async {
    final reader = html.FileReader();
    reader.readAsText(file);
    reader.onLoadEnd.listen((e) {
      final result = reader.result as String;
      try {
        setState(() {
          uploadedJson = jsonDecode(result);
          uploadedFileName = file.name;
          isFileUploaded = true;
        });
      } catch (e) {
        setState(() {
          uploadedJson = null;
          isFileUploaded = false;
          uploadedFileName = null;
        });
      }
    });
  }

  // Function to trigger the file selection dialog
  void _triggerFileSelection() {
    final input = html.FileUploadInputElement()
      ..accept = '.json'
      ..multiple = false;

    input.click();

    input.onChange.listen((e) {
      final files = input.files;
      if (files!.isNotEmpty) {
        _handleFileUpload(files.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 400,
        height: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upload Screen',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Column(
              children: [
                ElevatedButton(
                  onPressed: _triggerFileSelection,
                  child: const Text('Select JSON File'),
                ),
                const SizedBox(height: 16),
                if (uploadedFileName != null)
                  Text(
                    'Uploaded file: $uploadedFileName',
                    style: TextStyle(fontSize: 14),
                  ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isFileUploaded
                  ? () async {
                      List<Map<String, dynamic>> savedScreens =
                          await LocalStorageService.loadScreens();
                      savedScreens.add(uploadedJson!);
                      await LocalStorageService.saveScreens(savedScreens);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/view');
                    }
                  : null,
              child: const Text('Upload JSON'),
            ),
          ],
        ),
      ),
    );
  }
}
