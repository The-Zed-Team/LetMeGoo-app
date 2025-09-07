import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';

class LoginActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool showConnector;

  const LoginActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.showConnector = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 50),
        Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: color,
              ),
              child: Center(child: Icon(icon, color: Colors.white)),
            ),
            if (showConnector)
              Column(
                children: List.generate(2, (_) {
                  return Container(
                    width: 2,
                    height: 15,
                    margin: const EdgeInsets.symmetric(vertical: 1.5),
                    color: Color(0xFF31C5F4),
                  );
                }),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(label, style: AppFonts.regular16()),
          ),
        ),
      ],
    );
  }
}
