import 'package:flutter/material.dart';

const TextStyle defaultHeaderTextStyle = const TextStyle(
  fontSize: 20.0,
  color: Colors.black,
);

const TextStyle defaultPlaneTextStyle = const TextStyle(
  fontSize: 14.0,
  color: Colors.black,
);

const TextStyle defaultScheduleTextStyle = const TextStyle(
  fontSize: 14.0,
  color: Colors.white,
);

const Color defaultCurrentDateTimeDividerColor = Colors.red;

BoxDecoration defaultScheduleBox(Color color){
  return BoxDecoration(
    border: Border.all(color: color),
    borderRadius: BorderRadius.circular(8),
    color: color,
  );
}

const BorderSide defaultBorderSide = const BorderSide(
  color: Colors.grey,
  width: 0,
);