import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import 'onboarding_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<LibraryProvider>(
        builder: (context, library, child) {
          final profile = library.userProfile;
          
          return ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 120),
            physics: const BouncingScrollPhysics(),
            children: [
              const Text(
                'Настройки',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildGlassCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Профиль', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9D88F2), Color(0xFFC0ADFC)],
                            ),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.nickname ?? 'Слушатель',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile?.favoriteGenres.join(', ') ?? 'Любитель музыки',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: _buildGlassCard(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite, color: Color(0xFF9D88F2), size: 32),
                          const SizedBox(height: 12),
                          Text(
                            library.likedTracks.length.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Лайков', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGlassCard(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.queue_music, color: Color(0xFF9D88F2), size: 32),
                          const SizedBox(height: 12),
                          Text(
                            library.playlists.length.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Плейлистов', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildGlassCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Управление данными', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                      title: const Text('Очистить все данные', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text('Удалит все лайки и плейлисты', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => _confirmClearData(context, library),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Rush Mobile v1.0.0',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClearData(BuildContext context, LibraryProvider library) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E182A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Внимание', style: TextStyle(color: Colors.white)),
        content: const Text('Вы уверены, что хотите удалить все данные?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false), 
            child: const Text('Отмена', style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true), 
            child: const Text('Удалить', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await library.clearAllData();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }
}
