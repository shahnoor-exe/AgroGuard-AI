import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadWidget extends StatefulWidget {
  const UploadWidget({Key? key}) : super(key: key);

  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _predictionResult;

  /// Pick image from device (web compatible)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = pickedFile;
          _imageBytes = imageBytes;
          _predictionResult = null;
          _isError = false;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  /// Send image to backend for disease prediction
  Future<void> _predictDisease() async {
    if (_imageBytes == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/predict'),
      );

      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _imageBytes!,
          filename: _selectedImage?.name ?? 'image.jpg',
        ),
      );

      // Send request
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw 'Request timeout - Backend server may not be running';
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        setState(() {
          _predictionResult = jsonResponse;
          _isLoading = false;
        });
      } else {
        _showError(
          'Prediction failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _showError('Error: ${e.toString()}\n\nMake sure backend is running at http://localhost:5000');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show error message
  void _showError(String message) {
    setState(() {
      _isError = true;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Disease Detection',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D822D),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a crop image for AI-powered disease prediction',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Image Preview Area
            Container(
              width: double.infinity,
              height: isMobile ? 200 : 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: _imageBytes != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                                _imageBytes = null;
                                _predictionResult = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No image selected',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Buttons (Responsive Layout)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D822D),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _predictDisease,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2D822D),
                            ),
                          ),
                        )
                      : const Icon(Icons.api),
                  label: Text(_isLoading ? 'Predicting...' : 'Predict Disease'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_isError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red[700],
                          ),
                    ),
                  ],
                ),
              ),

            // Prediction Result
            if (_predictionResult != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediction Result',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildPredictionDetails(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build prediction details display
  List<Widget> _buildPredictionDetails() {
    final List<Widget> details = [];

    _predictionResult?.forEach((key, value) {
      details.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$key:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    });

    return details;
  }
}
