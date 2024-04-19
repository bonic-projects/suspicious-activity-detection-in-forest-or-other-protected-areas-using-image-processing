import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tflite/tflite.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/camera_service.dart';
import '../../../services/imageprocessing_service.dart';
import '../../../services/tts_service.dart';

class TensorflowViewModel extends BaseViewModel {
  final log = getLogger('TensorflowViewModel');

  final _snackBarService = locator<SnackbarService>();

  final TTSService _ttsService = locator<TTSService>();
  final ImageProcessingService _imageProcessingService =
  locator<ImageProcessingService>();
  final _camService = locator<CameraService>();


  CameraController get controller => _camService.controller;
  late StreamSubscription<double> _subscription;

  void onModelReady() async {
    initModel();
    _subscription = PerfectVolumeControl.stream.listen((value) {
      if (_image == null && !isBusy) {
        captureImageAndLabel();
      }
      if (_image != null && !isBusy) {
        log.i("Volume button got!");
        getLabel();
      }
    });
    setBusy(true);
    await _camService.initCam();
    setBusy(false);
    // setTimer();//todo
  }

  Future captureImageAndLabel() async {
    _image = await _camService.takePicture();
    getLabel();
  }

  Timer? _timer;

  void setTimer() {
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) async {
      log.i("Timer got!");
      if (_image == null && !isBusy) {
        captureImageAndLabel();
      }
      if (_image != null && !isBusy) {
        getLabel();
      }
    });
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  File? _image;

  File? get imageSelected => _image;

  // InputImage? _inputImage;

  getImageCamera() async {
    setBusy(true);
    // picking image
    _imageFile = await _picker.pickImage(source: ImageSource.camera);

    if (_imageFile != null) {
      log.i("CCC");
      // _dlibService.addImageFace(await _imageFile!.readAsBytes());
      _image = File(_imageFile!.path);
    } else {
      _snackBarService.showSnackbar(message: "No images selected");
    }
    setBusy(false);
  }

  getImageGallery() async {
    setBusy(true);
    // picking image
    _imageFile = await _picker.pickImage(source: ImageSource.gallery);

    if (_imageFile != null) {
      _image = File(_imageFile!.path);
    } else {
      _snackBarService.showSnackbar(message: "No images selected");
    }
    setBusy(false);
  }

  Future speak(String text) async {
    _ttsService.speak(text);
  }
  ///============================================================================

  void initModel() async {
    String? res;
    res = await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
    log.i(res);
  }

  Future<bool> getLabel() async {
    log.i("Deciding ring condition");
    try {
      final output = await Tflite.runModelOnImage(
        path: _image!.path,
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
      );
      bool c = processRecognitions(output);
      return c;
    } catch (e) {
      log.e("Error occurred: $e");
      return false;
    }
  }

  String? label;
  double? confidence;

  bool processRecognitions(outputs) {
    log.i(outputs);
    label = outputs[0]['label'].split(" ").last;
    confidence = outputs[0]['confidence'];
    notifyListeners();
    log.i(confidence);
    if (label == outputs[0]['label']) {
      speak("Label 1 detected");
      if (confidence! > 0.90) return true;
    }
    return false;
  }


  @override
  void dispose() {
    // call your function here
    Tflite.close();
    _camService.dispose();
    _subscription.cancel();
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    super.dispose();
  }
}
