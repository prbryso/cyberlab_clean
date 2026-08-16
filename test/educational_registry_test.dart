import 'package:flutter_test/flutter_test.dart';
import 'package:systems_studio/engine/education/educational_registry.dart';
import 'package:systems_studio/libraries/cyber_lab/cyber_lab_library.dart';

void main() {
  final registry = EducationalRegistry.instance;

  setUp(() {
    registry.clear();
  });

  test('Cyber Lab registers its domain and all twelve modules', () {
    CyberLabLibrary.register(registry);

    final domain = registry.domainById('cybersecurity');
    final passwordModule = registry.moduleById(
      'cybersecurity.password_security',
    );

    expect(domain, isNotNull);
    expect(domain?.name, 'Cybersecurity');
    expect(domain?.moduleIds, hasLength(12));

    expect(passwordModule, isNotNull);
    expect(passwordModule?.domainId, 'cybersecurity');
    expect(passwordModule?.title, 'Prevent Account Takeovers');

    final modules = registry.modulesForDomain('cybersecurity');

    expect(modules, hasLength(12));
    expect(modules.first.id, 'cybersecurity.password_security');
    expect(modules.last.id, 'cybersecurity.capstone');
  });

  test('Cyber Lab registration is safe to call more than once', () {
    CyberLabLibrary.register(registry);
    CyberLabLibrary.register(registry);

    expect(registry.domains, hasLength(1));
    expect(registry.modules, hasLength(12));
  });
}
