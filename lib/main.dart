import 'package:flutter/material.dart';
import 'package:uniswap_app/app.dart';
import 'package:uniswap_app/services/data_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DataRepository.instance.init();
  runApp(const UniSwapApp());
}
