import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum _BmiGender { male, female }

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  _BmiGender _gender = _BmiGender.male;
  double _height = 170;
  int _weight = 70;
  int _age = 30;

  void _setWeight(int value) {
    setState(() => _weight = value.clamp(1, 300));
  }

  void _setAge(int value) {
    setState(() => _age = value.clamp(1, 120));
  }

  void _calculate() {
    final heightMeters = _height / 100;
    final bmi = _weight / math.pow(heightMeters, 2);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).background,
      builder: (context) {
        return _BmiResultPanel(bmi: bmi, gender: _gender, age: _age);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'BMI Calculator',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      label: 'Male',
                      icon: Icons.male,
                      isActive: _gender == _BmiGender.male,
                      onTap: () => setState(() => _gender = _BmiGender.male),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderCard(
                      label: 'Female',
                      icon: Icons.female,
                      isActive: _gender == _BmiGender.female,
                      onTap: () => setState(() => _gender = _BmiGender.female),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Panel(
                child: Column(
                  children: [
                    Text(
                      'Height',
                      style: TextStyle(
                        color: colors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_height.round()} cm',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      min: 80,
                      max: 220,
                      value: _height,
                      activeColor: colors.primary,
                      inactiveColor: colors.surfaceVariant,
                      onChanged: (value) {
                        setState(() => _height = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _CounterPanel(
                      label: 'Weight',
                      value: _weight,
                      suffix: 'kg',
                      onDecrease: () => _setWeight(_weight - 1),
                      onIncrease: () => _setWeight(_weight + 1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CounterPanel(
                      label: 'Age',
                      value: _age,
                      suffix: 'yrs',
                      onDecrease: () => _setAge(_age - 1),
                      onIncrease: () => _setAge(_age + 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Calculate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final backgroundColor = isActive ? colors.primary : colors.surfaceVariant;
    final foregroundColor = isActive ? colors.onPrimary : colors.onSurface;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: foregroundColor, size: 42),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterPanel extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CounterPanel({
    required this.label,
    required this.value,
    required this.suffix,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return _Panel(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: colors.muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '$value $suffix',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.small(
                heroTag: '$label-decrease',
                backgroundColor: colors.surfaceVariant,
                foregroundColor: colors.onSurface,
                onPressed: onDecrease,
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: '$label-increase',
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                onPressed: onIncrease,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: child,
    );
  }
}

class _BmiResultPanel extends StatelessWidget {
  final double bmi;
  final _BmiGender gender;
  final int age;

  const _BmiResultPanel({
    required this.bmi,
    required this.gender,
    required this.age,
  });

  String get _category {
    if (bmi < 18.5) {
      return 'Underweight';
    }
    if (bmi < 25) {
      return 'Normal';
    }
    if (bmi < 30) {
      return 'Overweight';
    }
    return 'Obese';
  }

  Color _categoryColor(AppColorScheme colors) {
    if (bmi < 18.5) {
      return colors.info;
    }
    if (bmi < 25) {
      return colors.success;
    }
    if (bmi < 30) {
      return colors.warning;
    }
    return colors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final categoryColor = _categoryColor(colors);
    final genderLabel = gender == _BmiGender.male ? 'Male' : 'Female';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _Panel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                bmi.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Text(
                    _category,
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ResultMetaTile(label: 'Gender', value: genderLabel),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultMetaTile(label: 'Age', value: '$age'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Recalculate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultMetaTile extends StatelessWidget {
  final String label;
  final String value;

  const _ResultMetaTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: colors.muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
