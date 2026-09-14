import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/avatar_badge.dart';
import '../domain/entities/org_hierarchy.dart';

/// Manager + direct-reports card - mirrors web/src/components/OrgHierarchyView.vue.
class OrgHierarchyCard extends StatelessWidget {
  const OrgHierarchyCard({super.key, required this.hierarchy, required this.onPersonTap});

  final OrgHierarchy hierarchy;
  final void Function(String employeeId) onPersonTap;

  @override
  Widget build(BuildContext context) {
    final directManager = hierarchy.managerChain.isNotEmpty ? hierarchy.managerChain.first : null;
    final restOfChain = hierarchy.managerChain.length > 1 ? hierarchy.managerChain.sublist(1) : const [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x1417153D), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('MANAGER'),
          const SizedBox(height: 8),
          if (directManager != null)
            _PersonRow(name: directManager.employeeName, seed: directManager.employeeId, onTap: () => onPersonTap(directManager.employeeId))
          else
            const Text('No manager on file — top of the chain.', style: TextStyle(fontSize: 11.5, color: AppColors.ink300)),
          if (restOfChain.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reports up through: ${restOfChain.map((m) => m.employeeName).join(', ')}',
              style: const TextStyle(fontSize: 10.5, color: AppColors.ink300),
            ),
          ],
          const Divider(height: 24, color: AppColors.border),
          _SectionLabel('DIRECT REPORTS (${hierarchy.directReports.length})'),
          const SizedBox(height: 8),
          if (hierarchy.directReports.isEmpty)
            const Text('No direct reports — individual contributor.', style: TextStyle(fontSize: 11.5, color: AppColors.ink300))
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 170),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: hierarchy.directReports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final report = hierarchy.directReports[index];
                  return _PersonRow(name: report.employeeName, seed: report.employeeId, onTap: () => onPersonTap(report.employeeId));
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.ink300),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.name, required this.seed, required this.onTap});

  final String name;
  final String seed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            AvatarBadge(name: name, seed: seed, size: 24, fontSize: 9),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
