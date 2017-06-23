## CoreMLExample

In this example we use AVFoundation to continuously get image data from the back camera, and try to detect the dominant objects present in the image by using a pre-trained VGG16 model.


## Setup
To run this project, you need to download a pre-trained VGG16 model (I couldn't add it here because the file is larger than 100mb) and you can do it by running the `setup.sh` on the root folder. This will download the pre-trained model from apple's website.


```shell
git clone https://github.com/alaphao/CoreMLExample.git
cd CoreMLExample
./setup.sh
```

If you prefer, you can [download the model here](https://docs-assets.developer.apple.com/coreml/models/VGG16.mlmodel) and move it to the `CoreMLExample` folder.

## Requirements
* Xcode 9 beta
* Swift 4
* iOS 11


## Useful Links
* [Welcoming Core ML](https://medium.com/towards-data-science/welcoming-core-ml-8ba325227a28)
* [Integrating a Core ML Model into Your App](https://developer.apple.com/documentation/coreml/integrating_a_core_ml_model_into_your_app])
