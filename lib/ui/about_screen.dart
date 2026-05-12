import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'i18n/app_strings.dart';

/// About screen — app info, feedback contact, and rules attribution.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // TODO: update to your real email before publishing
  static const _feedbackEmail = 'feedback@dicepoker.app';
  static const _rulesSourceUrl =
      'https://vamosokintressa.blogspot.com/2008/08/regras-tradicionais-portuguesas-do.html';
  static const _appVersion = '0.1.0';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMailto() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      queryParameters: {'subject': 'Dice Poker Feedback'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.aboutTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.casino_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Dice Poker',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${strings.aboutVersionLabel} $_appVersion',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.aboutAppDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email_outlined,
                  color: theme.colorScheme.primary),
              title: Text(strings.feedbackLabel),
              subtitle: const Text(_feedbackEmail),
              onTap: _openMailto,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.link, color: theme.colorScheme.primary),
              title: Text(strings.rulesSourceLabel),
              subtitle: const Text(
                'vamosokintressa.blogspot.com',
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _openUrl(_rulesSourceUrl),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
