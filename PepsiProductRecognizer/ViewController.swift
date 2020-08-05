//
//  ViewController.swift
//  PepsiProductRecognizer
//
//  Created by Ugur Eratalar on 29.06.2020.
//  Copyright © 2020 Ugur Eratalar. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - View Elements
    
    var imageToAnalize: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .clear
        return img
    }()
    
    let classifierLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "Super Potatoo"
        return label
    }()
    
    let cameraButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Camera", for: .normal)
        btn.addTarget(self, action: #selector(camera), for: .touchUpInside)
        return btn
    }()
    
    let photoLibraryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Photo Library", for: .normal)
        btn.addTarget(self, action: #selector(photoLib), for: .touchUpInside)
        return btn
    }()
    
    let buttonsContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    @objc func camera() {
        print("open camera!")
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("camera is not available..")
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true, completion: nil)
        
    }
    
    @objc func photoLib() {
        print("open photo library!")
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("photo library is not available..")
            return
        }
        
        let photoPicker = UIImagePickerController()
        photoPicker.allowsEditing = false
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        
        present(photoPicker, animated: true, completion: nil)
        
    }
    
    // MARK: Properties
    var model: MyPepsiObjectDetector_1!
    static let width: CGFloat = 416
    static let height: CGFloat = 416
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        model = MyPepsiObjectDetector_1()
    }
    
    
    func setupUI() {
        self.view.backgroundColor = UIColor.rgb(red: 253, green: 245, blue: 230)
        //** imageToAnalize
        self.view.addSubview(imageToAnalize)
        imageToAnalize.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: ViewController.width, height: ViewController.height)
        imageToAnalize.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageToAnalize.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageToAnalize.addShadow()
        
        //** classifier label
        self.view.addSubview(classifierLabel)
        classifierLabel.anchor(top: nil, left: nil, bottom: imageToAnalize.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        classifierLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //** buttonsContainer
        self.view.addSubview(buttonsContainerView)
        buttonsContainerView.backgroundColor = .white
        buttonsContainerView.layer.cornerRadius = 5.0
        buttonsContainerView.layer.borderWidth = 1.0
        buttonsContainerView.layer.borderColor = UIColor.rgb(red: 245, green: 245, blue: 220).cgColor
        buttonsContainerView.addShadow()
        
        buttonsContainerView.anchor(top: imageToAnalize.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right:self.view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 100)
        
        //** camera button
        buttonsContainerView.addc`fGATFACAGFAGZcv`cfazresw4sreaeaewawSubview(cameraButton)w#wERxgzfgxfxgfxgxhdcfvvcchn gvcc
        cameraButton.anchor(top: buttonsContainerView.topAnchor, left: buttonsContainerView.leftAnchor, bottom: buttonsContainerView.bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 10, paddingBottom: 20, paddingRight: 0, width: 160, height: 60)
        cameraButton.backgroundColor = .black
        cameraButton.layer.cornerRadius = 5.0
        cameraButton.addShadow()
        
        //** photoLibraryButton
        buttonsContainerView.addSubview(photoLibraryButton)
        photoLibraryButton.anchor(top: buttonsContainerView.topAnchor, left: nil, bottom: buttonsContainerView.bottomAnchor, right: buttonsContainerView.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 10, width: 160, height: 60)
        photoLibraryButton.layer.borderColor = UIColor.black.cgColor
        photoLibraryButton.layer.borderWidth = 3.0
        photoLibraryButton.layer.cornerRadius = 5.0
        photoLibraryButton.addShadow()
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("image picker controller did cancel!")
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        self.classifierLabel.text = "Analyzing your image!"
        guard let selectedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage else { return }
        scaleImageForMLModel(originalImage: selectedImage)
    }
    
    fileprivate func scaleImageForMLModel(originalImage: UIImage) {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: ViewController.width, height: ViewController.height), true, 2.0)
        originalImage.draw(in: CGRect(x: 0, y: 0, width: ViewController.width, height: ViewController.height))
        let updatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(updatedImage.size.width), Int(updatedImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        if status == kCVReturnSuccess {

            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(updatedImage.size.width), height: Int(updatedImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
            
            context?.translateBy(x: 0, y: updatedImage.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context!)
            updatedImage.draw(in: CGRect(x: 0, y: 0, width: updatedImage.size.width, height: updatedImage.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            imageToAnalize.image = updatedImage
            makePrediction(pixelBuffer: pixelBuffer)
        } else { return }
    }

    fileprivate func makePrediction(pixelBuffer: CVPixelBuffer?) {
        guard let pixelImage = pixelBuffer else { return }
        guard let prediction = try? model.prediction(image: pixelImage, iouThreshold: 0.3, confidenceThreshold: 0.2) else { return }
        print(prediction)
    }
    
}
