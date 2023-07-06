import 'package:flutter/material.dart';

class Dialogs{
  static void showSnackbar(BuildContext context ,String msg)
  {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: TextStyle(color: const Color.fromARGB(37,37,53,109).withOpacity(0.9)),),
          backgroundColor: const Color.fromARGB(103,103,176,255).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
        ));
  }
  static void showProgressbar(BuildContext context)
  {
    showDialog(context: context, builder: (_)=> const Center(child: CircularProgressIndicator(),));
  }
}