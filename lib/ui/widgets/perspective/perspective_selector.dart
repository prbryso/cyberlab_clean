import 'package:flutter/material.dart';
import 'package:systems_studio/engine/models/perspective.dart';

class PerspectiveSelector extends StatelessWidget {
  final PerspectiveType selected;
  final ValueChanged<PerspectiveType> onChanged;

  const PerspectiveSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PerspectiveType>(
      segments: const [
        ButtonSegment(
          value: PerspectiveType.user,
          icon: Icon(Icons.person),
          label: Text("User"),
        ),
        ButtonSegment(
          value: PerspectiveType.attacker,
          icon: Icon(Icons.gpp_bad),
          label: Text("Attacker"),
        ),
        ButtonSegment(
          value: PerspectiveType.defender,
          icon: Icon(Icons.shield),
          label: Text("Defender"),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}
