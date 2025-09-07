import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeamSelectionDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const TeamSelectionDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<TeamSelectionDialog> createState() => _TeamSelectionDialogState();
}

class _TeamSelectionDialogState extends State<TeamSelectionDialog> {
  bool _isKeyboardVisible = false;
  final _nameController = TextEditingController();
  int selectedTeam = 0; // 0 = no selection, 1 = Team 1, 2 = Team 2
  bool _nameEntered = false;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = keyboardHeight > 0;

    return AnimatedAlign(
      duration: Duration(milliseconds: 300), // Smooth animation
      curve: Curves.easeInOut, // Nice easing curve

      alignment: _isKeyboardVisible ? Alignment.topCenter : Alignment.center,

      child: Dialog(
        alignment: _isKeyboardVisible ? Alignment.topCenter : Alignment.center,
        insetPadding:
            _isKeyboardVisible
                ? EdgeInsets.only(top: 0.h, left: 20.w, right: 20.w)
                : EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),

        backgroundColor: const Color(0xFFF7F7F7),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                'Join Team',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.h),

              // Team Selection Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Your Team',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Custom Team Selection Cards
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTeam = 1;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: selectedTeam == 1 ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color:
                                selectedTeam == 1
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow:
                              selectedTeam == 1
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 32.sp,
                              color:
                                  selectedTeam == 1
                                      ? Colors.white
                                      : Colors.blue,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Team 1',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    selectedTeam == 1
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTeam = 2;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: selectedTeam == 2 ? Colors.red : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color:
                                selectedTeam == 2
                                    ? Colors.red
                                    : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow:
                              selectedTeam == 2
                                  ? [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 32.sp,
                              color:
                                  selectedTeam == 2 ? Colors.white : Colors.red,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Team 2',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    selectedTeam == 2
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Name Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Name',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameController,
                  onChanged: (value) {
                    setState(() {
                      _nameEntered = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                ),
              ),
              SizedBox(height: 32.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      // ? on Tap select a team which has more than 0 aka team 1 or 2
                      // * and name is entered of user in field
                      // $ then return a map with name and team number with dialog closing
                      onTap:
                          (selectedTeam > 0 && _nameEntered)
                              ? () {
                                print('🎮 DEBUG: Join button pressed!');
                                print('🎮 DEBUG: Selected team: $selectedTeam');
                                print(
                                  '🎮 DEBUG: Player name: ${_nameController.text}',
                                );

                                // ? OR do this > Pass the name and team to the callback
                                // * widget.onConfirm(_nameController.text, selectedTeam);
                                // * Navigator.of(context).pop();
                                final result = {
                                  'name': _nameController.text,
                                  'team': selectedTeam,
                                };
                                print('🎮 DEBUG: Returning result: $result');
                                Navigator.of(context).pop(result);
                              }
                              : () {
                                print(
                                  '🎮 DEBUG: Join button pressed but disabled!',
                                );
                                print(
                                  '🎮 DEBUG: selectedTeam: $selectedTeam, _nameEntered: $_nameEntered',
                                );
                                // Show feedback to user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      selectedTeam == 0
                                          ? 'Please select a team first!'
                                          : 'Please enter your name!',
                                    ),
                                    backgroundColor: Colors.orange,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color:
                              (selectedTeam > 0 && _nameEntered)
                                  ? Colors.blue
                                  : Colors.grey[400],
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow:
                              (selectedTeam > 0 && _nameEntered)
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Text(
                          'Join Team',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
