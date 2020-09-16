//
//  TableViewController.swift
//  ShoppingList
//
//  Created by Eric Alves Brito on 15/09/20.
//  Copyright © 2020 DevBoost. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: UITableViewController {

    
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    
    // MARK: - Properties
    let collection = "shoppingList"
    var shoppingList: [ShoppingItem] = []
    lazy var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    var firestoreListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            title = user.displayName
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sair", style: .plain, target: self, action: #selector(logout))
        loadShoppingList()
        
        if let addItem = RemoteConfigValues.shared.featureToggle["addItem"], !addItem {
            navigationItem.rightBarButtonItems = []
        }
        
    }

    // MARK: - Methods
    @objc private func logout() {
        do {
            try Auth.auth().signOut()
            guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") else {return}
            navigationController?.viewControllers = [viewController]
        } catch {
            print("Não foi possível deslogar o usuário")
        }
    }
    
    private func loadShoppingList() {
        firestoreListener = firestore
                            .collection(collection)
                            .order(by: "name", descending: true)
                            //.limit(to: 20)
                            .addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
        
            if let error = error {
                print(error)
            } else {
                guard let snapshot = snapshot else {return}
                print("Documentos alterados:", snapshot.documentChanges.count)
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    self.showItemsFrom(snapshot)
                }
            }
        })
    }
    
    private func showItemsFrom(_ snapshot: QuerySnapshot) {
        shoppingList.removeAll()
        for document in snapshot.documents {
            let data = document.data()
            let name = data["name"] as! String
            let quantity = data["quantity"] as! Int
            let id = document.documentID
            let shoppingItem = ShoppingItem(name: name, quantity: quantity, id: id)
            shoppingList.append(shoppingItem)
        }
        tableView.reloadData()
    }
    
    private func showAlertForItem(_ item: ShoppingItem?) {
        let alert = UIAlertController(title: "Produto", message: "Entre com as informações do produto abaixo", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome"
            textField.text = item?.name
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Quantidade"
            textField.keyboardType = .numberPad
            textField.text = item?.quantity.description
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let name = alert.textFields?.first?.text, let quantityText = alert.textFields?.last?.text, let quantity = Int(quantityText) else {return}
            
            let data: [String: Any] = [
                "name": name,
                "quantity": quantity
            ]
            
            if let item = item {
                //Edição
                self.firestore.collection(self.collection).document(item.id).updateData(data)
            } else {
                //Criação
                self.firestore.collection(self.collection).addDocument(data: data)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func addItem(_ sender: Any) {
        showAlertForItem(nil)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let shoppingItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppingItem.name
        cell.detailTextLabel?.text = "\(shoppingItem.quantity)"
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let deleteItem = RemoteConfigValues.shared.featureToggle["deleteItem"], deleteItem {
                let shoppingItem = shoppingList[indexPath.row]
                firestore.collection(collection).document(shoppingItem.id).delete()
            } else {
                print("Feature desligada")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shoppingItem = shoppingList[indexPath.row]
        showAlertForItem(shoppingItem)
    }
}
