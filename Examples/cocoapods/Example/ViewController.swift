//
//  ViewController.swift
//  Example
//
//  Created by asharijuang on 28/02/20.
//  Copyright © 2020 qiscus. All rights reserved.
//

import UIKit
import QiscusMultichannelWidget

class ViewController: UIViewController {

    @IBOutlet weak var btStart: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtUserId: UITextField!
    //sample user properties
    let userProp = [["key":"job","value":"development"],["key":"Location","value":"Yogyakarta"]]
    //sample extras
    let ext = "{\"sample\":\"extras\"}"
    //sample avatar
    let ava = "https://image.flaticon.com/icons/svg/145/145867.svg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.btStart.layer.cornerRadius = 4
        
        if ChatManager.shared.isLoggedIn() {
            if let user =  ChatManager.shared.getUser(){
                ChatManager.shared.setUser(id: user.id, displayName: user.name, avatarUrl: user.avatarUrl.absoluteString, userProperties: userProp)
                ChatManager.shared.startChat(from: self, extras: ext, transition: .push(animated: true))
            }
        }
        
    }
    
    @IBAction func openMultichannel(_ sender: Any) {
        
        if ChatManager.shared.isLoggedIn() {
            ChatManager.shared.signOut()
            btStart.setTitle("START ->", for: .normal)
            txtUsername.text = ""
            txtUserId.text = ""
        }else{
            guard let userId = self.txtUserId.text, userId.count > 0 else {
                showError(message: "userId can't empty")
                return // or throw
            }
            
            guard let username = self.txtUsername.text, username.count > 0 else {
                showError(message: "username can't empty")
                return
            }
            
            ChatManager.shared.setUser(id: userId, displayName: username, avatarUrl: ava, userProperties: self.userProp)
            ChatManager.shared.startChat(from: self, extras: ext, transition: .push(animated: true))
        }
        
       
    }
    
    func showError(message : String) {
        let alert = UIAlertController(title: "warning", message: String(describing: message), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        if ChatManager.shared.isLoggedIn() {
            if let user =  ChatManager.shared.getUser(){
                txtUsername.text = user.name
                txtUserId.text = user.id
                
                btStart.setTitle("LOGOUT", for: .normal)
            }
        }else{
            btStart.setTitle("START ->", for: .normal)
        }
    }
    
}

