import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/initials_avatar.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The delivery agent with call and SMS buttons (they open the phone's own apps).
class AgentCard extends StatelessWidget {
  const AgentCard({super.key, required this.agent});

  final DeliveryAgent agent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      child: Row(
        children: [
          InitialsAvatar(name: agent.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent.name, style: textTheme.titleSmall),
                Text(
                  l10n.deliveryAgentTitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(TzPhone.format(agent.phone), style: textTheme.bodySmall),
              ],
            ),
          ),
          IconButton.outlined(
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: agent.phone)),
            tooltip: l10n.actionCall,
            color: AppColors.primary,
            icon: const Icon(Icons.call_outlined),
          ),
          IconButton.outlined(
            onPressed: () => launchUrl(Uri(scheme: 'smsto', path: agent.phone)),
            tooltip: l10n.actionMessage,
            color: AppColors.primary,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
    );
  }
}
