if ! type "wget" > /dev/null; then
    brew install wget
fi
wget "https://docs-assets.developer.apple.com/coreml/models/VGG16.mlmodel"
mv VGG16.mlmodel CoreMLExample
