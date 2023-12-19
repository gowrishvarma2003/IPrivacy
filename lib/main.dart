import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as imageLib;
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
// import 'package:pointycastle/pointycastle.dart';
// import 'package:pointycastle/api.dart';
// import 'dart:convert';
// import 'package:pointycastle/api.dart';
// import 'package:password_hash/password_hash.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ximage(),
    );
  }
}

class ximage extends StatefulWidget {
  @override
  _ximageState createState() => _ximageState();
}

class _ximageState extends State<ximage> {
  List<List<int>>? pixelArray;
  Uint8List? imageBytes; // Store the image bytes
  MemoryImage? memoryImage; // Store the MemoryImage object

  // void _processImage() async {
  //   final ByteData data = await rootBundle.load('assets/123.jpg');
  //   final buffer = data.buffer.asUint8List();
  //   final image = imageLib.decodeImage(Uint8List.fromList(buffer));

  //   setState(() {
  //     pixelArray = imageToPixelArray(image);
  //   });
  // }

  void _processImage() async {
    final ByteData data = await rootBundle.load('assets/X.jpg');
    final buffer = data.buffer.asUint8List();
    final image = imageLib.decodeImage(Uint8List.fromList(buffer));

    setState(() {
      pixelArray = imageToPixelArray(image);
      // Convert the pixel array back to an image
      // final image1 = pixelArrayToImage(pixelArray!);

      // // Encode the image as bytes
      // final List<int> pngBytes = imageLib.encodePng(image1);

      // // Update imageBytes and memoryImage with the new image data
      // imageBytes = Uint8List.fromList(pngBytes);
      // memoryImage = MemoryImage(imageBytes!);
    });
    Uint8List encryptionKey = Uint8List.fromList(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
    print(encryptPixelArray(pixelArray!, encryptionKey));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // if (memoryImage != null)
          //   Image(
          //     image: memoryImage!,
          //   ),
          ButtonBar(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50),
                child: TextButton(
                  onPressed: () {
                    _processImage(); // Call the function to process the image
                  },
                  child: Text("Do it!"),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<List<int>> imageToPixelArray(imageLib.Image? image) {
    if (image == null) {
      return [];
    }

    List<List<int>> result = [];
    print(image.height);
    print(image.width);
    for (int i = 0; i < image.height; i++) {
      List<int> row = [];
      for (int j = 0; j < image.width; j++) {
        row.add(image.getPixel(j, i));
      }
      result.add(row);
    }
    print(result);
    // Convert the pixel array back to an image
    imageLib.Image image1 = pixelArrayToImage(result);

    return result;
  }

  List<List<int>> encryptPixelArray(
      List<List<int>> pixelArray, Uint8List encryptionKey) {
    final CipherParameters params = PaddedBlockCipherParameters(
      ParametersWithIV(
          KeyParameter(encryptionKey), Uint8List(16)), // IV is set to zero
      null,
    );

    final BlockCipher encryptionCipher = PaddedBlockCipher("AES/CBC/PKCS7")
      ..init(true, params);

    return pixelArray.map((row) {
      return row.map((pixelValue) {
        final Uint8List input = Uint8List.fromList([pixelValue]);
        final Uint8List encryptedData = encryptionCipher.process(input);
        return encryptedData[0];
      }).toList();
    }).toList();
  }

  imageLib.Image pixelArrayToImage(List<List<int>> pixelArray) {
    int height = pixelArray.length;
    int width = pixelArray.isNotEmpty ? pixelArray[0].length : 0;

    imageLib.Image image = imageLib.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixelValue = pixelArray[y][x];
        image.setPixel(x, y, pixelValue);
      }
    }
    return image;
  }
}
