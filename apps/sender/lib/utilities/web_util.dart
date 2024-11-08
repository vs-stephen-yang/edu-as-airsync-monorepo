import 'package:flutter/material.dart';

bool isBigThan768(context) => MediaQuery.of(context).size.width >= 768;

bool isBigThan1024(context) => MediaQuery.of(context).size.width >= 1024;

bool isBigThan1280(context) => MediaQuery.of(context).size.width >= 1280;

bool isBigThan1536(context) => MediaQuery.of(context).size.width >= 1536;

bool isBigThan1920(context) => MediaQuery.of(context).size.width >= 1920;
