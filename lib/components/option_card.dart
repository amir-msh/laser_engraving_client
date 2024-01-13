import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback? onTap;
  const OptionCard({
    required this.title,
    required this.icon,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 6,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.deepOrange[800]!.withOpacity(0.15),
          splashColor: Colors.white70,
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: 19),
              IconTheme(
                data: IconThemeData(
                  size: 43,
                  color: Theme.of(context).iconTheme.color,
                ),
                child: icon,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
