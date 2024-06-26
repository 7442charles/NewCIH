import 'package:Recitte/components/contentpage.dart';
import 'package:flutter/material.dart';

class FishIntroduction extends StatelessWidget {
  const FishIntroduction({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentPage(
      appBarTitle: 'Fish & ShellFish',
      markdownPath: 'assets/markdowns/fishShellFish/fish_introduction.md',
      errorMessage: 'Error loading ',
    );
  }
}
