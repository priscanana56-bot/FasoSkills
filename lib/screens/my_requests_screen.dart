import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote.dart';
import '../models/service_request.dart';
import '../services/api_exception.dart';
import '../services/quote_service.dart';
import '../services/request_service.dart';
import '../theme/theme.dart';
import '../utils/status_helper.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _requestService = RequestService();
  final _quoteService = QuoteService();

  String _selectedTab = 'pending';
  bool _isLoading = true;
  String? _error;
  List<ServiceRequest> _requests = [];
  List<Quote> _quotes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _requestService.getRequests(),
        _quoteService.getQuotes(),
      ]);
      if (mounted) {
        setState(() {
          _requests = results[0] as List<ServiceRequest>;
          _quotes = results[1] as List<Quote>;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  int _countForTab(String status) =>
      _requests.where((r) => r.status == status).length;

  int _quoteCountForRequest(int requestId) =>
      _quotes.where((q) => q.request?.id == requestId).length;

  List<ServiceRequest> get _filteredRequests =>
      _requests.where((r) => r.status == _selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mes demandes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildTab('pending', 'En attente'),
                  const SizedBox(width: 12),
                  _buildTab('accepted', 'Acceptées'),
                  const SizedBox(width: 12),
                  _buildTab('completed', 'Terminées'),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _ErrorView(message: _error!, onRetry: _loadData)
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: _filteredRequests.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    'Aucune demande dans cette catégorie',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = _filteredRequests[index];
                                return _RequestCard(
                                  request: request,
                                  quoteCount: _quoteCountForRequest(request.id),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String status, String label) {
    final isSelected = _selectedTab == status;
    final count = _countForTab(status);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.inputFillColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$label ($count)',
            style: TextStyle(
              color: isSelected ? AppTheme.onPrimary : AppTheme.textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.destructiveColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.quoteCount});

  final ServiceRequest request;
  final int quoteCount;

  @override
  Widget build(BuildContext context) {
    final statusLabel = StatusHelper.label(request.status);
    final statusColor = StatusHelper.requestColor(request.status);
    final dateStr = DateFormat('dd/MM/yyyy').format(request.createdAt);

    return Card(
      color: AppTheme.surfaceColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.fullAddress,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Demandée le $dateStr',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    quoteCount > 0
                        ? '$quoteCount propositions'
                        : 'Voir les détails',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (quoteCount > 0) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
