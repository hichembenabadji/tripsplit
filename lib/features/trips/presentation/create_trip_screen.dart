import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_screen.dart';

class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScreen(
      title: 'Create Trip',
      subtitle: 'Presentation slot ready for the exported Figma screen.',
      child: _CreateTripPlaceholder(),
    );
  }
}

class _CreateTripPlaceholder extends StatelessWidget {
  const _CreateTripPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'This screen is intentionally light on UI for now. The final form will live in `features/trips/presentation/` with child widgets in `features/trips/widgets/`.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(decoration: const InputDecoration(labelText: 'Trip title')),
        const SizedBox(height: AppSpacing.lg),
        TextField(decoration: const InputDecoration(labelText: 'Destination')),
      ],
    );
  }
}
