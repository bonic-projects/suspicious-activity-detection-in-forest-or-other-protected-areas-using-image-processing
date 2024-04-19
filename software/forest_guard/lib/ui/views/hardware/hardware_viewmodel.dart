import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
//main.dart
// import "dart:async";

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

// import 'package:vision/ui/setup_snackbar_ui.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/imageprocessing_service.dart';
import '../../../services/regula_service.dart';
import '../../../services/tts_service.dart';

// import 'package:html/parser.dart' as parser;
// import 'package:html/dom.dart' as dom;

class HardwareViewModel extends BaseViewModel {
  final log = getLogger('HardwareViewModel');

  final _snackBarService = locator<SnackbarService>();
  final TTSService _ttsService = locator<TTSService>();
  final ImageProcessingService _imageProcessingService =
      locator<ImageProcessingService>();

  // final _navigationService = locator<NavigationService>();
  final _ragulaService = locator<RegulaService>();

  File? _image;

  File? get imageSelected => _image;

  List<String> _labels = <String>[];

  List<String> get labels => _labels;

  String? _ip;

  String? get ip => _ip;

  void onModelReady() async {
    setBusy(true);
    log.i("Model ready");

    _ip = "192.168.29.137";
    setBusy(false);

    _subscription = PerfectVolumeControl.stream.listen((value) {
      if (_image != null && !isBusy) {
        log.i("Volume button got!");
        workLabel();
      }
    });
  }

  late StreamSubscription<double> _subscription;

  @override
  void dispose() {
    // call your function here
    _subscription.cancel();
    super.dispose();
  }

  void workLabel() async {
    setBusy(true);
    await getImageFromHardware();
    // await getImageFromHardware();
    // await getImageFromHardware();
    if (_image != null) await getLabel();
  }

  void setIp(String ipIn) {
    _ip = ipIn;
    log.i("set Ip called $ipIn");
    notifyListeners();
  }

  // getting labels
  Future getLabel() async {
    log.i("Getting label");
    _labels = <String>[];

    _labels = await _imageProcessingService.getLabelFromImage(_image!);

    setBusy(false);

    String text = _imageProcessingService.processLabels(_labels);
    await _ttsService.speak(text);
    if (text == "Person detected") {
      await Future.delayed(const Duration(milliseconds: 2000));
      return processFace();
    } else  if (text == "Dog") {
      await Future.delayed(const Duration(milliseconds: 1000));
      await _ttsService.speak("Hunters may be present");
      return;
    }
  }

  void processFace() async {
    _ttsService.speak("Identifying person");
    setBusy(true);
    String? person = await _ragulaService.checkMatch(_image!.path);
    setBusy(false);
    if (person != null) {
      _labels.clear();
      _labels.add(person);
      notifyListeners();
      await _ttsService.speak(person);
      await Future.delayed(const Duration(milliseconds: 1500));
    } else {
      await _ttsService.speak("Not identified!");
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    log.i("Person: $person");
  }
  //

  //*******Getting Texts*******

  // Future captureImageAndText() async {
  //   _image = await _camService.takePicture();
  //   getText();
  // }

  Future workText() async {
    setBusy(true);
    await getImageFromHardware();
    // await getImageFromHardware();
    // await getImageFromHardware();
    if (_image != null) getText();
  }

  String? _text;

  String get text => _text.toString();

  void getText() async {
    setBusy(true);
    log.i("Getting Text");

    _text = await _imageProcessingService.getTextFromImage(_image!);

    setBusy(false);

    // _image != await _ttsService.speak(_texts);

    if (_image != null) {
      await _ttsService.speak(_text.toString());
    } else {
      await _ttsService.speak('Not Detected');
    }
  }

  //********//

  Uint8List? _img;

  Uint8List? get img => _img;

  // bool _isCalled = false;

  Future getImageFromHardware() async {
    log.i("Calling..");
    // _isCalled = true;

    Uri uri = Uri(scheme: 'http', host: ip!, path: 'snapshot');

    try {
      http.Response response = await http.get(uri);
      log.i("Status Code: ${response.statusCode}");
      log.i("Content Length: ${response.contentLength}");
      // log.i("Content Length: ${response.body}");
      //;------------
      _img = response.bodyBytes;
      // log.i(_img);
      //
      if (_image != null) {
        _image!.delete();
      } else {
        final directory = await getApplicationDocumentsDirectory();
        _image = await File('${directory.path}/image.png').create();
      }
      return _image!.writeAsBytes(_img!);
    } catch (e) {
      log.i("Error: $e");
    }
  }
}
