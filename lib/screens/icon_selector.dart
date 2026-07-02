import 'package:flutter/material.dart';
import '../utils/icons.dart';
import '../widgets/widgets.dart';

class IconSelector extends StatelessWidget {
  final String selectedIconPath;

  const IconSelector({super.key, required this.selectedIconPath});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithGradient(
      appBar: CustomAppBar(title: 'Select Icon'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildIconGrid(context),
      ),
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.25),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: iconMap.keys.map((iconPath) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop(iconPath);
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: selectedIconPath == iconPath
                    ? Colors.blueAccent
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                getIcon(iconName: iconPath),
                color: selectedIconPath == iconPath
                    ? Colors.white
                    : Colors.black,
                size: 30.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
