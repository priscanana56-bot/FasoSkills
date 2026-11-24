import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..checkAuthStatus(),
      child: MaterialApp(
        title: 'FasoSkills',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.splashGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowPrimary,
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: AppTheme.onPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (authProvider.user != null) {
              return const HomeScreen();
            }

            return const SplashScreen();
          },
        ),
      ),
    );
  }
}
