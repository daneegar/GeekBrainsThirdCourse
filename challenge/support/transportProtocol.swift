//
//  JSON.swift
//  challenge
//
//  Created by Denis Garifyanov on 28/06/2018.
//  Copyright © 2018 Denis Garifyanov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class transportProtocol {
    var token: String
    
    init(_ token: String) {
        self.token = token
    }
    
    //MARK - Loading Friends
    func loadFriends (completion:((Error?)-> Void)?) {
        let path = "https://api.vk.com/method/friends.get?v=5.80&access_token=\(token)&fields=photo_100&name_case=nom"
        guard let url = URL(string: path) else {return}
        let session = URLSession.shared
        let task = session.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion?(error)
                print(error)
                return
            }
            if let data = data {
                if let json = try? JSON(data: data) {
                    let friends = json["response"]["items"].arrayValue.map { ModelUser(json: $0)}
                    DispatchQueue.main.async {
                        completion?(nil)
                        self.saveData(someRealmArray: friends)
                    }
                }
            }
        }
        task.resume()
    }
    //MARK: - Load list of my groups.
    func loadMyGroups (completion: ((Error?) -> Void)?){
        var urlConstructor = URLComponents()
        
        urlConstructor.scheme = "https"
        urlConstructor.host = "api.vk.com"
        urlConstructor.path = "/method/groups.get"
        urlConstructor.queryItems = [
            URLQueryItem(name: "v", value: "5.52"),
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "extended", value: "1")
        ]
        guard let url = urlConstructor.url else {return}
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("*************************")
                print(error)
                completion?(error)
                return
            }
            if let data = data {
                print("*************************")
                if let json = try? JSON(data: data) {
                    let groups = json["response"]["items"].arrayValue.map { ModelGroup(json: $0)}
                    DispatchQueue.main.async {
                        self.saveData(someRealmArray: groups)
                    }
                }
            }
            
        }
        task.resume()
    }
    //MARK: - Load Freind's photos
    func loadFriendPhoto(byID ownerID: String, completion: (([ModelPhoto]?, Error?) -> Void)?){
        let path = "https://api.vk.com/method/photos.getAll"
        let parameters: Parameters = [
            "access_token": token,
            "v": "5.52",
            "owner_id": ownerID
        ]
        Alamofire.request(path, parameters: parameters).responseJSON { (response) in
            
            if let error = response.error{
                print(error)
            }
            if let value = response.data {
                if let json = try? JSON(data: value) {
                    let photos = json["response"]["items"].arrayValue.map { ModelPhoto(json: $0)}
                    DispatchQueue.main.async {
                        self.saveData(someRealmArray: photos)
                        completion?(photos, nil)
                        
                    }
                    
                }
            }
        }
        
    }
    //MARK: - Load Any Groups(DEFAULT search parametr "Бизнес")
    func loadAllGroups(completion: (([ModelGroup]?, Error?)->Void)?){
        var groups: [ModelGroup] = []
        let path = "https://api.vk.com/method/groups.search"
        let parameters: Parameters = [
            "access_token": token,
            "v": "5.58",
            "q": "Бизнес",
            "count": 100
        ]
        Alamofire.request(path, parameters: parameters).responseJSON { (response) in
            if let error = response.error{
                print (error)
            }
            if let value = response.data {
                if let json = try? JSON(data: value) {
                    groups = json["response"]["items"].arrayValue.map { ModelGroup(json: $0)}
                    self.loadMembersOfGroup(forGroup: groups, completion: { (groupsWithMembers, error) in
                        DispatchQueue.main.async {
                            completion?(groupsWithMembers, nil)
                        }
                    })
                }
            }
            
        }
    }
    //MARK: - Load SearchViewGroups
    func loadAllGroups(bySearching search: String, completion:(([ModelGroup]?, Error?)->Void)?){
        let path = "https://api.vk.com/method/groups.search"
        let parameters: Parameters = [
            "access_token": token,
            "v": "5.58",
            "count": 100,
            "q": search
        ]
        Alamofire.request(path, parameters: parameters).responseJSON { (response) in
            if let error = response.error{
                print (error)
            }
            if let value = response.data {
                if let json = try? JSON(data: value) {
                    let someGroups = json["response"]["items"].arrayValue.map { ModelGroup(json: $0)}
                    self.loadMembersOfGroup(forGroup: someGroups, completion: { (groupsWithIds, error) in
                        DispatchQueue.main.async {
                            completion?(groupsWithIds, nil)
                        }
                    })
                    
                }
            } else {
                return
            }
        }
    }
    //MARK:- Load count Members of Groups
    func loadMembersOfGroup(forGroup groups: [ModelGroup], completion:(([ModelGroup]?, Error?)->Void)?){
        let path = "https://api.vk.com/method/groups.getById"
        let groupId = idsOfGroups(Groups: groups)
        //print(groupId)
        let parameters: Parameters = [
            "access_token": token,
            "group_ids": groupId,
            "v": "5.8",
            "fields": "members_count"
        ]
        Alamofire.request(path, parameters: parameters).responseJSON { (response) in
            if let error = response.error{
                print (error)
            }
            if let value = response.data {
                if let json = try? JSON(data: value) {
                    //print(json)
                    let countMembersArray = json["response"].arrayValue.map {ModelGroup.addID(from: $0)}
                    var i = 0
                    for eachCount in countMembersArray{
                        groups[i].membersCount = eachCount
                        //print(groups)
                        i = i + 1
                    }
                    completion?(groups,nil)
                }
            }
        }
    }
    
    func idsOfGroups(Groups: [ModelGroup]) -> String{
        var result = ""
        var counter = 0
        for eachGroup in Groups {
            counter = counter + 1
            result.append(eachGroup.groupID!)
            if counter != Groups.count{
                result.append(",")
            }
        }
        return result
    }
    //MARK: - Realm Methods
    func saveData <T:Object> (someRealmArray array: [T]){
        let realm = try! Realm()
        do {
            try realm.write {
                let itemsForRemove = realm.objects(T.self)
                realm.delete(itemsForRemove)
                realm.add(array)
                try realm.commitWrite()
            }
        } catch {
            print(error)
            return
        }
    }
    
    //MARK: - Load Posts From the Wall
    func loadPosts(withOffset offset: Int = 0, completion:(([ModelPost]?, Error?, Int?)->Void)?){
        let path = "https://api.vk.com/method/wall.get"
        let parameters: Parameters = [
            "access_token": token,
            "v": "5.80",
            "offset": String(offset),
            "count": "100"
            ]
        Alamofire.request(path, parameters: parameters).responseJSON { (response) in
            if let error = response.error{
                print (error)
            }
            if let value = response.data {
                if let json = try? JSON(data: value) {
                    print(json)
                    let posts = json["response"]["items"].arrayValue.map {ModelPost(json: $0)}
                    //print(posts)
                    let count = Int(json["response"]["count"].stringValue)
                    completion?(posts,nil,count)
                }
            }
        }
    }
}
























