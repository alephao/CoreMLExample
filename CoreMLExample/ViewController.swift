//
//  ViewController.swift
//  CoreMLExample
//
//  Created by Aleph Retamal on 6/6/17.
//  Copyright © 2017 WWDC17. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML

final class ViewController: UIViewController {
    
    // MARK: - UI
    fileprivate let previewView: UIView = UIView()
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        label.numberOfLines = 2
        label.textColor = .white
        label.textAlignment = .center
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    fileprivate let probLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        label.textColor = .white
        label.textAlignment = .center
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    // MARK: - Properties
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    let probNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = true
        formatter.maximumSignificantDigits = 3
        formatter.multiplier = 100
        formatter.positiveSuffix = "%"
        return formatter
    }()
    
    let model = VGG16()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)
        view.addSubview(titleLabel)
        view.addSubview(probLabel)
        setupConstraints()
        setupCamera()
    }
    
    private func setupConstraints() {
        // previewView Constraints
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        let previewViewHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: .init(rawValue: 0), metrics: nil, views: ["view":previewView])
        let previewViewVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: .init(rawValue: 0), metrics: nil, views: ["view":previewView])
        
        view.addConstraints(previewViewHConstraints)
        view.addConstraints(previewViewVConstraints)
        
        // probLabel Constraints
        probLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let probLabelHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[probLabel]-16-|", options: .init(rawValue: 0), metrics: nil, views: ["probLabel":probLabel])
        let probLabelBottomConstraint = NSLayoutConstraint(item: probLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -20)
        
        view.addConstraints(probLabelHConstraints)
        view.addConstraint(probLabelBottomConstraint)
        
        // titleLabel Constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabelHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-16-|", options: .init(rawValue: 0), metrics: nil, views: ["titleLabel":titleLabel])
        let titleLabelBottomConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: probLabel, attribute: .top, multiplier: 1.0, constant: -8)
        
        view.addConstraints(titleLabelHConstraints)
        view.addConstraint(titleLabelBottomConstraint)
    }
    
    // Setup camera
    private func setupCamera() {
        // Capture session
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else { fatalError("Couldn't get AVCaptureDevice") }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession!.addInput(input)
        } catch let error {
            print("Failed to initialize input")
            print(error)
            return
        }
        
        // Output
        photoOutput = AVCapturePhotoOutput()
        captureSession!.addOutput(photoOutput!)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.layer.addSublayer(previewLayer!)
        previewView.layer.masksToBounds = true
        previewLayer!.frame = UIScreen.main.bounds
        
        startCapturing(photoOutput: photoOutput)
        
        captureSession?.startRunning()
    }
    
    // Starts a timer that captures a picture from the camera every 0.5s
    private func startCapturing(photoOutput: AVCapturePhotoOutput?) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg, AVVideoCompressionPropertiesKey: [AVVideoQualityKey: 1.0]])
            photoOutput?.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let photoBuffer = photoSampleBuffer else { return }
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else { return }
        guard let image = UIImage(data: imageData) else { return }
        let screenScale = UIScreen.main.scale
        guard let img = resize(image: image, newSize: CGSize(width: 224/screenScale, height: 224/screenScale)) else { return }
        let pixelBuffer = pixelBufferFromImage(image: img)
        
        guard let vggOutput = try? model.prediction(image: pixelBuffer) else {
            print("Failed to predict")
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            let classLabel = vggOutput.classLabel
            let classLabelProb = vggOutput.classLabelProbs[classLabel] ?? 0.0
            let formattedProb = self.probNumberFormatter.string(from: NSNumber(value: classLabelProb)) ?? ""
            self.titleLabel.text = classLabel
            self.probLabel.text = "Prob: \(formattedProb)"
        }
        
    }
}
