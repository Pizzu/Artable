//
//  ProductCell.swift
//  Artable
//
//  Created by Luca Lo Forte on 07/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

protocol ActionProductDelegate : class  {
    func productFavorited(product: Product)
    func showInfo(product: Product)
}

class ProductCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var productImageView: RoundedImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var addToCartBtn: RoundedButton!
    
    //Variables
    private var product: Product!
    weak var delegate : ActionProductDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UserService.isGuest == true {
            favoriteBtn.isHidden = true
            addToCartBtn.isHidden = true
        }
    }
    
    func configureCell(product: Product, delegate: ActionProductDelegate) {
        self.delegate = delegate
        self.product = product
        
        productName.text = product.name
        productPrice.text = "$\(product.price)"
        
        if let url = URL(string: product.imgUrl) {
            productImageView.kf.setImage(with: url)
        }
        
        if UserService.isGuest == false {
            let questionRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("favoriteProducts").document(product.id)
            questionRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    //We need to unlike the question
                    self.favoriteBtn.setImage(UIImage(named: "filled_star"), for: .normal)
                } else {
                    //We need to like the question
                    self.favoriteBtn.setImage(UIImage(named: "empty_star"), for: .normal)
                }
            }
        }
    }
    
    @IBAction func showInfoPressed(_ sender: Any) {
        delegate?.showInfo(product: product)
    }
    
    @IBAction func favoriteBtnPressed(_ sender: Any) {
        delegate?.productFavorited(product: product)
    }
    
    
}
