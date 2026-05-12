import 'package:flutter/material.dart';

/// Legacy detail page opened via Navigator 1.0.
///
/// This page is created through MaterialPageRoute / CupertinoPageRoute
/// and shows how pageless routes behave under Compatibility mode.
class LegacyDetailPage extends StatelessWidget {
  const LegacyDetailPage({
    required this.title,
    required this.routeType,
    required this.result,
    this.showBackButton = true,
    super.key,
  });

  final String title;
  final String routeType;
  final String result;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: showBackButton,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route info
              Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.purple.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Route info',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Type:', routeType),
                      const SizedBox(height: 8),
                      _buildInfoRow('Mode:', 'Pageless Route'),
                      const SizedBox(height: 8),
                      _buildInfoRow('API:', 'Navigator 1.0'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Result on pop:', result),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description
              const Text(
                'This page was created through the imperative Navigator 1.0 API:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Navigator.of(context).push(\n'
                  '  $routeType(\n'
                  '    builder: (context) => LegacyDetailPage(...),\n'
                  '  ),\n'
                  ');',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Key traits
              const Text(
                'Key traits:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeature(
                '-',
                'Route is created imperatively, not from RouteDeclaration',
              ),
              _buildFeature(
                '-',
                'Wrapped in a Page via NavigatorCompatibilityOverrides',
              ),
              _buildFeature(
                '-',
                'Added to the RouteNode state tree as a pageless route',
              ),
              _buildFeature('-', 'Pop result is delivered through a Completer'),
              _buildFeature(
                '-',
                'Fully interoperable with declarative navigation',
              ),

              const Spacer(),

              // Buttons - show only if there is somewhere to return to
              if (showBackButton && Navigator.canPop(context)) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(result);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: Text('Pop with result: "$result"'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Pop without result (null)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ] else if (showBackButton && !Navigator.canPop(context)) ...[
                // No routes below - this is the only page in the stack
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This is the only page in the stack',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$routeType removed every previous page.\n'
                          'Pop is not possible - there is nothing to return to.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Case: showBackButton: false (pushAndRemoveUntil)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All previous routes were removed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This page is now the only one in the navigation stack.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildInfoRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      );

  Widget _buildFeature(String bullet, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bullet,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
}
