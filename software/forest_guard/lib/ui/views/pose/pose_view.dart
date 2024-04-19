import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/ui_helpers.dart';
import 'pose_viewmodel.dart';

class PoseView extends StackedView<PoseViewModel> {
  const PoseView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PoseViewModel model,
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
            horizontalSpaceMedium,
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
                            Expanded(child: Stack(
                              children: [
                                Image.file(model.imageSelected!),
                                if (model.customPaint != null)
                                Icon(Icons.person),
                                  if (model.customPaint != null)
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    child: model.customPaint!),
                              ],
                            )),
                            if (model.labels.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  model.labels.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: IconButton(
                            //     icon: Icon(Icons.volume_down_outlined),
                            //     onPressed: model.getLabel,
                            //   ),
                            // ),
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
  PoseViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PoseViewModel();

  @override
  void onViewModelReady(PoseViewModel viewModel) {
    viewModel.onModelReady();
    super.onViewModelReady(viewModel);
  }
}
