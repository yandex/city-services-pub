import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import '../routes.dart';
import 'legacy_detail_page.dart';

/// Home page for the Compatibility Mode demo.
///
/// Shows everything you can do with the Navigator 1.0 API:
/// - push with MaterialPageRoute and CupertinoPageRoute
/// - pushReplacement
/// - pushAndRemoveUntil
/// - showDialog, showCupertinoDialog
/// - showModalBottomSheet
/// - Receiving results from pop
class CompatibilityHomePage extends StatefulWidget {
  const CompatibilityHomePage({super.key});

  @override
  State<CompatibilityHomePage> createState() => _CompatibilityHomePageState();
}

class _CompatibilityHomePageState extends State<CompatibilityHomePage> {
  String _lastResult = 'No result yet';

  void _showResult(String? result) {
    final resultText = result ?? 'null (dismissed)';
    setState(() {
      _lastResult = resultText;
    });

    // Show SnackBar with result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result: $resultText'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compatibility Mode Demo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Info card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'About Compatibility Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This example shows the Navigator 1.0 API '
                    '(push, pop, showDialog and friends) running inside an '
                    'app that uses YxNavigation for declarative navigation.\n\n'
                    'Every button below uses the legacy imperative '
                    'Navigator.of(context) API, yet they all play nicely '
                    'with the declarative navigation state.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Last result
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last result:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastResult,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: basic navigation
          _buildSectionTitle('1. Basic navigation (push/pop)'),
          _buildDemoButton(
            title: 'Push Material Route',
            subtitle: 'Navigator.of(context).push(MaterialPageRoute(...))',
            icon: Icons.arrow_forward,
            color: Colors.blue,
            onPressed: () async {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'legacy-material-detail'),
                  builder: (context) => const LegacyDetailPage(
                    title: 'Material Route',
                    routeType: 'MaterialPageRoute',
                    result: 'Material Result',
                  ),
                ),
              );
              _showResult(result);
            },
          ),
          _buildDemoButton(
            title: 'Push Cupertino Route',
            subtitle: 'Navigator.of(context).push(CupertinoPageRoute(...))',
            icon: Icons.arrow_forward_ios,
            color: Colors.orange,
            onPressed: () async {
              final result = await Navigator.of(context).push<String>(
                CupertinoPageRoute(
                  settings:
                      const RouteSettings(name: 'legacy-cupertino-detail'),
                  builder: (context) => const LegacyDetailPage(
                    title: 'Cupertino Route',
                    routeType: 'CupertinoPageRoute',
                    result: 'Cupertino Result',
                  ),
                ),
              );
              _showResult(result);
            },
          ),
          _buildDemoButton(
            title: 'Push with Fullscreen Dialog',
            subtitle: 'MaterialPageRoute(fullscreenDialog: true)',
            icon: Icons.fullscreen,
            color: Colors.purple,
            onPressed: () async {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  settings:
                      const RouteSettings(name: 'legacy-fullscreen-dialog'),
                  fullscreenDialog: true,
                  builder: (context) => const LegacyDetailPage(
                    title: 'Fullscreen Dialog',
                    routeType: 'MaterialPageRoute (fullscreenDialog)',
                    result: 'Fullscreen Dialog Result',
                  ),
                ),
              );
              _showResult(result);
            },
          ),

          const SizedBox(height: 24),

          // Section: declarative navigation (for comparison)
          _buildSectionTitle('2. Declarative navigation (for comparison)'),
          _buildDemoButton(
            title: 'Push via YxNavigation (Profile)',
            subtitle: 'routeNavigator.push(CompatibilityRoutes.profile)',
            icon: Icons.route,
            color: Colors.teal,
            onPressed: () => routeNavigator.push(CompatibilityRoutes.profile),
          ),

          const SizedBox(height: 24),

          // Section: replace operations
          _buildSectionTitle(
            '3. Replace operations',
            subtitle:
                'Warning: without Compatibility mode these operations trigger an assert.',
          ),
          _buildDemoButton(
            title: 'PushReplacement',
            subtitle: 'Navigator.of(context).pushReplacement(...)',
            icon: Icons.swap_horiz,
            color: Colors.red,
            onPressed: () async {
              // Note: pushReplacement replaces current page in stack
              // Current page is destroyed, so _showResult won't be called
              await Navigator.of(context).pushReplacement<String, void>(
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'legacy-replacement'),
                  builder: (context) => const LegacyDetailPage(
                    title: 'Replacement Route',
                    routeType: 'pushReplacement',
                    result: 'Replacement Result',
                  ),
                ),
              );
            },
          ),
          _buildDemoButton(
            title: 'PushAndRemoveUntil',
            subtitle: 'Removes every prior route up to the predicate',
            icon: Icons.clear_all,
            color: Colors.deepOrange,
            onPressed: () async {
              final result =
                  await Navigator.of(context).pushAndRemoveUntil<String>(
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'legacy-remove-until'),
                  builder: (context) => const LegacyDetailPage(
                    title: 'PushAndRemoveUntil',
                    routeType: 'pushAndRemoveUntil',
                    result: 'RemoveUntil Result',
                    showBackButton: false,
                  ),
                ),
                (route) => false, // Removes every preceding route
              );
              _showResult(result);
            },
          ),

          const SizedBox(height: 24),

          // Section: modal surfaces
          _buildSectionTitle('4. Modal surfaces (Dialogs & BottomSheets)'),
          _buildDemoButton(
            title: 'Show Material Dialog',
            subtitle: 'showDialog(context: context, ...)',
            icon: Icons.message,
            color: Colors.indigo,
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Material Dialog'),
                  content: const Text(
                    'A standard Material dialog created via showDialog().\n\n'
                    'It runs as a pageless route and integrates cleanly '
                    'with YxNavigation.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop('Dialog OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              _showResult(result);
            },
          ),
          _buildDemoButton(
            title: 'Show Cupertino Dialog',
            subtitle: 'showCupertinoDialog(context: context, ...)',
            icon: Icons.message_outlined,
            color: Colors.cyan,
            onPressed: () async {
              final result = await showCupertinoDialog<String>(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Cupertino Dialog'),
                  content: const Text(
                    'A Cupertino-styled iOS dialog.\n\n'
                    'The pageless route works with YxNavigation.',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () =>
                          Navigator.of(context).pop('Cupertino OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              _showResult(result);
            },
          ),
          _buildDemoButton(
            title: 'Show Cupertino Modal Popup',
            subtitle: 'showCupertinoModalPopup(context: context, ...)',
            icon: Icons.ios_share,
            color: Colors.orange,
            onPressed: () async {
              final result = await showCupertinoModalPopup<String>(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: const Text('Cupertino Action Sheet'),
                  message: const Text(
                    'CupertinoModalPopupRoute works through Compatibility mode.',
                  ),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(context).pop('Action 1'),
                      child: const Text('Action 1'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(context).pop('Action 2'),
                      child: const Text('Action 2'),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(context).pop(),
                    isDestructiveAction: true,
                    child: const Text('Cancel'),
                  ),
                ),
              );
              _showResult(result);
            },
          ),
          _buildDemoButton(
            title: 'Show Popup Menu',
            subtitle: 'showMenu() - native mode (bypasses compatibility)',
            icon: Icons.more_vert,
            color: Colors.brown,
            onPressed: () async {
              // Get button position for menu
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay = Navigator.of(context)
                  .overlay!
                  .context
                  .findRenderObject() as RenderBox;
              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(Offset.zero, ancestor: overlay),
                  button.localToGlobal(
                    button.size.bottomRight(Offset.zero),
                    ancestor: overlay,
                  ),
                ),
                Offset.zero & overlay.size,
              );

              final result = await showMenu<String>(
                context: context,
                position: position,
                items: [
                  const PopupMenuItem<String>(
                    value: 'Option 1',
                    child: Text('Option 1'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Option 2',
                    child: Text('Option 2'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Option 3',
                    child: Text('Option 3'),
                  ),
                ],
              );
              _showResult(result);
            },
          ),
          _buildDemoButton(
            title: 'Show Modal BottomSheet',
            subtitle: 'showModalBottomSheet(context: context, ...)',
            icon: Icons.vertical_align_bottom,
            color: Colors.pink,
            onPressed: () async {
              final result = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Modal BottomSheet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ModalBottomSheetRoute also runs '
                        'as a pageless route through Compatibility mode.',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pop('BottomSheet OK'),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              _showResult(result);
            },
          ),
          _buildDemoButton(
            title: 'Show General Dialog',
            subtitle: 'showGeneralDialog (RawDialogRoute)',
            icon: Icons.admin_panel_settings,
            color: Colors.deepOrange,
            onPressed: () async {
              final result = await showGeneralDialog<String>(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Dismiss',
                barrierColor: Colors.black54,
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Center(
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 48,
                              color: Colors.deepOrange,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'General Dialog',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'RawDialogRoute with a custom animation.\n\n'
                              'The elastic scale transition is preserved '
                              'through the compatibility layer.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop('GeneralDialog OK'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
              _showResult(result);
            },
          ),

          const SizedBox(height: 24),

          // Supplementary notes
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '- NavigatorCompatibilityOverrides intercepts every Navigator 1.0 operation\n'
                    '- Each Route is wrapped in a Page and added to the RouteNode\n'
                    '- Pop results flow back through a Completer\n'
                    '- Replace operations succeed without hitting an assert\n'
                    '- Navigation state stays consistent',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildDemoButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
}
