//
//  ViewController.swift
//  Artable
//
//  Created by Luca Lo Forte on 05/02/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class HomeVC: UIViewController {

    //Outlets
    @IBOutlet weak var loginOutBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Variables
    var categories = [Category]()
    var selectedCategory: Category!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupInitialAnonymousUser()
        setupNavigationBar()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: NibName.categoryCell, bundle: nil), forCellWithReuseIdentifier: ReuseId.categoryCell)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1),
             NSAttributedString.Key.font: UIFont(name: "Futura", size: 22)!]
    }
    
    func setupInitialAnonymousUser() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (authResult, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.handleFireAuthError(error: error)
                }
                self.simpleAlert(title: "Welcome!", message: "You are currently logged in as a guest. You can browse through the products, but to make a purchase you will need to log in. Take a look around!")
                self.setupCategoryListener()
            }
        } else {
            self.setupCategoryListener()
        }
    }
    
    func setupCategoryListener() {
        Firestore.firestore().collection("categories").order(by: "name", descending: false).addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            snapshot?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                var category : Category
                do {
                    category = try FirestoreDecoder().decode(Category.self, from: data)
                } catch {
                    debugPrint(error.localizedDescription)
                    return
                }
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, category: category)
                case .modified:
                    self.onDocumentModified(change: change, category: category)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            loginOutBtn.title = "Logout"
            let cartBtn = UIBarButtonItem(image: UIImage(named: "bar_button_cart"), style: .plain, target: self, action: #selector(cartPressed))
            let favoritesBtn = UIBarButtonItem(image: UIImage(named: "bar_button_star"), style: .plain, target: self, action: #selector(favoritesPressed))
            navigationItem.setRightBarButtonItems([cartBtn, favoritesBtn], animated: true)
            if UserService.listener == nil {
                UserService.getCurrentUser()
            }
        } else {
            loginOutBtn.title = "Login"
            navigationItem.rightBarButtonItems?.removeAll()
        }
    }
    
    @objc func favoritesPressed() {
        //performSegue(withIdentifier: "toFavoritesVC", sender: self)
    }
    
    @objc func cartPressed() {
        return
    }
    
    private func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginOutPressed(_ sender: Any) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        if currentUser.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                UserService.logoutUser()
                //After the sign out (from signed in user with email) --> we set an Anonymous user
                Auth.auth().signInAnonymously { (authResult, error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        self.handleFireAuthError(error: error)
                    }
                    self.presentLoginController()
                }
            } catch {
                debugPrint(error.localizedDescription)
                self.handleFireAuthError(error: error)
            }
        }
    }
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func onDocumentAdded(change: DocumentChange, category: Category) {
        let newIndex = Int(change.newIndex)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(row: newIndex, section: 0)])
    }
    
    func onDocumentModified(change: DocumentChange, category: Category) {
        if change.oldIndex == change.newIndex {
            // Item changed but remained in the same position
            let index = Int(change.oldIndex)
            categories[index] = category
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        } else {
            // Item changed and changed position
            categories.remove(at: Int(change.oldIndex))
            categories.insert(category, at: Int(change.newIndex))
            collectionView.moveItem(at: IndexPath(row: Int(change.oldIndex), section: 0), to: IndexPath(row: Int(change.newIndex), section: 0))
            collectionView.reloadItems(at: [IndexPath(row: Int(change.newIndex), section: 0), IndexPath(row: Int(change.oldIndex), section: 0)])
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        categories.remove(at: Int(change.oldIndex))
        collectionView.deleteItems(at: [IndexPath(row: Int(change.oldIndex), section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseId.categoryCell, for: indexPath) as? CategoryCell {
            
            cell.configureCell(category: categories[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        let cellWidth = (width - 50) / 2
        let cellHeight = cellWidth * 1.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        performSegue(withIdentifier: Segues.ToProducts, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToProducts {
            if let destination = segue.destination as? ProductsVC {
                destination.selectedCategory = selectedCategory
            }
        }
    }
    
    
}
