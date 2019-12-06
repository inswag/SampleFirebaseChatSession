//
//  ChatViewController.swift
//  TalkApp
//
//  Created by 박인수 on 24/11/2019.
//  Copyright © 2019 inswag. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    var comments: [ChatModel.Comment] = []
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var myButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        //        sendMessage()
        myButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        getMessageList()
    }
    
    func getMessageList() {
        Database.database().reference()
            .child("chatrooms")
            .child(chatRoomUid!)
            .child("comments")
            .observe(DataEventType.value) { (dataSnapshot) in
                print(dataSnapshot.childrenCount)
                self.comments.removeAll()
                
                for child in dataSnapshot.children {
                    let item = child as! DataSnapshot
                    let value = item.value as! [String:Any]
                    let commentFromServer = ChatModel.Comment(JSON: value)
                    self.comments.append(commentFromServer!)
                }
                self.mainTableView.reloadData()
        }
    }
    
    var chatRoomUid : String?
    
    @objc func sendMessage() {
        let message: [String : Any] = [
            "uid" : Auth.auth().currentUser?.uid,
            "message" : myTextField.text!,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference()
            .child("chatrooms")
            .child(chatRoomUid!)
            .child("comments")
            .childByAutoId()
            .setValue(message)
    }
    
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myUid = Auth.auth().currentUser?.uid
        
        if comments[indexPath.row].uid == myUid {
            let myCell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageCell
            myCell.messageLabel.text = comments[indexPath.row].message
            return myCell
        } else {
            let destinationCell = tableView.dequeueReusableCell(withIdentifier: "destinationMessageCell", for: indexPath) as! DestinationMessageCell
            destinationCell.messageLabel.text = comments[indexPath.row].message
            return destinationCell
        }
        
    }
    
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
}
