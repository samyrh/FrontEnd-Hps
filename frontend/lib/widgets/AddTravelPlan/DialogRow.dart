import 'package:flutter/cupertino.dart';

Widget buildDialogRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
        ),
      ],
    ),
  );
}
