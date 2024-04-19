import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/ui_helpers.dart';
import 'tensorflow_viewmodel.dart';

class TensorflowView extends StackedView<TensorflowViewModel> {
  const TensorflowView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TensorflowViewModel model,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Scaffold(
        appBar: AppBar(
          title: const Text('Smartphone'),
          actions: [
            IconButton(
              onPressed: () {
                print("icon b");
                model.speak("This is test speech output");
              },
              icon: const Icon(Icons.volume_up),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            horizontalSpaceTiny,
            Row(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // model.getImageCamera();
                    model.captureImageAndLabel();
                  },
                  tooltip: 'camera',
                  child: Icon(Icons.add_a_photo),
                  heroTag: null,
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    model.getImageGallery();
                  },
                  tooltip: 'gallery',
                  child: Icon(Icons.image),
                  heroTag: null,
                )
              ],
            )
          ],
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: Container(
            child: model.imageSelected != null
                ? Column(
              children: [
                Expanded(child: Image.file(model.imageSelected!)),
                if (model.label != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      model.label!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                TextButton(
                  onPressed: () {
                    model.getLabel();
                    // print("get label");
                  },
                  child: const Text(
                    "Get label",
                  ),
                ),
              ],
            )
                : CameraPreview(model.controller),

            // const Text("No images selected!")
          ),
        ),
      ),
    );
  }

  @override
  TensorflowViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TensorflowViewModel();

  @override
  void onViewModelReady(TensorflowViewModel viewModel) {
    viewModel.onModelReady();
    super.onViewModelReady(viewModel);
  }
}
