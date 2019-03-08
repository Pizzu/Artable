//
//  AddEditProductVC.swift
//  ArtableAdmin
//
//  Created by Luca Lo Forte on 07/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase
import CropViewController
import CodableFirebase
import Kingfisher

class AddEditProductVC: UIViewController {

    //Outlets
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productPriceTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Variables
    private var croppingStyle = CropViewCroppingStyle.default
    private var addedProductImg : UIImage?
    var selectedCategory : Category!
    var productToEdit : Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        productImage.addGestureRecognizer(tap)
        
        if let product = productToEdit {
            productNameTextField.text = product.name
            productPriceTextField.text = "$\(product.price)"
            stockTextField.text = "\(product.stock)"
            productDescription.text = product.productDescription
            
            if let url = URL(string: product.imgUrl) {
                productImage.kf.setImage(with: url)
            }
        }
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()
    }
    
    @IBAction func addProductPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        if let productToEdit = productToEdit {
            // We are editing a category, but we also want to be able to edit JUST the title.
            if addedProductImg == nil {
                uploadDocument(url: productToEdit.imgUrl)
            } else {
                uploadImageThenDocument()
            }
        } else {
            uploadImageThenDocument()
        }
    }
    
    func uploadImageThenDocument() {
        guard let image = addedProductImg ,
            let productName = productNameTextField.text , productName.isNotEmpty ,
            let productPriceString = productPriceTextField.text , productPriceString.isNotEmpty,
            let productPrice = Double(productPriceString),
            let productStockString = stockTextField.text , productStockString.isNotEmpty,
            let productStock = Int(productStockString),
            let productDescription = productDescription.text , productDescription.isNotEmpty else {
                simpleAlert(title: "Error", message: "Must add all the fields.")
                activityIndicator.stopAnimating()
                return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        let imageRef = Storage.storage().reference().child("/productImages/\(productName).jpg")
        
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
   
    func uploadDocument(url : String) {
        var docRef : DocumentReference!
        guard let productName = productNameTextField.text , productName.isNotEmpty ,
        let productPriceString = productPriceTextField.text , productPriceString.isNotEmpty,
        let productPrice = Double(productPriceString),
        let productStockString = stockTextField.text , productStockString.isNotEmpty,
        let productStock = Int(productStockString),
        let productDescription = productDescription.text , productDescription.isNotEmpty else {
            simpleAlert(title: "Error", message: "Must add all the fields.")
            activityIndicator.stopAnimating()
            return
        }
        var product = Product.init(
            name: productName,
            id: "",
            categoryId: selectedCategory.id,
            price: productPrice,
            productDescription: productDescription,
            imgUrl: url,
            timeStamp: Timestamp(),
            stock: productStock)
        
        if let productToEdit = productToEdit {
            // We are editing
            docRef = Firestore.firestore().collection("products").document(productToEdit.id)
            product.id = productToEdit.id
        } else {
            // New category
            docRef = Firestore.firestore().collection("products").document()
            product.id = docRef.documentID
        }
        do {
            let data = try FirestoreEncoder().encode(product)
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

extension AddEditProductVC : CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        addedProductImg = image
        productImage.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
