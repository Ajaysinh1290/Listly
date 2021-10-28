import 'package:flutter/material.dart';

class FullImage extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final bool? showAppBar;

  const FullImage(
      {Key? key,
      required this.imageUrl,
      required this.heroTag,
      this.showAppBar})
      : super(key: key);

  @override
  State<FullImage> createState() => _FullImageState();
}

class _FullImageState extends State<FullImage>
    with SingleTickerProviderStateMixin {
  final _transformationController = TransformationController();

  late TapDownDetails _doubleTapDetails;
  late AnimationController _animationController;
  late Animation<Matrix4> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        _transformationController.value = _animation.value;
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    Matrix4 _endMatrix;
    Offset _position = _doubleTapDetails.localPosition;

    if (_transformationController.value != Matrix4.identity()) {
      _endMatrix = Matrix4.identity();
    } else {
      _endMatrix = Matrix4.identity()
        ..translate(-_position.dx * 2, -_position.dy * 2)
        ..scale(3.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: _endMatrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.showAppBar ?? true)
          ? AppBar(title: const Text('Photo'))
          : null,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: GestureDetector(
            onDoubleTap: _handleDoubleTap,
            onDoubleTapDown: _handleDoubleTapDown,
            child: InteractiveViewer(
              transformationController: _transformationController,
              maxScale: 5.0,
              child: Hero(
                tag: widget.heroTag,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
