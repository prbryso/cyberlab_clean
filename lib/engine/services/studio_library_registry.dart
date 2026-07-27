import 'package:systems_studio/engine/models/studio_library.dart';

class StudioLibraryRegistry {
  StudioLibraryRegistry._();

  static final StudioLibraryRegistry instance = StudioLibraryRegistry._();

  final List<StudioLibrary> _libraries = [];

  List<StudioLibrary> get libraries => List.unmodifiable(_libraries);

  void register(StudioLibrary library) {
    final alreadyRegistered = _libraries.any(
      (existingLibrary) => existingLibrary.id == library.id,
    );

    if (!alreadyRegistered) {
      _libraries.add(library);
    }
  }
}
