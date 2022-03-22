import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    /**
     * Trace l'arc de cercle intérieur et le rempli de l'extérieur
     *
     * param :
     *     - canvas (Canvas)
     *     - size (Size)
     */
    var paint = Paint();
    // La couleur de remplissage
    paint.color = Colors.grey.shade100;
    // On indique qu'on rempli la surface délimitée par la courbe que l'on va tracer
    paint.style = PaintingStyle.fill;

    var path = Path();
    // On commence en haut à gauche
    path.moveTo(0, 0);
    // On trace un arc de cercle
    final center = Offset(size.width, 0);
    const startAngle = -3.14;
    const endAngle = -3.14 / 2;
    path.arcTo(Rect.fromCircle(center: center, radius: 70), startAngle,
        endAngle, true);
    // On ferme la courbe
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
