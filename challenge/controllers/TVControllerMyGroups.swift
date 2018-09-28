//
//  TVControllerGroups.swift
//  challenge
//
//  Created by Denis Garifyanov on 25/06/2018.
//  Copyright © 2018 Denis Garifyanov. All rights reserved.
//

import UIKit
import RealmSwift

class TVControllerMyGroups: UITableViewController {
    var token: String? = ""
    var listOfMyGroups: Results<ModelGroup>!
    var realm = try! Realm()
    var notificationToken: NotificationToken?
    
    //MARK: - Data methods
    func syncStores(){
        listOfMyGroups = realm.objects(ModelGroup.self).sorted(byKeyPath: "name")
        notificationToken = listOfMyGroups._observe { (changes) in
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
    func loadDataFromAPI(){
        guard let token = self.token else {return}
        let JSONAction = transportProtocol(token)
        JSONAction.loadMyGroups { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let VCTable = segue.destination as? TVControllersAllGroups{
            VCTable.token = token
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncStores()
        loadDataFromAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfMyGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellOfMyGroup", for: indexPath) as! UITVCellOfMyGroup
//        cell.nameOfGroup.text = listOfMyGroups[indexPath.row].name
        let group = listOfMyGroups[indexPath.row]
        cell.setupWithData(group)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

