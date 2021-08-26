import 'package:flutter/material.dart';
import 'package:image_scan/model.dart';

class Detail extends StatefulWidget {
  final Model _model;
  const Detail(this._model, {Key? key}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('details: ${widget._model.alltext!}'),
            Text('pharese1: ${widget._model.phrase1}'),
            Text('pharese2: ${widget._model.pharese2!}'),
          ],
        ),
      ),
    );
  }
}
