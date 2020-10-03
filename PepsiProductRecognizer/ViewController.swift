//
//  ViewController.swift
//  PepsiProductRecognizer
//
//  Created by Ugur Eratalar on 29.06.2020.
//  Copyright © 2020 Ugur Eratalar. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - View Elements
    
    var imageToAnalize: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
		img.backgroundColor = .yellow
		img.isUserInteractionEnabled = true
		img.clipsToBounds = true
        return img
    }()
    
    let photoLibraryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Select Photo", for: .normal)
        btn.addTarget(self, action: #selector(photoLib), for: .touchUpInside)
        return btn
    }()
	
	lazy var detection:VNCoreMLRequest = {
		do {
			let model = try VNCoreMLModel(for: NewPepsiDetector_1().model)
			
			let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
				self?.processDetections(request: request, error: error)
			})
			request.imageCropAndScaleOption = .scaleFit
			return request
		} catch {
			fatalError("Failed to load Vision ML model: \(error)")
		}
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
    }
    
    
    func setupUI() {
        view.backgroundColor = UIColor.rgb(red: 253, green: 245, blue: 230)
        //** imageToAnalize
        view.addSubview(imageToAnalize)
        imageToAnalize.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: ViewController.width, height: ViewController.height)
        imageToAnalize.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageToAnalize.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageToAnalize.addShadow()
        
		view.addSubview(photoLibraryButton)
		photoLibraryButton.anchor(top: imageToAnalize.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right:self.view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 60)
        
        //** photoLibraryButton
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
		
		guard let image = info[.originalImage] as? UIImage else {
			return
		}
		
		self.imageToAnalize.image = image
		updateDetections(image: image)
	}
    
}

extension ViewController {
	
	private func updateDetections(image: UIImage) {
		let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
		guard let convertedImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).")}
		
		DispatchQueue.global(qos: .userInitiated).async {
			let handler = VNImageRequestHandler(ciImage: convertedImage, orientation: orientation!)
			do {
				try handler.perform([self.detection])
			} catch {
				print("Failed to detect!:  ", error.localizedDescription)
			}
		}
	}
	
	private func processDetections(request: VNRequest, error: Error?) {
		DispatchQueue.main.async {
			guard let results = request.results else {
				print("Unable to detect!: ", error?.localizedDescription ?? "")
				return
			}
			let detections = results as! [VNRecognizedObjectObservation]
			self.drawDetections(detections: detections)
		}
	}
	
	func drawDetections(detections: [VNRecognizedObjectObservation]) {
		guard let image = self.imageToAnalize.image else { return }
		let imageSize = image.size
		let scale: CGFloat = 0
		UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
		image.draw(at: CGPoint.zero)
		var btnArray = [UIButton]()
		for detection in detections {
			print(detection.labels.map({"\($0.identifier) confidence: \($0.confidence)"}).joined(separator: "\n"))
			print("------------")
			
			let boundingBox = detection.boundingBox
			let rectangle = CGRect(x: boundingBox.minX*image.size.width, y: (1-boundingBox.minY-boundingBox.height)*image.size.height, width: boundingBox.width*image.size.width, height: boundingBox.height*image.size.height)
			UIColor(red: 0, green: 1, blue: 0, alpha: 0.4).setFill()
			UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
			
//			let wikiButton = UIButton(type: .system)
//			wikiButton.backgroundColor = .red
//			wikiButton.center = CGPoint(x: boundingBox.minX*image.size.width, y: (1-boundingBox.minY-boundingBox.height)*image.size.height)
//			wikiButton.frame.size = CGSize(width: boundingBox.width*image.size.width, height: boundingBox.height*image.size.height)
//			wikiButton.addTarget(self, action: #selector(showWikiPage), for: .touchUpInside)
//			btnArray.append(wikiButton)
		}
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.imageToAnalize.image = newImage
	}
	
	@objc func showWikiPage() {
		print("\nshow wiki\n")
	}
}
