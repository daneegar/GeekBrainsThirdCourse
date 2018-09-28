//
//  ViewController.swift
//  challenge
//
//  Created by Denis Garifyanov on 15/06/2018.
//  Copyright © 2018 Denis Garifyanov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var ScrolView: UIScrollView!
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!

    var autorisationStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hideKeyBoardGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        ScrolView?.addGestureRecognizer(hideKeyBoardGesture)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - notification center
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadWasShown), name: NSNotification., object: <#T##Any?#>)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadWasShown), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.​​keyboardWillBeHidden), name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK - autorization
    @IBAction func loginButtonPressed(_ sender: Any) {
        let typedLogin = loginInput.text!
        let typedPassword = passwordInput.text!
        autorization(login: typedLogin, password: typedPassword)
    }
    
    func autorization(login: String, password: String){
        if login == "admin" && password == "123456"{
            print("Успешная авторизация")
            autorisationStatus = true
        } else {
             print("неспешная авторизация")
            autorisationStatus = false
        }
    }
   
    
    //MARK - keyboards events
    @objc func keyboadWasShown (notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentLnSets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        
        self.ScrolView?.contentInset = contentLnSets
        self.ScrolView?.scrollIndicatorInsets = contentLnSets
    }
   
    @objc func ​​keyboardWillBeHidden(​​notification: Notification){
        let contenLnSets = UIEdgeInsets.zero
        self.ScrolView?.contentInset = contenLnSets
        self.ScrolView?.scrollIndicatorInsets = contenLnSets
    }
    
    @objc func hideKeyboard() {
        self.ScrolView?.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "userLogined"{
//            let destinatinoVC = segue.destination as! TabBarViewController
//            
//            if autorisationStatus {
//                //destinatinoVC.buttonStatus.setTitle("Success", for: .normal)
//                autorisationStatus = false
//            }
            
            print("Segue Prepered")
        }
    }
    


