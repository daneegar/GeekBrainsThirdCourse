//
//  TVCintrollerFriends.swift
//  challenge
//
//  Created by Denis Garifyanov on 25/06/2018.
//  Copyright © 2018 Denis Garifyanov. All rights reserved.
//

import UIKit
import RealmSwift

class TVCintrollerFriends: UITableViewController {
    var token: String? = ""
    var friends: Results<ModelUser>!
    var realm = try! Realm()
    var notificationToken: NotificationToken?
    

    override func viewDidLoad() {
        self.tableView.addSubview(self.refreshControl!)
        super.viewDidLoad()
        syncStores()
    }
    
    //MARK: - load data methods
    func loadDataFromAPI(){
        guard let token = token else { return }
        let responser = transportProtocol(token)
        responser.loadFriends { (error) in
            if let anError = error{
                print(anError)
                //TODO:- handle error
            }
        }
    }
    
    func syncStores() {
        friends = realm.objects(ModelUser.self).sorted(byKeyPath: "lastName")
        notificationToken = friends._observe { (changes) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView.endUpdates()
            case .error(let error):
                print(error)
            }
        }
    }
    
    //MARK: - pull to refersh
    override lazy var refreshControl: UIRefreshControl? = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TVCintrollerFriends.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadDataFromAPI()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! UITVCellFriend
        
        let cathcedFriend = friends[indexPath.row]
        
        cell.setCell(byUser: cathcedFriend)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotosColletcion"{
            
            let destinatinoVC = segue.destination as! CVControllerPhotos
            destinatinoVC.name = friends[(tableView.indexPathForSelectedRow?.row)!].completeName
            destinatinoVC.token = self.token
            destinatinoVC.userID = friends[(tableView.indexPathForSelectedRow?.row)!].userID
        }
    }
    
    @IBAction func addFriend(_ sender: Any) {
//        var alertTextField = UITextField()
//
//        let alertForNameanItem = UIAlertController(title: "Add Friend", message: "Name the friend", preferredStyle: .alert)
//
//        let alertButtonPressed = UIAlertAction(title: "Add", style: .default) { (Alert) in
//            if alertTextField.text != "" {
//                self.friends.append(alertTextField.text!)
//            }
//            self.tableView.reloadData()
//        }
//        alertForNameanItem.addAction(alertButtonPressed)
//
//        alertForNameanItem.addTextField { (AlertTextInput) in
//            AlertTextInput.placeholder = "Here..."
//            alertTextField = AlertTextInput
//        }
//        present(alertForNameanItem, animated: true)

    }
    
    
    
}
