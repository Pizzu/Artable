//
//  ProductDetailVC.swift
//  Artable
//
//  Created by Luca Lo Forte on 12/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Kingfisher

class ProductDetailVC: UIViewController {

    //Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    //Variables
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        if let url = URL(string: product.imgUrl) {
            productImage.kf.setImage(with: url)
        }
        productName.text = product.name
        productPrice.text = "$\(product.price)"
        productDescription.text = product.productDescription
    }
    
    @IBAction func addToCartPressed(_ sender: Any) {
        //We insert the product to the cart
    }
    
    @IBAction func keepShoppingPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

