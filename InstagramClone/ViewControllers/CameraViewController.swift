//
//  CameraViewController.swift
//  InstagramClone
//
//  Created by Violet Wei on 2018-12-27.
//  Copyright © 2018 Violet Wei. All rights reserved.
//

import UIKit
import AVFoundation
import ImagePicker

class CameraViewController: UIViewController, ImagePickerDelegate {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIButton!
    var selectedImage: UIImage?
    var videoUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func handlePost() {
        if selectedImage != nil {
           self.shareButton.isEnabled = true
           self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
           self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            let ratio = profileImg.size.width / profileImg.size.height
            HelperService.uploadDataToServer(data: imageData, videoUrl: self.videoUrl, ratio: ratio, caption: captionTextView.text!, onSuccess: {
            self.clean()
            self.tabBarController?.selectedIndex = 0
        })
        
        } else {
            ProgressHUD.showError("Profile Image can't be empty")
        }
    }
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first else {
            dismiss(animated: true, completion: nil)
            return
        }
        selectedImage = image
        photo.image = image
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "filter_segue", sender: nil)
        })
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
    }
    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_segue" {
            let filterVC = segue.destination as! FilterViewController
            filterVC.selectedImage = self.selectedImage
            filterVC.delegate = self
        }
    }
    
}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        print(info)
        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            if let thumnailImage = self.thumbnailImageForFileUrl(videoUrl) {
                selectedImage = thumnailImage
                photo.image = thumnailImage
                self.videoUrl = videoUrl
            }
            dismiss(animated: true, completion: nil)
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
            dismiss(animated: true, completion: { 
                self.performSegue(withIdentifier: "filter_segue", sender: nil)
            })
        }
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(7, 1), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
}

extension CameraViewController: FilterViewControllerDelegate {
    func updatePhoto(image: UIImage) {
        self.photo.image = image
        self.selectedImage = image
    }
}
