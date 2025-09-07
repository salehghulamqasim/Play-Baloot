import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart'; // Added for haptic feedback

// Your existing FormLabeledField class
class FormLabeledField extends StatelessWidget {
  final String label;
  final String? hintOrValue;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool isRequired;

  const FormLabeledField({
    super.key,
    required this.label,
    this.hintOrValue,
    this.controller,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    required this.isRequired,
    this.onChanged,
  });

  InputDecoration get _decoration => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF7F7F7),
    hintText: hintOrValue,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: Color(0xFF007AFF)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            isRequired ? '$label *' : label, // Added asterisk if required
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
        onTap != null
            ? InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: onTap,
              child: IgnorePointer(
                child: TextFormField(
                  readOnly: true,
                  decoration: _decoration,
                  controller: controller,
                ),
              ),
            )
            : TextFormField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              decoration: _decoration,
              onChanged: onChanged,
            ),
      ],
    );
  }
}

// Example screen with dropdown
class DropdownExampleScreen extends StatefulWidget {
  const DropdownExampleScreen({super.key});

  @override
  State<DropdownExampleScreen> createState() => _DropdownExampleScreenState();
}

class _DropdownExampleScreenState extends State<DropdownExampleScreen> {
  String selectedValue = "30 minutes"; // Default value
  final TextEditingController dropdownController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dropdownController.text = selectedValue; // Set initial value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Example'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            FormLabeledField(
              label: "Duration",
              controller: dropdownController,
              isRequired: true,
              onTap: () => _showDurationPicker(context),
            ),
            SizedBox(height: 20.h),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    final List<String> durations = [
      "15 minutes",
      "30 minutes",
      "45 minutes",
      "1 hour",
      "1.5 hours",
      "2 hours",
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: 300.h,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Duration',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: durations.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(durations[index]),
                        trailing:
                            selectedValue == durations[index]
                                ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF007AFF),
                                )
                                : null,
                        onTap: () {
                          HapticFeedback.selectionClick(); // Added haptic feedback
                          setState(() {
                            selectedValue = durations[index];
                            dropdownController.text = selectedValue;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    dropdownController.dispose();
    super.dispose();
  }
}

//how did we add onChanged?
// first we added final ValueChanged<String>? onChanged; and then added it in constructor this.onchaged then in ui inside textfield

//dropdownfield
//create a string value dropdown and assign 30 minutes string into it .outside build method
// then build a scaffold and give it appbar and leading icon button an context navigator pop
//then create singlechild scroll
