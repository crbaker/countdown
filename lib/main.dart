import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' as picker;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Countdown Assistant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _pickedFile;
  String _detectedText = "";
  List<String> _solutions = [];

  Future _pickImage() async {
    File tempFile =
        await picker.ImagePicker.pickImage(source: picker.ImageSource.camera);

    setState(() {
      _pickedFile = tempFile;
    });

    _detectText(_pickedFile);
  }

  Future _detectText(File tempFile) async {
    FirebaseVisionImage image = FirebaseVisionImage.fromFile(tempFile);
    TextRecognizer recognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await recognizer.processImage(image);

    var buffer = new StringBuffer();

    visionText.blocks.forEach((block) {
      block.lines.forEach((line) {
        line.elements.forEach((element) {
          buffer.write(element.text);
        });
      });
    });

    _findWords(buffer.toString());

    setState(() {
      _detectedText = buffer.toString();
    });
  }

  Future _findWords(String detectedText) async {
    String data = await rootBundle.loadString('assets/files/words.txt');
    var allWords = data.split('\n');
    var filteredSet =
        allWords.where((word) => word.length <= detectedText.length);

    var matching = filteredSet
        .where((word) =>
            _fitsIn(word.toLowerCase(), detectedText.toLowerCase().split("")))
        .map((s) => s.toLowerCase())
        .toList();

    matching.sort((t, o) {
      if (o.length.compareTo(t.length) == 0) {
        return t.compareTo(o);
      } else {
        return o.length.compareTo(t.length);
      }
    });

    setState(() {
      _solutions = matching.take(100).toList();
    });
  }

  bool _fitsIn(String word, List<String> refenceLetters) {
    var ll = word;
    refenceLetters.forEach((letter) {
      ll = ll.replaceFirst(letter, "");
    });
    return ll.length == 0;
  }

  @override
  Widget build(BuildContext context) {
    var previewWidget = _pickedFile != null
        ? Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.scaleDown, image: FileImage(_pickedFile))),
          )
        : Container();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Center(
          child: ListView(
            children: <Widget>[
              Center(
                child: previewWidget,
              ),
              IconButton(
                  icon: Icon(Icons.camera, size: 30, color: Colors.teal),
                  onPressed: _pickImage),
              Center(
                child: Text(
                  _detectedText,
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              ..._solutions.map((s) {
                return Center(child: Text(s));
              }).toList()
            ],
          ),
        ),
      ),
    );
  }
}
