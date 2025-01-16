import 'package:blurhash_shader/blurhash_shader.dart';
import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List"),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return BlurHash(
                r"rLLXc8J7.Ao~9FIAkXITR,_3=|soM_M{bca#kCRj.9adD%IUs,%gi^R*n%-;RjMxtRbwRPkXofkCR3bbnO%Mx]MxRjazWXO@jFtSRjjYbbR5ozs:");
          }),
    );
  }
}
