import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/flag_report_service.dart';

class FlagReportDialog extends StatefulWidget {
  final String reportId;
  final VoidCallback? onSuccess;

  const FlagReportDialog({super.key, required this.reportId, this.onSuccess});

  @override
  State<FlagReportDialog> createState() => _FlagReportDialogState();
}

class _FlagReportDialogState extends State<FlagReportDialog> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitFlag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await FlagReportService.flagReport(
        reportId: widget.reportId,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        image: _selectedImage,
      );

      if (result['success']) {
        _showSnackBar('Report flagged successfully', isError: false);
        widget.onSuccess?.call();
        Navigator.of(context).pop();
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      _showSnackBar('Error flagging report: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: screenWidth * 0.9,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag, color: Colors.red[600], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Flag Report',
                    style: AppFonts.bold18().copyWith(color: Colors.red[700]),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: Colors.grey[600], size: 24),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why are you flagging this report?',
                        style: AppFonts.semiBold16(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide details about why you believe this report is incorrect or inappropriate.',
                        style: AppFonts.regular14().copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subject Field
                      Text('Subject*', style: AppFonts.semiBold14()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          hintText: 'Brief description of the issue',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Subject is required';
                          }
                          if (value.trim().length < 5) {
                            return 'Subject must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description Field
                      Text('Description*', style: AppFonts.semiBold14()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Provide detailed explanation...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          if (value.trim().length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Image Section
                      // Text(
                      //   'Evidence Photo (Optional)',
                      //   style: AppFonts.semiBold14(),
                      // ),
                      // const SizedBox(height: 8),
                      // if (_selectedImage != null) ...[
                      //   Container(
                      //     width: double.infinity,
                      //     height: 200,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(12),
                      //       border: Border.all(color: Colors.grey[300]!),
                      //     ),
                      //     child: ClipRRect(
                      //       borderRadius: BorderRadius.circular(12),
                      //       child: Stack(
                      //         children: [
                      //           Image.file(
                      //             _selectedImage!,
                      //             width: double.infinity,
                      //             height: double.infinity,
                      //             fit: BoxFit.cover,
                      //           ),
                      //           Positioned(
                      //             top: 8,
                      //             right: 8,
                      //             child: GestureDetector(
                      //               onTap: () {
                      //                 setState(() {
                      //                   _selectedImage = null;
                      //                 });
                      //               },
                      //               child: Container(
                      //                 padding: const EdgeInsets.all(4),
                      //                 decoration: BoxDecoration(
                      //                   color: Colors.black.withOpacity(0.6),
                      //                   shape: BoxShape.circle,
                      //                 ),
                      //                 child: const Icon(
                      //                   Icons.close,
                      //                   color: Colors.white,
                      //                   size: 16,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      //   const SizedBox(height: 12),
                      // ],
                      // GestureDetector(
                      //   onTap: _showImageSourceDialog,
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 50,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(12),
                      //       border: Border.all(
                      //         color: AppColors.primary,
                      //         style: BorderStyle.solid,
                      //       ),
                      //       color: AppColors.primary.withOpacity(0.05),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Icon(
                      //           _selectedImage != null
                      //               ? Icons.edit_document
                      //               : Icons.add_photo_alternate,
                      //           color: AppColors.primary,
                      //           size: 20,
                      //         ),
                      //         const SizedBox(width: 8),
                      //         Text(
                      //           _selectedImage != null
                      //               ? 'Change Photo'
                      //               : 'Add Photo',
                      //           style: AppFonts.semiBold14().copyWith(
                      //             color: AppColors.primary,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppFonts.semiBold14().copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFlag,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Submit Flag',
                                style: AppFonts.semiBold14().copyWith(
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
