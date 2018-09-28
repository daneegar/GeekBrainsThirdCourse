//
//  TVControllersAllGroups.swift
//  challenge
//
//  Created by Denis Garifyanov on 25/06/2018.
//  Copyright © 2018 Denis Garifyanov. All rights reserved.
//

import UIKit
import RealmSwift

protocol AddGroupsProtocolDelegate {
    func AddGroup(nameOfGroup:String)
}

class TVControllersAllGroups: UITableViewController, UISearchBarDelegate {
    var token: String? = ""
    var groups: [ModelGroup] = []
    var realm = try! Realm()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromLocalStorage()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Data methods
    func loadDataFromLocalStorage(){
        let catchedGroups = Array(realm.objects(ModelGroup.self))
        groups = catchedGroups
    }
    
    
    func loadDataFromAPI(){
        guard let token = self.token else {return}
        let JSONAction = transportProtocol(token)
        JSONAction.loadAllGroups { (catchedGroups, error) in
            if let someError = error{
                print(someError)
            }
            if let groups = catchedGroups {
                self.groups = groups
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllGroup", for: indexPath) as! UITVCellOfAllGroup
        //transportProtocol.loadMembersOfGroup(forGroup: groups[indexPath.row], token:token)
        cell.setupWithModel(byTheGroup: groups[indexPath.row])
        return cell
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let token = self.token else {return}
        let JSONAction = transportProtocol(token)
        JSONAction.loadAllGroups(bySearching: searchText) { (catchedGroups, error) in
            if let someError = error{
                print (someError)
            }
            if let groups = catchedGroups {
                self.groups = groups
                self.tableView.reloadData()
            }
        }
    }
}

