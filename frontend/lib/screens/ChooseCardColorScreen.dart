import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'SuccessScreen.dart';

class ChooseCardColorScreen extends StatefulWidget {
  const ChooseCardColorScreen({Key? key}) : super(key: key);

  @override
  State<ChooseCardColorScreen> createState() => _ChooseCardColorScreenState();
}

class _ChooseCardColorScreenState extends State<ChooseCardColorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;

  late List<Gradient> gradients;
  late String cardType;
  late String packName;

  Gradient? selectedGradient;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🔥 Receive data from GoRouter
    final extras = GoRouterState.of(context).extra as Map<String, dynamic>;
    gradients = extras['gradients'] as List<Gradient>;
    cardType = extras['cardType'] as String;
    packName = extras['packName'] as String;

    // ✅ Set initial selectedGradient
    selectedGradient = gradients.first;
  }

  void _flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => isFront = !isFront);
  }

  Widget _animatedCardContainer({required Widget child}) {
    return TweenAnimationBuilder<Gradient>(
      tween: GradientTween(begin: selectedGradient!, end: selectedGradient!),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      builder: (context, gradient, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutExpo,
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildFront() {
    return _animatedCardContainer(
      child: Column(
        key: const ValueKey('front'),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Preview Card',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Icon(Icons.credit_card, color: Colors.white, size: 24),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(packName,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('**** **** ****',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 3)),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CARDHOLDER',
                      style: TextStyle(fontSize: 9, color: Colors.white54)),
                  SizedBox(height: 2),
                  Text('Nada S. Rhandor',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('EXPIRES',
                      style: TextStyle(fontSize: 9, color: Colors.white54)),
                  SizedBox(height: 2),
                  Text('**/**',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _animatedCardContainer(
      child: Column(
        key: const ValueKey('back'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CVV',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              Container(
                width: 60,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    '***',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Authorized Signature',
                  style: TextStyle(fontSize: 10, color: Colors.white54)),
              Text('Valid Thru **/**',
                  style: TextStyle(fontSize: 10, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        physics: const NeverScrollableScrollPhysics(),
        children: gradients.map((g) {
          final isSelected = selectedGradient == g;
          return GestureDetector(
            onTap: () => setState(() => selectedGradient = g),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.2 : 1.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: g,
                    border: isSelected
                        ? Border.all(
                        color: Colors.black.withOpacity(0.8), width: 2)
                        : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Choose Card Color',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E2D),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.chevron_left,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'You have selected the $packName ($cardType). Choose your preferred color below. '
                    'A request will be sent to your bank administrator for approval. '
                    'You can flip the card to preview both sides.',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5E5E6B),
                  height: 1.65,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final isFrontVisible = _animation.value <= pi / 2;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_animation.value),
                              child: isFrontVisible
                                  ? _buildFront()
                                  : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(pi),
                                child: _buildBack(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  _buildColorCircles(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessScreen(
                          cardType: cardType,
                          packName: packName,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for animating between gradients
class GradientTween extends Tween<Gradient> {
  GradientTween({required Gradient begin, required Gradient end})
      : super(begin: begin, end: end);

  @override
  Gradient lerp(double t) {
    final LinearGradient b = begin as LinearGradient;
    final LinearGradient e = end as LinearGradient;

    return LinearGradient(
      colors: List.generate(b.colors.length, (i) {
        return Color.lerp(b.colors[i], e.colors[i], t)!;
      }),
      begin: Alignment.lerp(b.begin as Alignment?, e.begin as Alignment?, t)!,
      end: Alignment.lerp(b.end as Alignment?, e.end as Alignment?, t)!,
    );
  }
}
