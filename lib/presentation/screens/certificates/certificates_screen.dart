import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  bool _isLoading = false;
  List<Certificate> _certificates = [];

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _certificates = _getMockCertificates();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Certificates',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading certificates...')
          : _certificates.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.workspace_premium,
                  title: 'No Certificates Yet',
                  subtitle: 'Your certificates from events will appear here',
                  actionText: 'Refresh',
                  onActionTap: _loadCertificates,
                )
              : _buildCertificatesList(),
    );
  }

  Widget _buildCertificatesList() {
    return RefreshIndicator(
      onRefresh: _loadCertificates,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _certificates.length,
        itemBuilder: (context, index) {
          final certificate = _certificates[index];
          return _buildCertificateCard(certificate);
        },
      ),
    );
  }

  Widget _buildCertificateCard(Certificate certificate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(certificate.category),
                  _getCategoryColor(certificate.category).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.eventName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(certificate.category, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    certificate.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.calendar_today, 'Event Date', certificate.eventDate),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.person, 'Participant', certificate.participantName),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.emoji_events, 'Achievement', certificate.achievement),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewCertificate(certificate),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadCertificate(certificate),
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  void _viewCertificate(Certificate certificate) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Certificate Preview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Certificate of Participation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(certificate.eventName, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Awarded to ${certificate.participantName}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () { Navigator.of(context).pop(); _downloadCertificate(certificate); }, child: const Text('Download'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadCertificate(Certificate certificate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading certificate for ${certificate.eventName}...'), backgroundColor: Colors.green),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technical': return Colors.blue;
      case 'cultural': return Colors.purple;
      case 'sports': return Colors.green;
      case 'academic': return Colors.orange;
      default: return Colors.grey;
    }
  }

  List<Certificate> _getMockCertificates() {
    return [
      Certificate(
        id: '1',
        eventName: 'Tech Fest 2024',
        category: 'Technical',
        eventDate: 'December 15, 2024',
        participantName: 'John Doe',
        achievement: 'Participation',
        status: 'Available',
        description: 'Certificate of participation in the annual technical festival.',
      ),
      Certificate(
        id: '2',
        eventName: 'Hackathon 2024',
        category: 'Technical',
        eventDate: 'November 28, 2024',
        participantName: 'John Doe',
        achievement: 'Winner',
        status: 'Available',
        description: 'First place winner in the 48-hour coding marathon.',
      ),
    ];
  }
}

class Certificate {
  final String id;
  final String eventName;
  final String category;
  final String eventDate;
  final String participantName;
  final String achievement;
  final String status;
  final String description;

  Certificate({
    required this.id,
    required this.eventName,
    required this.category,
    required this.eventDate,
    required this.participantName,
    required this.achievement,
    required this.status,
    required this.description,
  });
}