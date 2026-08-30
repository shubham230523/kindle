import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/feature.dart';
import '../models/requirement.dart';

class ProjectViewModel extends ChangeNotifier {
  Project _project;
  Project get project => _project;

  ProjectViewModel(this._project);

  void updateProject({
    String? name,
    String? description,
    String? targetUsers,
    String? problemStatement,
    List<Feature>? features,
    List<Requirement>? requirements,
  }) {
    _project = _project.copyWith(
      name: name,
      description: description,
      targetUsers: targetUsers,
      problemStatement: problemStatement,
      features: features,
      requirements: requirements,
    );
    notifyListeners();
  }

  void updateFeature(int index, Feature updatedFeature) {
    final newFeatures = List<Feature>.from(_project.features);
    newFeatures[index] = updatedFeature;
    _project = _project.copyWith(features: newFeatures);
    notifyListeners();
  }

  void updateRequirement(int index, Requirement updatedRequirement) {
    final newRequirements = List<Requirement>.from(_project.requirements);
    newRequirements[index] = updatedRequirement;
    _project = _project.copyWith(requirements: newRequirements);
    notifyListeners();
  }
}
