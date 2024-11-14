import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;

  const CustomLoader({
    Key? key,
    this.message,
    this.size = 50.0,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 4.0,
            color: color,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 10),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
