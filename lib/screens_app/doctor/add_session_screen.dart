import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sessions/presentation/cubit/doctor_sessions_cubit.dart';
import 'sessions/presentation/cubit/doctor_sessions_state.dart';
import 'package:image_picker/image_picker.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = "Chat";

  @override
  void dispose() {
    _patientNameController.dispose();
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickFile() async {
    final XFile? file = _selectedType == "Video"
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      // Combine Date + Time into ISO DateTime
      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      context.read<DoctorSessionsCubit>().createSession(
        patientName: _patientNameController.text.trim(),
        sessionType: _selectedType,
        scheduledAt: scheduledAt,
        price: double.tryParse(_priceController.text.trim()),
        filePath: _selectedFile?.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorSessionsCubit, DoctorSessionsState>(
      listener: (context, state) {
        if (state is DoctorSessionCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is DoctorSessionCreateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
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
                      /// Logo
                      Image.asset(
                        'assets/images/name.png',
                        height: 35,
                        fit: BoxFit.contain,
                      ),

                      /// Back Button
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF0EA5E9),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Add Session',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEFF3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Patient Name
                        const Text(
                          'Patient Name',
                          style: TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _patientNameController,
                          hint: "enter patient name",
                        ),

                        const SizedBox(height: 20),

                        /// Session Type
                        const Text(
                          'Session Type',
                          style: TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _sessionTypeButton("Chat"),
                            const SizedBox(width: 10),
                            _sessionTypeButton("Video"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// Session File (Video/Chat)
                        Text(
                          _selectedType == "Chat" ? 'Chat File' : 'Video File',
                          style: const TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPickerField(
                          text: _selectedFile != null
                              ? _selectedFile!.name
                              : (_selectedType == "Chat"
                                    ? "upload chat screenshot/image"
                                    : "upload video file"),
                          onTap: _pickFile,
                        ),

                        const SizedBox(height: 20),

                        /// Price
                        const Text(
                          'Price',
                          style: TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _priceController,
                          hint: "enter session price",
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        /// Date
                        const Text(
                          'Date',
                          style: TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPickerField(
                          text:
                              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          onTap: _selectDate,
                        ),

                        const SizedBox(height: 20),

                        /// Time
                        const Text(
                          'Time',
                          style: TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPickerField(
                          text: _selectedTime.format(context),
                          onTap: _selectTime,
                        ),

                        const SizedBox(height: 30),

                        /// Add Button
                        Center(
                          child: SizedBox(
                            width: 160,
                            height: 45,
                            child: ElevatedButton.icon(
                              onPressed: _saveSession,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text(
                                "Add",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0EA5E9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
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
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    TextEditingController? controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _sessionTypeButton(String text) {
    final bool isSelected = _selectedType == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = text;
            _selectedFile = null; // Clear selected file when type changes
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
