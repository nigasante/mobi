import 'package:flutter/material.dart';
import 'models/article.dart';
import 'category.dart';
import 'dart:convert';
import 'dart:io';
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
  String? _titleError;
  String? _contentError;

  static const bannedWords = [
    'fuck', 'shit', 'bitch', 'asshole', 'dumb', 'stupid', 'crap', 'idiot', 'moron', 'damn',
    'suck', 'freak', 'jerk', 'piss', 'bastard', 'retard', 'dick', 'cock', 'pussy', 'slut',
    'whore', 'fucked up', 'screwed', 'screw you', 'motherfucker', 'bullshit', 'son of a bitch',
    'douche', 'douchebag', 'wtf', 'wth', 'omg', 'lmao', 'rofl', 'lol', 'brb', 'btw', 'fml',
    'idk', "ain't", 'gonna', 'wanna', "y'all", 'yo', 'nah', 'uh-huh', 'meh', 'ugh', 'ew',
    'huh', 'uh-oh', 'nope', 'yup', 'hell yeah', 'hell no', 'bloody', 'goddamn', 'jackass',
    'tool', 'twat', 'arse', 'shithead', 'nuts', 'crappy', 'sucky', 'screwed up', 'freaking',
    'fricking', "freakin'", "friggin'", 'darn', 'dang', 'dipshit', 'shitface', 'shitshow',
    'numbnuts', 'shitstorm', 'pissed off', 'screw it', 'shut up', 'bite me', 'go to hell',
    'buzz off', 'duh', 'troll', 'cringey', 'cringe', 'creep', 'loser', 'psycho', 'crazy',
    'insane', 'bonkers', 'fatass', 'lazy', 'lame', 'savage', 'lit', 'dope', 'sus', 'cap',
    'no cap', 'bet', 'salty', 'thirsty', 'lowkey', 'highkey', 'flex', 'clout', 'Karen',
    'tool', 'boomer', 'fugly', 'buttface', 'nasty', 'gross', 'ugh', 'eww', 'effed up',
    'n00b', 'rekt', 'gg ez', 'yeet', 'smh', 'tbh', 'IDC', 'get lost', 'get a life',
    'shut your mouth', 'zip it', 'wack', 'weak sauce', 'shitless', 'arsehole', 'arsewipe',
    'twatwaffle', 'dumbass', 'shitbag', 'fubar', 'clusterfuck', 'facepalm', 'dumbfuck',
    'jerkwad', 'bitchy', 'asshat', 'fuckwad', 'shitload', 'crapload', 'cocky'
  ];

  List<String> _findBannedWords(String text) {
    text = text.toLowerCase();
    return bannedWords.where((word) => text.contains(word.toLowerCase())).toList();
  }

  void _validateText() {
    final titleBannedWords = _findBannedWords(_titleController.text);
    final contentBannedWords = _findBannedWords(_contentController.text);

    setState(() {
      _titleError = titleBannedWords.isNotEmpty
          ? 'Title contains banned words: ${titleBannedWords.join(", ")}'
          : null;
      _contentError = contentBannedWords.isNotEmpty
          ? 'Content contains banned words: ${contentBannedWords.join(", ")}'
          : null;
    });
  }
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadedImageUrl;
  String? _previewImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _status = widget.article!.status;
      _selectedCategoryIds = List<int>.from(widget.article!.categoryID ?? []);
      _uploadedImageUrl = widget.article!.imageUrl;
      _previewImageUrl = widget.article!.imageUrl;
      
      // Check for banned words in existing article
      _validateText();
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
        _previewImageUrl = image.path;
        _uploadedImageUrl = null; // Reset this when new image is selected
      });
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  Future<void> _submitArticle() async {
    // First validate the text
    _validateText();
    
    if (_titleError != null || _contentError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please remove inappropriate language before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

    setState(() => _isUploading = true);

    try {
      // Handle image upload
      if (_imageFile != null) {
        print('Uploading image to Cloudinary...');
        _uploadedImageUrl = await CloudinaryService.uploadImage(_imageFile!);

        if (_uploadedImageUrl == null) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
          return;
        }
        print('Image uploaded successfully: $_uploadedImageUrl');
      }

      // Prepare article data
      final requestBody = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'editorID': widget.editorId,
        'status': _status,
        'publishDate': DateTime.now().toIso8601String(),
        'categoryIDs': _selectedCategoryIds,
        'imageUrl':
            _uploadedImageUrl ??
            widget.article?.imageUrl, // Use existing URL if no new image
      };

      // Send to your API
      final url = widget.article == null
          ? 'http://10.0.2.2:5264/api/articles'
          : 'http://10.0.2.2:5264/api/articles/${widget.article!.articleID}';

      final response = widget.article == null
          ? await http.post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestBody),
            )
          : await http.put(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestBody),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true); // Return true to trigger refresh
      } else {
        throw Exception('Failed to save article: ${response.body}');
      }
    } catch (e) {
      print('Error saving article: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving article: $e')));
    } finally {
      setState(() => _isUploading = false);
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
                if (_previewImageUrl != null)
                  _imageFile != null
                      ? Image.file(File(_previewImageUrl!), fit: BoxFit.cover)
                      : Image.network(
                          _previewImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
          decoration: InputDecoration(
            labelText: 'Title',
            errorText: _titleError,
          ),
          onChanged: (text) => _validateText(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _contentController,
          decoration: InputDecoration(
            labelText: 'Content',
            errorText: _contentError,
          ),
          onChanged: (text) => _validateText(),
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
