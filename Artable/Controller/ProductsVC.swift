//
//  ProductsVC.swift
//  Artable
//
//  Created by Luca Lo Forte on 07/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class ProductsVC: UIViewController {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    var selectedCategory: Category?
    var products = [Product]()
    var selectedProduct: Product?
    private var listener : ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        setupQuery()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: NibName.productCell, bundle: nil), forCellReuseIdentifier: ReuseId.productCell)
    }
    
    func setupNavigationBar() {
        title = selectedCategory?.name.lowercased()
    }
    
    func setupQuery() {
        guard let selectedCategory = selectedCategory else { return }
        listener = Firestore.firestore().collection("products").whereField("categoryId", isEqualTo: selectedCategory.id).order(by: "name", descending: false).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("error")
                debugPrint(error.localizedDescription)
            }
            snapshot?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                var product: Product
                do {
                    product = try FirestoreDecoder().decode(Product.self, from: data)
                } catch {
                    debugPrint(error)
                    return
                }
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, product: product)
                case .modified:
                    self.onDocumentModified(change: change, product: product)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        }
    }
    
}

extension ProductsVC : UITableViewDelegate, UITableViewDataSource {
    func onDocumentAdded(change: DocumentChange, product: Product) {
        let newIndex = Int(change.newIndex)
        products.insert(product, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }
    
    func onDocumentModified(change: DocumentChange, product: Product) {
        if change.oldIndex == change.newIndex {
            // Item changed but remained in the same position
            let index = Int(change.oldIndex)
            products[index] = product
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            // Item changed and changed position
            products.remove(at: Int(change.oldIndex))
            products.insert(product, at: Int(change.newIndex))
            tableView.moveRow(at: IndexPath(row: Int(change.oldIndex), section: 0), to: IndexPath(row: Int(change.newIndex), section: 0))
            tableView.reloadRows(at: [IndexPath(row: Int(change.newIndex), section: 0), IndexPath(row: Int(change.oldIndex), section: 0)], with: .automatic)
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        products.remove(at: Int(change.oldIndex))
        tableView.deleteRows(at: [IndexPath(row: Int(change.oldIndex), section: 0)], with: .left)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReuseId.productCell, for: indexPath) as? ProductCell {
            cell.configureCell(product: products[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = products[indexPath.row]
        //performSegue(withIdentifier: "toQuestionsList", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}
