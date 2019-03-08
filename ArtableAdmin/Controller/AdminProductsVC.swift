//
//  AdminProductsVC.swift
//  ArtableAdmin
//
//  Created by Luca Lo Forte on 07/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit

class AdminProductsVC: ProductsVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        navigationItem.rightBarButtonItems?.removeAll()
        let editCategoryBtn = UIBarButtonItem(title: "Edit Category", style: .plain, target: self, action: #selector(editCategory))
        editCategoryBtn.tintColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        
        let newProductBtn = UIBarButtonItem(title: "+ Product", style: .plain, target: self, action: #selector(newProduct))
        newProductBtn.tintColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        navigationItem.setRightBarButtonItems([editCategoryBtn, newProductBtn], animated: true)
    }
    
    @objc func editCategory() {
        performSegue(withIdentifier: Segues.EditCategory, sender: self)
    }
    
    @objc func newProduct() {
        performSegue(withIdentifier: Segues.ToAddEditProduct, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.EditCategory {
            if let destination = segue.destination as? AddEditCategoryVC {
                destination.categoryToEdit = selectedCategory
            }
        } else if segue.identifier == Segues.ToAddEditProduct {
            if let destination = segue.destination as? AddEditProductVC {
                destination.selectedCategory = selectedCategory
                destination.productToEdit = selectedProduct
                selectedProduct = nil
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = products[indexPath.row]
        performSegue(withIdentifier: Segues.ToAddEditProduct, sender: self)
    }

}
