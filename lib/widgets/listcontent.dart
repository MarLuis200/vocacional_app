import 'package:flutter/material.dart';

class ContentDisplay extends StatelessWidget {
  const ContentDisplay({
    Key? key,
    required Map<String, bool> questions,
  })  : _questions = questions,
        super(key: key);

  final Map<String, bool> _questions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.brown,
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions.keys.elementAt(index);
          final answer = _questions.values.elementAt(index);
          final number = index + 1;

          return ListTileTheme(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            // tileColor: Colors.grey[900],
            dense: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: ListTile(
              leading: Text(
                '${number.toInt()}.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              title: Text(
                question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                answer.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
