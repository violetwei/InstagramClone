//
//  FilterViewController.swift
//  InstagramClone
//
//  Created by Violet Wei on 2018-12-27.
//  Copyright © 2018 Violet Wei. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate {
    func updatePhoto(image: UIImage)
}

class FilterViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterPhoto: UIImageView!
    var delegate: FilterViewControllerDelegate?
    var selectedImage: UIImage!
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterPhoto.image = selectedImage
        filterPhoto.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
    }
    @IBAction func cancelBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nextBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.updatePhoto(image: self.filterPhoto.image!)
    }

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIFilterNames.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        let context = CIContext(options: nil)
        let newImage = resizeImage(image: selectedImage, newWidth: 150)
        let ciImage = CIImage(image: newImage)
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            cell.filterPhoto.image = UIImage(cgImage: result!)

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            self.filterPhoto.image = UIImage(cgImage: result!)
        }

    }
}
