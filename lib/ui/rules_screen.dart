import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'i18n/app_strings.dart';

/// Full-screen view that renders the game rules markdown for the current language.
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.rulesTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(strings.gameRulesAsset),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Icon(Icons.error_outline));
          }
          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              h1: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              h2: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              h3: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              p: Theme.of(context).textTheme.bodyMedium,
              code: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          );
        },
      ),
    );
  }
}
