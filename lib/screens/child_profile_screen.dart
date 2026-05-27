import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class ChildProfileScreen extends StatefulWidget {
  final int parentId;
  const ChildProfileScreen({super.key, required this.parentId});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {

  final nameController = TextEditingController();
  int selectedAge = 3;
  int selectedAvatar = 1;
  List<String> selectedInterests = [];
  bool isLoading = false;
  String errorMessage = '';

  // Avatar options — emoji icons for children
  final List<String> avatars = ['🐶', '🐱', '🐻', '🦁', '🐸', '🦊'];

  // Interest options
  final List<Map<String, String>> interests = [
    {'icon': '🐾', 'label': 'Animals'},
    {'icon': '🎨', 'label': 'Art'},
    {'icon': '🔢', 'label': 'Numbers'},
    {'icon': '🌿', 'label': 'Nature'},
    {'icon': '🎵', 'label': 'Music'},
    {'icon': '📖', 'label': 'Stories'},
    {'icon': '🚀', 'label': 'Science'},
    {'icon': '🏃', 'label': 'Sports'},
  ];

  Future<void> handleSave() async {
    if (nameController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter child name');
      return;
    }
    if (selectedInterests.isEmpty) {
      setState(() => errorMessage = 'Please select at least one interest');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final result = await ApiService.addChild(
      parentId: widget.parentId,
      name: nameController.text.trim(),
      age: selectedAge,
      interests: selectedInterests.join(','),
      avatar: selectedAvatar,
    );

    setState(() => isLoading = false);

    if (result['childId'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        errorMessage = result['error'] ?? 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7F77DD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 10),

              // Header
              Center(
                child: Column(
                  children: [
                    Text(
                      'Create Child Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tell us about your child',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // White card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Avatar picker
                    Text(
                      'Pick an avatar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C3489),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(avatars.length, (index) {
                        bool isSelected = selectedAvatar == index + 1;
                        return GestureDetector(
                          onTap: () => setState(() => selectedAvatar = index + 1),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF7F77DD)
                                  : Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Color(0xFF3C3489), width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                avatars[index],
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 20),

                    // Child name
                    Text(
                      'Child Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C3489),
                      ),
                    ),
                    SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your child\'s name',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.child_care,
                          color: Color(0xFF7F77DD),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Age picker
                    Text(
                      'Age — $selectedAge years old',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C3489),
                      ),
                    ),
                    SizedBox(height: 6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Color(0xFF7F77DD),
                        inactiveTrackColor: Color(0xFFEEEDFE),
                        thumbColor: Color(0xFF7F77DD),
                        overlayColor: Color(0x297F77DD),
                        valueIndicatorColor: Color(0xFF7F77DD),
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: Slider(
                        value: selectedAge.toDouble(),
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: '$selectedAge years',
                        onChanged: (value) {
                          setState(() => selectedAge = value.toInt());
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 yr', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('2', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('3', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('4', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('5', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('6', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('7 yr', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Interests
                    Text(
                      'Interests (select all that apply)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C3489),
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: interests.map((interest) {
                        bool isSelected = selectedInterests
                            .contains(interest['label']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedInterests.remove(interest['label']);
                              } else {
                                selectedInterests.add(interest['label']!);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF7F77DD)
                                  : Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  interest['icon']!,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  interest['label']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 16),

                    // Error message
                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFEBEB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7F77DD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Save Child Profile',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}