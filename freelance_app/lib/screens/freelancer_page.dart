import 'package:flutter/material.dart';

class FreelancersPage extends StatelessWidget {
  const FreelancersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.group, size: 64, color: Colors.deepPurple),
          SizedBox(height: 16),
          Text(
            "Freelancers page - to be implemented",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
