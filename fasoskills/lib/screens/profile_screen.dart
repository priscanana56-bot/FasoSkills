import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/theme.dart';
import 'profile_pages.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final menuItems = [
      {
        "icon": Icons.person_outline,
        "title": "Informations personnelles",
        "page": const PersonalInfoPage(),
      },
      {
        "icon": Icons.location_on_outlined,
        "title": "Adresses enregistrées",
        "page": const SavedAddressesPage(),
      },
      {
        "icon": Icons.credit_card_outlined,
        "title": "Moyens de paiement",
        "page": const PaymentMethodsPage(),
      },
      {
        "icon": Icons.history_outlined,
        "title": "Historique des demandes",
        "page": const RequestsHistoryPage(),
      },
      {
        "icon": Icons.notifications_outlined,
        "title": "Paramètres de notifications",
        "page": const NotificationSettingsPage(),
      },
      {
        "icon": Icons.security_outlined,
        "title": "Sécurité",
        "page": const SecurityPage(),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowMedium,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.inputFillColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.avatarUrl.isNotEmpty == true
                        ? NetworkImage(user!.avatarUrl)
                        : null,
                    child: user?.avatarUrl.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Awa Traoré',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.role ?? 'Client',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: menuItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == menuItems.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil('/', (route) => false);
                            }
                          },
                          icon: const Icon(
                            Icons.logout_outlined,
                            color: AppTheme.destructiveColor,
                          ),
                          label: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: AppTheme.destructiveColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.destructiveColor,
                            side: const BorderSide(
                              color: AppTheme.destructiveColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final item = menuItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowLight,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          item["icon"] as IconData,
                          color: AppTheme.textColor,
                        ),
                        title: Text(
                          item["title"] as String,
                          style: const TextStyle(color: AppTheme.textColor),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: AppTheme.textMuted,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => item["page"] as Widget,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
