## CoreMLExample

In this example we use AVFoundation to continuously get image data from the back camera, and try to detect the dominant objects present in the image by using a pre-trained VGG16 model.


## Setup
To run this project, you need to download a pre-trained VGG16 model (I couldn't add it here because the size of the file is more than 500mb) and you can do it by running the `setup.sh` on the root folder. This will download the pre-trained model from apple's website.


```shell
brew install wget
./setup.sh
```

If you prefer, you can [download the model here](https://docs-assets.developer.apple.com/coreml/models/VGG16.mlmodel) and move it to the `CoreMLExample` folder.

## Requirements
* Xcode 9 beta
* Swift 4
* iOS 11