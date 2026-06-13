import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingStepper extends StatelessWidget {
  final int currentStep;

  const OnboardingStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StepItem(
            number: 1,
            title: "Information",
            state: _getState(1),
          ),
        ),

        _Connector(
          active: currentStep > 1,
        ),

        Expanded(
          child: _StepItem(
            number: 2,
            title: "Subscription",
            state: _getState(2),
          ),
        ),

        _Connector(
          active: currentStep > 2,
        ),

        Expanded(
          child: _StepItem(
            number: 3,
            title: "Admin Account",
            state: _getState(3),
          ),
        ),
      ],
    );
  }

  StepStateType _getState(int step) {
    if (step < currentStep) {
      return StepStateType.completed;
    }

    if (step == currentStep) {
      return StepStateType.current;
    }

    return StepStateType.pending;
  }
}

enum StepStateType {
  completed,
  current,
  pending,
}

class _StepItem extends StatelessWidget {
  final int number;
  final String title;
  final StepStateType state;

  const _StepItem({
    required this.number,
    required this.title,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Color textColor;

    switch (state) {
      case StepStateType.completed:
        borderColor = const Color(0xff0E8F62);
        backgroundColor = const Color(0xff0E8F62);
        textColor = Colors.white;
        break;

      case StepStateType.current:
        borderColor = const Color(0xff12308E);
        backgroundColor = Colors.white;
        textColor = const Color(0xff12308E);
        break;

      case StepStateType.pending:
        borderColor = const Color(0xffD7DCE5);
        backgroundColor = Colors.white;
        textColor = const Color(0xffA5AAB5);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: Center(
            child: state == StepStateType.completed
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 22,
            )
                : Text(
              "$number",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: state == StepStateType.pending
                ? const Color(0xffA5AAB5)
                : const Color(0xff1D2433),
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool active;

  const _Connector({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 28),
        height: 2,
        color: active
            ? const Color(0xff0E8F62)
            : const Color(0xffD7DCE5),
      ),
    );
  }
}
