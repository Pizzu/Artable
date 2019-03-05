//
//  AddEditCategoryVC.swift
//  ArtableAdmin
//
//  Created by Luca Lo Forte on 04/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase
import CropViewController
import CodableFirebase
import Kingfisher

class AddEditCategoryVC: UIViewController {

    //Outlets
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Variables
    private var croppingStyle = CropViewCroppingStyle.default
    private var addedCategoryImg : UIImage?
    var categoryToEdit: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        categoryImageView.addGestureRecognizer(tap)
        
        if let category = categoryToEdit {
            categoryNameTextField.text = category.name
            
            if let url = URL(string: category.imgUrl) {
                categoryImageView.kf.setImage(with: url)
            }
        }
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()
    }
    
    @IBAction func addCategoryPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        if let categoryToEdit = categoryToEdit {
            // We are editing a category, but we also want to be able to edit JUST the title.
            if addedCategoryImg == nil {
                uploadDocument(url: categoryToEdit.imgUrl)
            } else {
                uploadImageThenDocument()
            }
        } else {
            uploadImageThenDocument()
        }
    }
    
    func uploadImageThenDocument() {
        guard let image = addedCategoryImg ,
            let categoryName = categoryNameTextField.text , categoryName.isNotEmpty else {
                simpleAlert(title: "Error", message: "Must add Category Image and Category Title")
                activityIndicator.stopAnimating()
                return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        let imageRef = Storage.storage().reference().child("/categoryImages/\(categoryName).jpg")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageRef.putData(imageData, metadata: metaData) { (metadata, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", message: "Unable to upload image")
                self.activityIndicator.stopAnimating()
                return
            }
            imageRef.downloadURL(completion: { (url, err) in
                
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.simpleAlert(title: "Error", message: "Unable to retrieve image url")
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                guard let url = url else { return }
                self.uploadDocument(url: url.absoluteString)
            })
        }
    }
    
    func uploadDocument(url: String) {
        var docRef : DocumentReference!
        guard let categoryName = categoryNameTextField.text , categoryName.isNotEmpty else {
            self.simpleAlert(title: "Error", message: "Must add Category Image and Category Title")
            self.activityIndicator.stopAnimating()
            return
        }
        var category = Category.init(
                                            name: categoryName,
                                            id: "",
                                            imgUrl:
                                            url, isActive: true,
                                            timeStamp: Timestamp())
        
        if let categoryToEdit = categoryToEdit {
            // We are editing
            docRef = Firestore.firestore().collection("categories").document(categoryToEdit.id)
            category.id = categoryToEdit.id
        } else {
            // New category
            docRef = Firestore.firestore().collection("categories").document()
            category.id = docRef.documentID
        }
        do {
            let data = try FirestoreEncoder().encode(category)
            docRef.setData(data, merge: true) { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.simpleAlert(title: "Error", message: "Unable to save data")
                    self.activityIndicator.stopAnimating()
                    return
                }
                self.activityIndicator.stopAnimating()
                self.navigationController?.popViewController(animated: true)
            }
        }  catch {
            debugPrint(error.localizedDescription)
        }
    }
}

extension AddEditCategoryVC : CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        picker.dismiss(animated: true, completion: {
            self.present(cropController, animated: true, completion: nil)
        })
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        addedCategoryImg = image
        categoryImageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
