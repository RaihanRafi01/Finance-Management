import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower animation
    )..repeat(); // Remove reverse for continuous loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Layer with Animated Objects
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPainter(animation: _controller),
                );
              },
            ),
          ),

          // Foreground Layer with Login Card
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Card
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Login", style: TextStyle(fontSize: 24)),
                        SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Login"),
                        ),
                      ],
                    ),
                  ),
                ),

                // Animated Overlapping Objects
                Positioned(
                  top: -50,
                  right: -50,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..translate(-50 * _controller.value, -50 * _controller.value)
                          ..rotateZ(-_controller.value * 2 * 3.14159), // Rotate around Z axis
                        child: Image.asset(
                          'assets/images/add_image.png',
                          width: 50,
                          height: 50,
                          color: Colors.red.withOpacity(0.2),
                          colorBlendMode: BlendMode.srcATop,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..translate(-50 * _controller.value, -50 * _controller.value)
                          ..rotateZ(-_controller.value * 2 * 3.14159), // Rotate around Z axis
                        child: Image.asset(
                          'assets/images/google.png',
                          width: 150,
                          height: 150,
                          color: Colors.green.withOpacity(0.2),
                          colorBlendMode: BlendMode.srcATop,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  BackgroundPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final rotation = animation.value * 2 * 3.14159; // Full rotation

    // Save the canvas state
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Draw rotating circles
    paint.color = Colors.blue.withOpacity(0.2);
    canvas.drawCircle(Offset(0, -200), 100, paint);

    paint.color = Colors.orange.withOpacity(0.3);
    canvas.drawCircle(Offset(0, 0), 120, paint);

    paint.color = Colors.purple.withOpacity(0.4);
    canvas.drawCircle(Offset(0, 200), 150, paint);

    // Restore the canvas state
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
