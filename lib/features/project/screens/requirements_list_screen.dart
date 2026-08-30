import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/requirement.dart';
import '../models/feature.dart';
import '../models/user_story.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class RequirementsListScreen extends StatefulWidget {
  final Project project;

  const RequirementsListScreen({super.key, required this.project});

  @override
  State<RequirementsListScreen> createState() => _RequirementsListScreenState();
}

class _RequirementsListScreenState extends State<RequirementsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requirements & Features'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Functional'),
                  Tab(text: 'Non-Functional'),
                  Tab(text: 'Features'),
                  Tab(text: 'User Stories'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequirementsList(RequirementType.functional),
          _buildRequirementsList(RequirementType.nonFunctional),
          _buildFeaturesList(),
          _buildUserStoriesList(),
        ],
      ),
    );
  }

  Widget _buildRequirementsList(RequirementType type) {
    final filtered = widget.project.requirements
        .where((r) => r.type == type)
        .where((r) => r.title.toLowerCase().contains(_searchQuery) || r.description.toLowerCase().contains(_searchQuery))
        .toList();

    return _ResponsiveListView(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final req = filtered[index];
        return _RequirementTile(requirement: req);
      },
    );
  }

  Widget _buildFeaturesList() {
    final filtered = widget.project.features
        .where((f) => f.name.toLowerCase().contains(_searchQuery) || f.description.toLowerCase().contains(_searchQuery))
        .toList();

    return _ResponsiveListView(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final feature = filtered[index];
        return _FeatureTile(feature: feature);
      },
    );
  }

  Widget _buildUserStoriesList() {
    final filtered = widget.project.userStories
        .where((us) => us.fullText.toLowerCase().contains(_searchQuery))
        .toList();

    return _ResponsiveListView(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final story = filtered[index];
        return _UserStoryTile(story: story);
      },
    );
  }
}

class _ResponsiveListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _ResponsiveListView({required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  final Requirement requirement;

  const _RequirementTile({required this.requirement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          title: Text(requirement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: _PriorityBadge(priority: requirement.priority),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(requirement.description),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final Feature feature;

  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          title: Text(feature.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(feature.category, style: Theme.of(context).textTheme.bodySmall),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feature.description),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserStoryTile extends StatelessWidget {
  final UserStory story;

  const _UserStoryTile({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(story.actor, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(story.fullText, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final RequirementPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case RequirementPriority.low:
        color = Colors.blue;
        break;
      case RequirementPriority.medium:
        color = Colors.orange;
        break;
      case RequirementPriority.high:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
