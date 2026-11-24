import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ProfilePageShell extends StatelessWidget {
  const ProfilePageShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: actions,
      ),
      body: SafeArea(child: child),
    );
  }
}

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController(text: 'Cedric');
  final _phone = TextEditingController(text: '+226 70 12 34 56');
  final _email = TextEditingController(text: 'cedric@example.com');
  final _dob = TextEditingController(text: '12/05/1995');
  final _gender = TextEditingController(text: 'Homme');
  final _specialty = TextEditingController(text: 'Plomberie');
  final _bio = TextEditingController(
    text:
        'Artisan plombier avec plus de 5 ans d’expérience dans l’installation et la réparation.',
  );

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _dob.dispose();
    _gender.dispose();
    _specialty.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Informations personnelles',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.camera_alt_outlined),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.inputFillColor,
                    child: Icon(
                      Icons.person,
                      size: 44,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _profileField('Nom complet', _fullName),
              _profileField('Téléphone', _phone),
              _profileField('Email', _email),
              _profileField('Date de naissance', _dob),
              _profileField('Genre', _gender),
              _profileField('Spécialité', _specialty),
              _profileField('Bio', _bio, maxLines: 4),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class SavedAddressesPage extends StatelessWidget {
  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Adresses enregistrées',
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressPage()),
          ),
          icon: const Icon(Icons.add),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _AddressCard(
              title: 'Domicile',
              subtitle:
                  'Secteur 15, Ouagadougou\nBurkina Faso\n+226 70 12 34 56',
              isDefault: true,
            ),
            const SizedBox(height: 12),
            _AddressCard(
              title: 'Atelier',
              subtitle:
                  'Zone industrielle, Ouagadougou\nBurkina Faso\n+226 64 12 34 56',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text('Aucune autre adresse'),
                    const SizedBox(height: 8),
                    const Text(
                      'Ajoutez une adresse pour faciliter vos interventions.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAddressPage(),
                        ),
                      ),
                      child: const Text('Ajouter une adresse'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAddressPage extends StatelessWidget {
  const AddAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Ajouter une adresse',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Type d’adresse'),
            ),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(labelText: 'Adresse complète'),
            ),
            const SizedBox(height: 14),
            const TextField(decoration: InputDecoration(labelText: 'Ville')),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(labelText: 'Téléphone'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Moyens de paiement',
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPaymentMethodPage()),
          ),
          icon: const Icon(Icons.add),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _PaymentCard(
              title: 'Moov Money',
              subtitle: '+226 70 12 34 56',
              isDefault: true,
            ),
            const SizedBox(height: 12),
            _PaymentCard(title: 'Orange Money', subtitle: '+226 66 12 34 56'),
            const SizedBox(height: 12),
            _PaymentCard(
              title: 'Compte bancaire',
              subtitle: 'BOA - Burkina Faso\n1234 **** **** 5678',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.credit_card_outlined,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text('Aucun autre moyen de paiement'),
                    const SizedBox(height: 8),
                    const Text(
                      'Ajoutez un moyen de paiement pour recevoir vos paiements.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPaymentMethodPage(),
                        ),
                      ),
                      child: const Text('Ajouter un moyen'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPaymentMethodPage extends StatelessWidget {
  const AddPaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Ajouter un moyen de paiement',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Type de moyen'),
            ),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(labelText: 'Numéro de téléphone'),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Définir comme moyen par défaut'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestsHistoryPage extends StatelessWidget {
  const RequestsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = const ['Tous', 'En cours', 'Terminées', 'Annulées'];
    return ProfilePageShell(
      title: 'Historique des demandes',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs
                    .map(
                      (tab) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(tab),
                          backgroundColor: tab == 'Tous'
                              ? AppTheme.primaryColor
                              : AppTheme.inputFillColor,
                          labelStyle: TextStyle(
                            color: tab == 'Tous'
                                ? Colors.white
                                : AppTheme.textColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  _RequestSummaryCard(
                    id: '#1234',
                    title: 'Installation robinet',
                    location: 'Secteur 15, Ouaga',
                    date: '12 Mai 2024 • 10:30',
                    amount: '25000 FCFA',
                    status: 'Terminée',
                  ),
                  _RequestSummaryCard(
                    id: '#1233',
                    title: 'Réparation fuite',
                    location: 'Zone 4, Ouaga',
                    date: '10 Mai 2024 • 14:20',
                    amount: '15000 FCFA',
                    status: 'Terminée',
                  ),
                  _RequestSummaryCard(
                    id: '#1232',
                    title: 'Débouchage canalisation',
                    location: 'Pâte d’oie, Ouaga',
                    date: '08 Mai 2024 • 09:15',
                    amount: '20000 FCFA',
                    status: 'Annulée',
                  ),
                  _RequestSummaryCard(
                    id: '#1231',
                    title: 'Installation évier',
                    location: 'Koulouba, Ouaga',
                    date: '05 Mai 2024 • 16:45',
                    amount: '30000 FCFA',
                    status: 'Terminée',
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

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool push = true;
  bool requests = true;
  bool messages = true;
  bool payments = true;
  bool promotions = false;
  bool reminders = true;

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Paramètres de notifications',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _toggle('Notifications push', push, (v) => setState(() => push = v)),
          _toggle(
            'Nouvelles demandes',
            requests,
            (v) => setState(() => requests = v),
          ),
          _toggle('Messages', messages, (v) => setState(() => messages = v)),
          _toggle(
            'Paiements reçus',
            payments,
            (v) => setState(() => payments = v),
          ),
          _toggle(
            'Promotions et offres',
            promotions,
            (v) => setState(() => promotions = v),
          ),
          _toggle('Rappels', reminders, (v) => setState(() => reminders = v)),
        ],
      ),
    );
  }

  Widget _toggle(String title, bool value, ValueChanged<bool> onChanged) {
    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title),
      ),
    );
  }
}

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Sécurité',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SecurityActionCard(
            icon: Icons.lock_outline,
            title: 'Changer le mot de passe',
            subtitle: 'Modifiez votre mot de passe de connexion',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          _SecurityActionCard(
            icon: Icons.verified_user_outlined,
            title: 'Authentification à deux facteurs',
            subtitle: 'Activé',
            trailing: _status('Activé', AppTheme.statusCompleted),
            onTap: () {},
          ),
          _SecurityActionCard(
            icon: Icons.devices_outlined,
            title: 'Sessions actives',
            subtitle: '2 sessions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ActiveSessionsPage()),
            ),
          ),
          _SecurityActionCard(
            icon: Icons.shield_outlined,
            title: 'Appareils de confiance',
            subtitle: '1 appareil',
            onTap: () {},
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: AppTheme.destructiveColor),
            label: const Text(
              'Déconnexion de tous les appareils',
              style: TextStyle(color: AppTheme.destructiveColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(String text, Color color) => Chip(
    label: Text(text),
    backgroundColor: color.withValues(alpha: 0.14),
    labelStyle: TextStyle(color: color),
  );
}

class ActiveSessionsPage extends StatelessWidget {
  const ActiveSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Sessions actives',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _SessionCard(
            device: 'Cet appareil',
            platform: 'Flutter • Android',
            place: 'Ouagadougou, Burkina Faso',
            status: 'Actif maintenant',
            active: true,
          ),
          _SessionCard(
            device: 'Autre appareil',
            platform: 'Chrome • Windows',
            place: 'Ouagadougou, Burkina Faso',
            status: '12 Mai 2024 à 10:30',
          ),
          _SessionCard(
            device: 'Autre appareil',
            platform: 'Chrome • Android',
            place: 'Bobo-Dioulasso, Burkina Faso',
            status: '10 Mai 2024 à 15:45',
          ),
          SizedBox(height: 12),
          Text(
            'Si vous ne reconnaissez pas une session, déconnectez-la immédiatement.',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPwd = TextEditingController();
  final newPwd = TextEditingController();
  final confirmPwd = TextEditingController();

  @override
  void dispose() {
    oldPwd.dispose();
    newPwd.dispose();
    confirmPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Modifier le mot de passe',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Ancien mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 14),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Le mot de passe doit contenir :'),
                    SizedBox(height: 8),
                    Text('• Au moins 8 caractères'),
                    Text('• Une lettre majuscule'),
                    Text('• Un chiffre'),
                    Text('• Un caractère spécial'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.title,
    required this.subtitle,
    this.isDefault = false,
  });
  final String title;
  final String subtitle;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.home_outlined, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        const Chip(label: Text('Par défaut')),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.title,
    required this.subtitle,
    this.isDefault = false,
  });
  final String title;
  final String subtitle;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.payment_outlined,
          color: AppTheme.primaryColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isDefault
            ? const Chip(label: Text('Par défaut'))
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.amount,
    required this.status,
  });

  final String id;
  final String title;
  final String location;
  final String date;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Demande $id'),
        subtitle: Text('$title\n$location\n$date\n$amount'),
        trailing: Chip(label: Text(status)),
      ),
    );
  }
}

class _SecurityActionCard extends StatelessWidget {
  const _SecurityActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.device,
    required this.platform,
    required this.place,
    required this.status,
    this.active = false,
  });
  final String device;
  final String platform;
  final String place;
  final String status;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          active ? Icons.computer : Icons.devices_other,
          color: active ? AppTheme.statusCompleted : AppTheme.textMuted,
        ),
        title: Text(device),
        subtitle: Text('$platform\n$place\n$status'),
        trailing: active
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(
                onPressed: () {},
                child: const Text(
                  'Déconnecter',
                  style: TextStyle(color: AppTheme.destructiveColor),
                ),
              ),
      ),
    );
  }
}
