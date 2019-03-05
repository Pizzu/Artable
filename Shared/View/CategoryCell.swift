//
//  CategoryCell.swift
//  Artable
//
//  Created by Luca Lo Forte on 04/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Kingfisher
class CategoryCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImage.layer.cornerRadius = 5
    }
    
    func configureCell(category: Category) {
        categoryName.text = category.name
        if let url = URL(string: category.imgUrl) {
            categoryImage.kf.setImage(with: url)
        }
    }
    
}
