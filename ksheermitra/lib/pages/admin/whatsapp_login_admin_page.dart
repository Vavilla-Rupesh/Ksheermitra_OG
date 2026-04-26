import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/whatsapp_login.service.dart';

/// Admin page for managing WhatsApp QR code login
///
/// Features:
/// - Display current QR code
/// - Show session status
/// - Monitor expiration with alert
/// - Reset session
class WhatsAppLoginAdminPage extends StatefulWidget {
  final String baseUrl;
  final String adminUsername;
  final String adminPassword;

  const WhatsAppLoginAdminPage({
    Key? key,
    required this.baseUrl,
    required this.adminUsername,
    required this.adminPassword,
  }) : super(key: key);

  @override
  State<WhatsAppLoginAdminPage> createState() => _WhatsAppLoginAdminPageState();
}

class _WhatsAppLoginAdminPageState extends State<WhatsAppLoginAdminPage> {
  late WhatsAppLoginService _whatsappService;
  WhatsAppQRResponse? _qrResponse;
  WhatsAppSessionInfo? _sessionInfo;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _whatsappService = WhatsAppLoginService(
      baseUrl: widget.baseUrl,
      username: widget.adminUsername,
      password: widget.adminPassword,
    );
    _loadSessionInfo();
    // Refresh status every 30 seconds
    Future.delayed(const Duration(seconds: 30), _refreshStatus);
  }

  Future<void> _loadSessionInfo() async {
    setState(() => _isLoading = true);
    try {
      final info = await _whatsappService.getSessionInfo();
      setState(() {
        _sessionInfo = info;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getQRCode() async {
    setState(() => _isLoading = true);
    try {
      final qr = await _whatsappService.getQRCode();
      setState(() {
        _qrResponse = qr;
        _error = null;
      });
      // Auto-refresh status in 5 seconds
      Future.delayed(const Duration(seconds: 5), _loadSessionInfo);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetSession() async {
    final confirm = await _showConfirmDialog(
      'Reset WhatsApp Session?',
      'This will disconnect WhatsApp and require a new QR scan.',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      await _whatsappService.resetSession();
      setState(() => _error = null);
      _getQRCode();
      _showSnackBar('Session reset. Scan the new QR code.', Colors.green);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshStatus() async {
    try {
      await _loadSessionInfo();
    } finally {
      if (mounted) {
        Future.delayed(const Duration(seconds: 30), _refreshStatus);
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Session Management'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              _buildErrorCard()
            else if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_qrResponse != null)
              _buildQRCodeCard()
            else
              _buildGetQRCodeCard(),
            const SizedBox(height: 24),
            _buildSessionStatusCard(),
            if (_sessionInfo?.expirationAlert.isExpiringSoon ?? false)
              const SizedBox(height: 16),
            if (_sessionInfo?.expirationAlert.isExpiringSoon ?? false)
              _buildExpirationAlertCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadSessionInfo,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Scan QR Code with WhatsApp',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.memory(
                base64Decode(_qrResponse!.qrCode.split(',').last),
                width: 250,
                height: 250,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Expires in ${_qrResponse!.expiresIn} seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
            ),
            const SizedBox(height: 16),
            ..._qrResponse!.instructions.map((instr) {
              final index = _qrResponse!.instructions.indexOf(instr) + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue,
                      child: Text(
                        '$index',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(instr)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGetQRCodeCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.qr_code, color: Colors.blue, size: 48),
            const SizedBox(height: 12),
            Text(
              'WhatsApp Not Connected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a QR code to establish WhatsApp session',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _getQRCode,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStatusCard() {
    final status = _sessionInfo?.session;

    if (status == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.isConnected ? Icons.check_circle : Icons.cancel,
                  color: status.isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Text(
                  'Session Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Status', status.statusText),
            _buildStatusRow('State', status.connectionState),
            if (status.uptime != null)
              _buildStatusRow('Uptime', '${status.uptime} hours'),
            if (status.timeUntilExpiration != null)
              _buildStatusRow(
                'Expires In',
                status.timeUntilExpiration == 0
                    ? 'Less than 1 hour'
                    : '${status.timeUntilExpiration} hours',
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _resetSession,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationAlertCard() {
    final alert = _sessionInfo!.expirationAlert;

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Session Expiring Soon',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Scan New QR'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadSessionInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Widget to display WhatsApp session status in admin dashboard
class WhatsAppStatusWidget extends StatefulWidget {
  final String baseUrl;
  final String adminUsername;
  final String adminPassword;

  const WhatsAppStatusWidget({
    Key? key,
    required this.baseUrl,
    required this.adminUsername,
    required this.adminPassword,
  }) : super(key: key);

  @override
  State<WhatsAppStatusWidget> createState() => _WhatsAppStatusWidgetState();
}

class _WhatsAppStatusWidgetState extends State<WhatsAppStatusWidget> {
  late WhatsAppLoginService _service;
  WhatsAppSessionStatus? _status;

  @override
  void initState() {
    super.initState();
    _service = WhatsAppLoginService(
      baseUrl: widget.baseUrl,
      username: widget.adminUsername,
      password: widget.adminPassword,
    );
    _loadStatus();
    // Refresh every 60 seconds
    Future.delayed(const Duration(seconds: 60), _loadStatus);
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _service.getSessionStatus();
      if (mounted) {
        setState(() => _status = status);
      }
    } catch (e) {
      // Silent fail for widget
    }
    if (mounted) {
      Future.delayed(const Duration(seconds: 60), _loadStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _status!.isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _status!.isHealthy ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _status!.isConnected ? Icons.check_circle : Icons.cancel,
            color: _status!.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WhatsApp Session',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  _status!.statusText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (_status!.timeUntilExpiration != null &&
              _status!.timeUntilExpiration! < 60)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_status!.timeUntilExpiration}h left',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

