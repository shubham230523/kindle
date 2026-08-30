import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/feature.dart';
import '../models/requirement.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/kindle_button.dart';

class ProjectEditScreen extends StatefulWidget {
  final Project project;

  const ProjectEditScreen({super.key, required this.project});

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late List<Feature> _features;
  late List<Requirement> _requirements;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descController = TextEditingController(text: widget.project.description);
    _features = List.from(widget.project.features);
    _requirements = List.from(widget.project.requirements);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedProject = widget.project.copyWith(
      name: _nameController.text,
      description: _descController.text,
      features: _features,
      requirements: _requirements,
    );
    Navigator.pop(context, updatedProject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Application Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              'Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            ..._features.asMap().entries.map((entry) {
              int idx = entry.key;
              Feature feature = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
                child: TextField(
                  onChanged: (val) {
                    _features[idx] = feature.copyWith(name: val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Feature name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _features.removeAt(idx);
                        });
                      },
                    ),
                  ),
                  controller: TextEditingController(text: feature.name),
                ),
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _features.add(Feature(
                    id: DateTime.now().toString(),
                    name: 'New Feature',
                    description: '',
                    category: 'General',
                  ));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Feature'),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            KindleButton(
              text: 'Save Changes',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
