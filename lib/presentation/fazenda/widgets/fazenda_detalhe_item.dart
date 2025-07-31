import 'package:flutter/material.dart';

class FazendaDetalheItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isTitle;
  const FazendaDetalheItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: isTitle ? Colors.white : Colors.black,
          size: isTitle ? 24 : 20,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTitle ? 18 : 16,
            color: isTitle ? Colors.white : Colors.black,
          ),
        ),
        if (value.isNotEmpty && !isTitle) ...[
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else if (isTitle && value.isEmpty)
          ...[]
        else if (isTitle) ...[
          Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
