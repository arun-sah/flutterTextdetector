
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_scan/detail.dart';
import 'package:image_scan/model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PDFDocument? _scannedDocument;
  File? _scannedDocumentFile;
  File? _scannedImage;
  String alltext = '';
  String pharese1 = '';
  String phares2 = '';

  openPdfScanner(BuildContext context) async {
    var doc = await DocumentScannerFlutter.launchForPdf(
      context,
      labelsConfig: {
        ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next Steps",
        ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_SINGLE: "Only 1 Page",
        ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_MULTIPLE:
            "Only {PAGES_COUNT} Page"
      },
      //source: ScannerFileSource.CAMERA
    );
    if (doc != null) {
      _scannedDocument = null;
      setState(() {});
      await Future.delayed(Duration(milliseconds: 100));
      _scannedDocumentFile = doc;
      _scannedDocument = await PDFDocument.fromFile(doc);
      setState(() {});
    }
  }

  openImageScanner(BuildContext context) async {
    // var cardDetails = await CardScanner.scanCard(
    //   scanOptions: CardScanOptions(
    //     scanCardHolderName: true,
    //   ),
    // );

    // print(cardDetails);

    var image = await DocumentScannerFlutter.launch(context,
        //source: ScannerFileSource.CAMERA,
        labelsConfig: {
          ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next Step",
          ScannerLabelsConfig.ANDROID_OK_LABEL: "OK"
        });
    if (image != null) {
      // Google ML Vision

      _scannedImage = image;
      var file = File(image.path.toString());
      // final inputImage = InputImage.fromFile(file);
      final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(file);
      final ImageLabeler labeler = GoogleVision.instance.imageLabeler();
      final TextRecognizer textRecognizer =
          GoogleVision.instance.textRecognizer();

// final ImageLabeler labeler = GoogleVision.instance.imageLabeler(
//   ImageLabelerOptions(confidenceThreshold: 0.75),
// );
      final List<ImageLabel> labels = await labeler.processImage(visionImage);
      final VisionText visionText =
          await textRecognizer.processImage(visionImage);

      for (ImageLabel label in labels) {
        final String? text = label.text;
        final String? entityId = label.entityId;
        final double? confidence = label.confidence;

        print('ImageLabel ------------');
        print('$text \n $entityId \n $confidence');

        pharese1 += label.text ?? 'phares1';
      }

      phares2 = visionText.text ?? 'pharese 2';
      print('phares2 test =====$phares2');
      for (TextBlock block in visionText.blocks) {
        final Rect? boundingBox = block.boundingBox;
        final List<Offset> cornerPoints = block.cornerPoints;
        final String? text = block.text;
        final List<RecognizedLanguage> languages = block.recognizedLanguages;

        print('ImageLabel ------------');
        print('$text \n $boundingBox \n $cornerPoints \n $languages');

        for (TextLine line in block.lines) {
          print(
              '${line.elements}\n${line.text}\n${line.recognizedLanguages}\n ${line.cornerPoints}\n-------------------');

          // Same getters as TextBlock
          for (TextElement element in line.elements) {
            alltext += '  ${element.text} ';
            // Same getters as TextBlock
            print('TextElement detected--------------');
            print(
                '\n${element.text}\n${element.boundingBox}\n ${element.cornerPoints}\n-------------------');
          }
        }
      }

      var model = Model(alltext: alltext, phrase1: pharese1, pharese2: phares2);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Detail(model)),
      );

      // final imageLabeler = GoogleMlKit.vision.imageLabeler();

      // final List<ImageLabel> labels =
      //     await imageLabeler.processImage(inputImage);

      // final textDetector = GoogleMlKit.vision.textDetector();
      // final RecognisedText recognisedText =
      //     await textDetector.processImage(inputImage);

      // for (ImageLabel label in labels) {
      //   final String text = label.label;
      //   final int index = label.index;
      //   final double confidence = label.confidence;

      //   print('label detected--------------');
      //   print('$text\n$index\n$confidence\n-------------------');
      // }

      // String text = recognisedText.text;
      // for (TextBlock block in recognisedText.blocks) {
      //   final Rect rect = block.rect;
      //   final List<Offset> cornerPoints = block.cornerPoints;
      //   final String text = block.text;
      //   final List<String> languages = block.recognizedLanguages;

      //   print('TextBlock detected--------------');
      //   print('$rect\n$cornerPoints\n$text\n $languages\n-------------------');

      //   for (TextLine line in block.lines) {
      //     print('TextLine detected--------------');
      //     print(
      //         '${line.elements}\n${line.text}\n${line.recognizedLanguages}\n ${line.cornerPoints}\n-------------------');
      //     // Same getters as TextBlock
      //     for (TextElement element in line.elements) {
      //       // Same getters as TextBlock
      //       print('TextElement detected--------------');
      //       print(
      //           '\n${element.text}\n${element.rect}\n ${element.cornerPoints}\n-------------------');
      //     }
      //   }
      // }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Document Scanner Demo'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_scannedDocument != null || _scannedImage != null) ...[
              if (_scannedImage != null)
                Image.file(_scannedImage!,
                    width: 300, height: 300, fit: BoxFit.contain),
              if (_scannedDocument != null)
                Expanded(
                    child: PDFViewer(
                  document: _scannedDocument!,
                )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    _scannedDocumentFile?.path ?? _scannedImage?.path ?? ''),
              ),
            ],
            Center(
              child: Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () => openPdfScanner(context),
                    child: Text("PDF Scan"));
              }),
            ),
            Center(
              child: Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () => openImageScanner(context),
                    child: Text("Image Scan"));
              }),
            )
          ],
        ),
      ),
    );
  }
}
