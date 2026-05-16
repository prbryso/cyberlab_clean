import 'package:flutter/material.dart';
import 'package:cyber_lab/core/responsive/responsive_layout.dart';
import 'package:cyber_lab/theme/spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    final textScale = MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.3);

    int columns = 1;

    if (ResponsiveLayout.isMedium(context)) {
      columns = 2;
    } else if (ResponsiveLayout.isLarge(context)) {
      columns = 3;
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: textScale),
      child: Scaffold(
        appBar: AppBar(title: const Text("Choose a Module")),
        body: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: GridView.count(
            crossAxisCount: columns,
            crossAxisSpacing: spacing.lg,
            mainAxisSpacing: spacing.lg,
            childAspectRatio: ResponsiveLayout.isSmall(context)
                ? 3.5 / textScale
                : 1.6 / textScale,
            children: const [
              _ModuleCard(
                title: "Passwords",
                description: "Learn how attackers break weak passwords.",
                icon: Icons.lock,
                route: "/password",
              ),
              _ModuleCard(
                title: "Encryption",
                description: "Understand how encryption protects your data.",
                icon: Icons.key,
                route: "/encryption",
              ),
              _ModuleCard(
                title: "Phishing",
                description: "Spot fake emails and protect yourself.",
                icon: Icons.search,
                route: "/phishing",
              ),
              _ModuleCard(
                title: "Social Engineering",
                description: "see how attackers manipulate people",
                icon: Icons.search,
                route: "/social",
              ),
              _ModuleCard(
                title: "Networking",
                description:
                    "see how everything hooks together and communicates",
                icon: Icons.search,
                route: "/networking",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          Navigator.pushNamed(context, widget.route);
        },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(spacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(spacing.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.08 : 0.04),
                  blurRadius: _pressed ? 10 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(spacing.md),
              splashColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    widget.icon,
                    size:
                        spacing.xl *
                        MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.2),
                  ),
                  SizedBox(height: spacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: spacing.sm),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
