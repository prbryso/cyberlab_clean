import 'dart:collection';

import 'educational_domain.dart';
import 'learning_module.dart';

/// Authoritative catalog of educational content registered with
/// Systems Studio.
///
/// The registry controls mutation. Consumers receive read-only views.
class EducationalRegistry {
  EducationalRegistry._();

  static final EducationalRegistry instance = EducationalRegistry._();

  final Map<String, EducationalDomain> _domains = {};
  final Map<String, LearningModule> _modules = {};

  UnmodifiableListView<EducationalDomain> get domains {
    final values = _domains.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return UnmodifiableListView(values);
  }

  UnmodifiableListView<LearningModule> get modules {
    final values = _modules.values.toList()
      ..sort((a, b) {
        final orderComparison = a.order.compareTo(b.order);

        if (orderComparison != 0) {
          return orderComparison;
        }

        return a.title.compareTo(b.title);
      });

    return UnmodifiableListView(values);
  }

  void registerDomain(EducationalDomain domain) {
    _validateIdentifier(domain.id, objectType: 'domain');

    if (_domains.containsKey(domain.id)) {
      throw StateError(
        'An educational domain with ID "${domain.id}" is already registered.',
      );
    }

    _domains[domain.id] = domain;
  }

  void registerModule(LearningModule module) {
    _validateIdentifier(module.id, objectType: 'module');
    _validateIdentifier(module.domainId, objectType: 'domain reference');

    if (_modules.containsKey(module.id)) {
      throw StateError(
        'A learning module with ID "${module.id}" is already registered.',
      );
    }

    if (!_domains.containsKey(module.domainId)) {
      throw StateError(
        'Cannot register module "${module.id}". '
        'Domain "${module.domainId}" has not been registered.',
      );
    }

    _modules[module.id] = module;
  }

  void registerModules(Iterable<LearningModule> modules) {
    for (final module in modules) {
      registerModule(module);
    }
  }

  EducationalDomain? domainById(String id) {
    return _domains[id];
  }

  LearningModule? moduleById(String id) {
    return _modules[id];
  }

  UnmodifiableListView<LearningModule> modulesForDomain(String domainId) {
    final values =
        _modules.values.where((module) => module.domainId == domainId).toList()
          ..sort((a, b) {
            final orderComparison = a.order.compareTo(b.order);

            if (orderComparison != 0) {
              return orderComparison;
            }

            return a.title.compareTo(b.title);
          });

    return UnmodifiableListView(values);
  }

  bool containsDomain(String id) {
    return _domains.containsKey(id);
  }

  bool containsModule(String id) {
    return _modules.containsKey(id);
  }

  /// Intended primarily for tests and controlled application restarts.
  void clear() {
    _modules.clear();
    _domains.clear();
  }

  void _validateIdentifier(String id, {required String objectType}) {
    if (id.trim().isEmpty) {
      throw ArgumentError('$objectType ID cannot be empty.');
    }

    final validIdentifier = RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$');

    if (!validIdentifier.hasMatch(id)) {
      throw ArgumentError(
        'Invalid $objectType ID "$id". '
        'Use lowercase letters, numbers, periods, underscores, or hyphens.',
      );
    }
  }
}
