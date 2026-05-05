import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'sessions/presentation/cubit/doctor_sessions_cubit.dart';
import 'sessions/presentation/cubit/doctor_sessions_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});
  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _patientIdController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  PlatformFile? _selectedPlatformFile;
  XFile? _selectedImageOrVideo;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = "Chat";

  String? get _selectedFilePath => _selectedPlatformFile?.path ?? _selectedImageOrVideo?.path;
  String? get _selectedFileName => _selectedPlatformFile?.name ?? _selectedImageOrVideo?.name;

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientIdController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickFile() async {
    if (_selectedType == "PDF") {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) setState(() { _selectedPlatformFile = result.files.first; _selectedImageOrVideo = null; });
    } else if (_selectedType == "Audio") {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null) setState(() { _selectedPlatformFile = result.files.first; _selectedImageOrVideo = null; });
    } else if (_selectedType == "Video") {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null) setState(() { _selectedImageOrVideo = file; _selectedPlatformFile = null; });
    } else {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) setState(() { _selectedImageOrVideo = file; _selectedPlatformFile = null; });
    }
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final scheduledAt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
          _selectedTime.hour, _selectedTime.minute);
      context.read<DoctorSessionsCubit>().createSession(
        patientName: _patientNameController.text.trim(),
        patientId: int.tryParse(_patientIdController.text.trim()) ?? 1,
        sessionType: _selectedType,
        scheduledAt: scheduledAt,
        price: double.tryParse(_priceController.text.trim()),
        filePath: _selectedFilePath,
      );
    }
  }

  String _getFileLabel(AppLocalizations l10n) {
    switch (_selectedType) {
      case "Video": return "Video File";
      case "Audio": return "Audio File";
      case "PDF": return "PDF Document";
      default: return "Chat Image";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BlocListener<DoctorSessionsCubit, DoctorSessionsState>(
      listener: (context, state) {
        if (state is DoctorSessionCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.sessionAdded), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is DoctorSessionCreateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F6FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/name.png', height: 35, fit: BoxFit.contain),
                      Container(
                        height: 38, width: 38,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF0EA5E9), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.addSessionTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEDEFF3), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.patientName,
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildInputField(controller: _patientNameController, hint: l10n.enterPatientName, l10n: l10n),
                        const SizedBox(height: 20),
                        Text(l10n.patientId,
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildInputField(controller: _patientIdController, hint: l10n.enterPatientId, keyboardType: TextInputType.number, l10n: l10n),
                        const SizedBox(height: 20),
                        Text(l10n.sessionType,
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Row(children: [
                          _sessionTypeButton("Chat"),
                          const SizedBox(width: 8),
                          _sessionTypeButton("Video"),
                          const SizedBox(width: 8),
                          _sessionTypeButton("Audio"),
                          const SizedBox(width: 8),
                          _sessionTypeButton("PDF"),
                        ]),
                        const SizedBox(height: 20),
                        Text(_getFileLabel(l10n),
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildPickerField(
                          text: _selectedFileName ?? "Upload ${_getFileLabel(l10n).toLowerCase()}",
                          onTap: _pickFile,
                        ),
                        const SizedBox(height: 20),
                        Text(l10n.price,
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildInputField(
                            controller: _priceController, hint: l10n.enterPrice,
                            keyboardType: TextInputType.number, l10n: l10n),
                        const SizedBox(height: 20),
                        Text(l10n.date,
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildPickerField(
                          text: "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          onTap: _selectDate,
                        ),
                        const SizedBox(height: 20),
                        Text(l10n.time,
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildPickerField(text: _selectedTime.format(context), onTap: _selectTime),
                        const SizedBox(height: 30),
                        Center(
                          child: BlocBuilder<DoctorSessionsCubit, DoctorSessionsState>(
                            builder: (context, state) {
                              final isLoading = state is DoctorSessionCreating;
                              return SizedBox(
                                width: 160, height: 45,
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : _saveSession,
                                  icon: isLoading
                                      ? const SizedBox(height: 18, width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.add, size: 18),
                                  label: Text(isLoading ? l10n.saving : l10n.add,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0EA5E9),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    TextEditingController? controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    required AppLocalizations l10n,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPickerField({required String text, required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Text(text, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _sessionTypeButton(String text) {
    final bool isSelected = _selectedType == text;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedType = text;
          _selectedPlatformFile = null;
          _selectedImageOrVideo = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0EA5E9) : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black54),
                  fontWeight: FontWeight.w500, fontSize: 12)),
        ),
      ),
    );
  }
}
