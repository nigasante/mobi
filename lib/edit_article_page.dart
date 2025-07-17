import 'package:flutter/material.dart';
import 'home_page.dart';
import 'category.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'cloudinary_service.dart';

class EditArticlePage extends StatefulWidget {
  final Article? article;
  final int editorId;
  final List<Category> categories;

  const EditArticlePage({
    super.key,
    this.article,
    required this.editorId,
    required this.categories,
  });

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _status = 'Draft';
  List<int> _selectedCategoryIds = [];
  late XFile _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadedImageUrl;



  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _status = widget.article!.status;
      _uploadedImageUrl = widget.article!.imageUrl;
      print('Existing article image URL: ${widget.article!.imageUrl}');

      if (widget.article!.categoryID != null) {
        _selectedCategoryIds.add(widget.article!.categoryID!);
      }
    }
  }

   Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _imageFile = image;
        _isUploading = true;
      });

      final imageUrl = await CloudinaryService.uploadImage(image);

      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
          print('Image uploaded successfully, URL: $imageUrl');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process image: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  
  Future<void> _submitArticle() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty ||
        _selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields and select at least one category',
          ),
        ),
      );
      return;
    }

    try {
      final requestBody = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'editorID': widget.editorId,
        'status': _status,
        'publishDate': DateTime.now().toIso8601String(),
        'categoryIDs': _selectedCategoryIds,
        'imageUrl': _uploadedImageUrl, // Send the image URL
      };

      print('Submitting article with body: ${json.encode(requestBody)}');

      final url = widget.article == null
          ? 'http://10.0.2.2:5264/api/articles'
          : 'http://10.0.2.2:5264/api/articles/${widget.article!.articleID}';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Server response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save article: ${response.body}');
      }
    } catch (e) {
      print('Error saving article: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving article: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? 'Create Article' : 'Edit Article'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildForm(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isUploading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Uploading image...'),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                if (_uploadedImageUrl != null)
                  Image.network(
                    _uploadedImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, size: 40),
                            Text('Failed to load image'),
                          ],
                        ),
                      );
                    },
                  )
                else
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, size: 40, color: Colors.grey),
                        Text('No image selected'),
                      ],
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _pickImage,
                    child: const Icon(Icons.add_photo_alternate),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Content'),
          maxLines: 5,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _status,
          items: [
            'Draft',
            'Published',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) => setState(() => _status = val!),
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        const SizedBox(height: 10),
        _buildCategorySelector(),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        children: widget.categories.map((category) {
          final isSelected = _selectedCategoryIds.contains(category.categoryID);
          return CheckboxListTile(
            title: Text(category.name),
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected ?? false) {
                  _selectedCategoryIds.add(category.categoryID);
                } else {
                  _selectedCategoryIds.remove(category.categoryID);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitArticle,
      child: Text(widget.article == null ? 'Create' : 'Update'),
    );
  }
}
