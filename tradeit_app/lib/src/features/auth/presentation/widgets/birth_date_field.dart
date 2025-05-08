import 'package:flutter/material.dart';

class BirthDateField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const BirthDateField({
    super.key,
    required this.controller,
    this.hint = 'Selecione sua data de nascimento',
    this.icon = Icons.calendar_today,
    this.validator,
  });

  @override
  State<BirthDateField> createState() => _BirthDateFieldState();
}

class _BirthDateFieldState extends State<BirthDateField> {
  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      widget.controller.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: Colors.deepPurple),
            hintText: widget.hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}