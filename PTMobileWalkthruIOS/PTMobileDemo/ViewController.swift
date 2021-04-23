// Copyright (c) 2020 Facebook, Inc. and its affiliates.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.


import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnRun: UIButton!
    

    private var image : UIImage?
    private var inferencer = ImageClassfication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image = UIImage(named: "IMG_2102.jpg")!
        //contaminated-0276.jpg
        if let iv = imageView {
            iv.image = image
            btnRun.setTitle("Detect", for: .normal)
        }
        // Do any additional setup after loading the view.
    }

    
    static func cleanDetection(imageView: UIImageView) {
        if let layers = imageView.layer.sublayers {
            for layer in layers {
                if layer is CATextLayer {
                    layer.removeFromSuperlayer()
                }
            }
            for view in imageView.subviews {
                view.removeFromSuperview()
            }
        }
    }
    
    @IBAction func doInference(_ sender: Any) {
        btnRun.isEnabled = false
        btnRun.setTitle("Inferencing...", for: .normal)
        
        let resizedImage = image!.resized(to: CGSize(width: 256, height: 256))

        guard var pixelBuffer = resizedImage.normalized() else {
            return
        }
        DispatchQueue.global().async{
            guard let outputs = self.inferencer.module.predict(image: &pixelBuffer) else {
                return
            }
            let zippedResults = zip(self.inferencer.labels.indices, outputs)
            let sortedResults = zippedResults.sorted { $0.1.floatValue > $1.1.floatValue }.prefix(1)
            print(sortedResults)
            DispatchQueue.main.async {
                var text = ""
                for result in sortedResults {
                    text += "\u{2022} \(self.inferencer.labels[result.0]) \n\n"
                }
                self.textView.text = text
                self.btnRun.isEnabled = true
                self.btnRun.setTitle("Detect", for: .normal)
            }
        }
    }
    
    @IBAction func imageloaded(_ sender: Any) {
        ViewController.cleanDetection(imageView: imageView)
        let image_loaded = UIImagePickerController()
        image_loaded.delegate = self
        image_loaded.sourceType = UIImagePickerController.SourceType.photoLibrary
        image_loaded.allowsEditing = false
        self.present(image_loaded, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("func")
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}


