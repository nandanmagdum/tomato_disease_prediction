import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? pickedImage;
  XFile? image;
  bool isButtonPressedCamera = false;
  bool isButtonPressedGallery = false;
  Color backgroundColor = Color(0xffe9edf1);
  Color secondaryColor = Color(0xffe1e6ec);
  Color accentColor = Color(0xff2d5765);

  List? results;
  String confidence = "";
  String name = "";
  String crop_name = "";
  String disease_name = "";
  String disease_url = "";
  bool result_visibility = false;

  applyModelOnImage(File file) async {
    var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      results = res!;
      // print(results);
      String str = results![0]["label"];
      name = str.substring(2);
      confidence = results != null
          ? (results![0]["confidence"] * 100.0).toString().substring(0, 5) + "%"
          : "";
      print(name);
      print(confidence);
      split_model_result();
    });
  }

  void split_model_result() {
    List temp = name.split(' ');
    crop_name = temp[0];
    temp.removeAt(0);
    disease_name = temp.join(' ');
    print(crop_name);
    print(disease_name);
  }

  Future getImage(ImageSource source) async {
    try {
      image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      } else {
        final imageTemporary = File(image!.path);
        setState(() {
          pickedImage = imageTemporary;
          applyModelOnImage(pickedImage!);
          // result_visibility = true;
          // isButtonPressedCamera = false;
          // isButtonPressedGallery = false;
        });
      }
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  Future loadModel() async {
    // String modelPath = ModelPathSelector();
    // print(modelPath);
    // ignore: unused_local_variable
    var resultant = await Tflite.loadModel(
        model: "assets/Tomato/model.tflite",
        labels: "assets/Tomato/labels.txt");

    // print("Result after loading model: $resultant");
  }

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disease Prediction"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getImage(ImageSource.gallery);
        },
        child: Text("Pick Image"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
          ),
          image == null
              ? Text("Image not selected")
              : Image.file(File(image!.path)),
          Text("Disease: ${name}"),
          Text("confidance: ${confidence}"),
          Text("Crop: ${crop_name}"),
          Text("Disease name: ${disease_name}"),
        ],
      ),
    );
  }
}
