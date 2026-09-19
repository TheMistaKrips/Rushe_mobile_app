import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/library_provider.dart';
import '../../models/user_profile.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  File? _avatarImage;
  
  final List<String> _availableGenres = [
    'Pop', 'Hip Hop', 'Rock', 'Electronic', 'Jazz', 'Classical', 'Lofi Hip Hop', 
    'Synthwave', 'Indie', 'Metal', 'Synth Pop', 'Punk', 'Midwest Emo', 'Hardcore', 'Goth', 'Witch house'
  ];
  final Set<String> _selectedGenres = {};

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  void _nextPage() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите ваше имя'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _completeOnboarding() {
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один жанр'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final profile = UserProfile(
      nickname: _nameController.text.trim(),
      favoriteGenres: _selectedGenres.toList(),
      // In a real app, save avatar path to profile too, but UserProfile model might need update
    );

    context.read<LibraryProvider>().saveUserProfile(profile);
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildProfilePage(),
          _buildGenresPage(),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Container(
      color: const Color(0xFF0F0C16),
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Создай\nсвой\nпрофиль',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A2D),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF9D88F2), width: 3),
                    image: _avatarImage != null
                        ? DecorationImage(image: FileImage(_avatarImage!), fit: BoxFit.cover)
                        : const DecorationImage(image: AssetImage('images/icon.png'), fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9D88F2).withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: _avatarImage == null 
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                      )
                    : null,
                ),
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Твое имя',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D88F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                  shadowColor: const Color(0xFF9D88F2).withOpacity(0.5),
                ),
                child: const Text(
                  'Далее',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenresPage() {
    return Container(
      color: const Color(0xFF9D88F2),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 32),
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text(
                    'PICK\nYOUR\nFAVORITE\nGENRES',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.05,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_downward, color: Colors.white, size: 28),
                )
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: _availableGenres.map((genre) {
                    final isSelected = _selectedGenres.contains(genre);
                    // alternate styles to match the chaotic screenshot look
                    final isDarkStyle = genre.length % 2 == 0; 
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected ? _selectedGenres.remove(genre) : _selectedGenres.add(genre);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white 
                              : (isDarkStyle ? Colors.black : Colors.transparent),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: isDarkStyle ? Colors.black : Colors.black.withOpacity(0.5), 
                            width: 1.5
                          ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Colors.black 
                                : (isDarkStyle ? Colors.white : Colors.black.withOpacity(0.7)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'ПОГНАЛИ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
