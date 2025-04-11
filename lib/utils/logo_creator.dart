import 'package:flutter/material.dart';
import 'package:life_track/main.dart';

class LogoPainter extends CustomPainter {
  final Color color;
  
  LogoPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1;
      
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width * 0.4;
    
    // Dibuja un círculo para la cabeza
    canvas.drawCircle(
      Offset(centerX, centerY - radius * 0.3),
      radius * 0.6,
      paint,
    );
    
    // Dibuja una línea para el cuerpo
    canvas.drawLine(
      Offset(centerX, centerY + radius * 0.4),
      Offset(centerX, centerY + radius),
      paint,
    );
    
    // Dibuja las líneas para los brazos
    canvas.drawLine(
      Offset(centerX, centerY + radius * 0.4),
      Offset(centerX - radius * 0.6, centerY + radius * 0.2),
      paint,
    );
    
    canvas.drawLine(
      Offset(centerX, centerY + radius * 0.4),
      Offset(centerX + radius * 0.6, centerY + radius * 0.2),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoWidget extends StatelessWidget {
  final double size;
  final Color color;
  
  const LogoWidget({
    super.key,
    this.size = 100,
    this.color = Colors.white,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(125),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.6,
          height: size * 0.6,
          child: CustomPaint(
            painter: LogoPainter(color: color),
          ),
        ),
      ),
    );
  }
} 