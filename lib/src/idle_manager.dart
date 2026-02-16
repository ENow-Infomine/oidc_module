import 'dart:async';
import 'package:flutter/material.dart';

class IdleManager extends StatefulWidget {
  final Widget child;
  final Duration idleDuration;
  final Duration warningDuration;
  final VoidCallback onLogout;

  const IdleManager({
    super.key,
    required this.child,
    required this.idleDuration,
    required this.warningDuration,
    required this.onLogout,
  });

  @override
  State<IdleManager> createState() => _IdleManagerState();
}

class _IdleManagerState extends State<IdleManager> {
  Timer? _idleTimer;
  Timer? _warningTimer;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _warningTimer?.cancel();
    _idleTimer = Timer(widget.idleDuration, _showWarningDialog);
  }

  void _showWarningDialog() {
    if (_isDialogOpen || !mounted) return;
    setState(() => _isDialogOpen = true);

    _warningTimer = Timer(widget.warningDuration, () {
      if (_isDialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        widget.onLogout();
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Inactivity Warning"),
        content: const Text("You have been inactive for a while. You will be logged out shortly. Are you still there?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleUserReturned();
            },
            child: const Text("I'M STILL HERE"),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() => _isDialogOpen = false);
    });
  }

  void _handleUserReturned() {
    _warningTimer?.cancel();
    _startIdleTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _isDialogOpen ? null : _handleUserReturned(),
      onPointerMove: (_) => _isDialogOpen ? null : _handleUserReturned(),
      onPointerHover: (_) => _isDialogOpen ? null : _handleUserReturned(),
      child: Focus(
        onKeyEvent: (node, event) {
          if (!_isDialogOpen) _handleUserReturned();
          return KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }
}