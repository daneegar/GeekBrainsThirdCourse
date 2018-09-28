//
//  LoginVK.swift
//  challenge
//
//  Created by Denis Garifyanov on 28/06/2018.
//  Copyright © 2018 Denis Garifyanov. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class LoginVK: UIViewController {
   

    @IBOutlet weak var webView: WKWebView!
    
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        if let request = vkAuthRequest() {
            webView.load(request)
        }
    }
    //MARK: - Передача token во вью
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(segue.identifier!)
                if let friendsVC = segue.destination as? TabBarViewController {
                    if let cathchedToken = self.token
                    {friendsVC.token = cathchedToken}
                }
    }
    
    func vkAuthRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "6618655"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: "262150"),
            URLQueryItem(name: "v", value: "5.74")
        ]
        
        if let url = urlComponents.url {
            return URLRequest(url: url)
        }
        
        return nil
    }
}

//MARK: - WKNavigationDelegate
extension LoginVK: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else {
                decisionHandler(.allow)
                return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .map({ $0.components(separatedBy: "=") })
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        let session = Session.instance
        if let token = params["access_token"], let user_id = params["user_id"] {
            self.token = token
            session.token = token
            session.id = Int(user_id)!
            print (session.id)
            performSegue(withIdentifier: "successLogin", sender: nil)
        }
        
        decisionHandler(.allow)
    }
}


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


