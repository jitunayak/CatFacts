import 'package:flutter/cupertino.dart';

class Tick extends StatelessWidget {
  final bool isSelected;
  const Tick({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {}, // Empty onPressed as it's just a visual indicator
      child: isSelected
          ? Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: CupertinoTheme.of(context).brightness == Brightness.dark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.activeBlue,
            )
          : const SizedBox(height: 20),
    );
  }
}
