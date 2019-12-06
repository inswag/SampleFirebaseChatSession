//
//  ViewController.swift
//  TalkApp
//
//  Created by 박인수 on 10/11/2019.
//  Copyright © 2019 inswag. All rights reserved.
//

import UIKit

import Firebase
import SDWebImage

class PeopleViewController: UIViewController {
    
    @IBOutlet weak var mainTableview: UITableView!
    
    var imgArray = [UIImage(named:"p1"), UIImage(named:"p2"), UIImage(named:"p3")]
    
    var destinationUid : String?
    var chatRoomUid : String?
    var array: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView
        mainTableview.delegate = self
        mainTableview.dataSource = self
        
        // Firebase
        fetchPeople()
    }
    
    func fetchPeople() {
        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
            self.array.removeAll()
            for child in snapshot.children {
                let item = child as! DataSnapshot
                let value = item.value as! [String: Any]
                let userModel = UserModel(JSON: value)
                self.array.append(userModel!)
            }
            self.mainTableview.reloadData()
        }
    }
    
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! MyItemCell
        cell.nameLabel.text = array[indexPath.row].userName
        
        let url = array[indexPath.row].profileImageUrl
        cell.mainImageView.sd_setImage(with: URL(string: url!), completed: nil)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myUid = Auth.auth().currentUser?.uid  // 나의 UID
        self.destinationUid = array[indexPath.row].uid // 대화할 상대방 ID
        
        Database.database().reference()
            .child("chatrooms")
            .queryOrdered(byChild: "users/" + myUid!)
            .queryEqual(toValue: true)
            .observeSingleEvent(of: .value) { (dataSnapshot) in
                
                // 방이 하나도 없을 때
                if dataSnapshot.childrenCount == 0 {
                    self.createRoom(uid: myUid!, destinationUid: self.destinationUid!)
                    return
                }
                self.chatRoomUid = nil
                
                // 내가 소속된 방을 다 읽어옴
                for child in dataSnapshot.children {
                    let item = child as! DataSnapshot
                    let value = item.value as! [String: Any]
                    let chatModel = ChatModel(JSON: value)
                    
                    // 일일이 방을 탐색하면서 내가 대화하고 싶은 상대방이 있는 방의 이름 값을 가져옴
                    if chatModel?.users[self.destinationUid!] == true {
                        self.chatRoomUid = item.key
                        self.performSegue(withIdentifier: "detailChatSegue", sender: nil)
                        break
                    }
                }
                
                if self.chatRoomUid == nil {
                    self.createRoom(uid: myUid!,destinationUid: self.destinationUid!)
                }
        }
        
    }
    
    
    // 방 생성 코드
    func createRoom(uid : String, destinationUid : String){
        let createRoomInfo : Dictionary<String,Any> = [
            "users" : [
                uid: true,
                destinationUid :true
            ]
        ]
        
        Database.database().reference()
            .child("chatrooms")
            .childByAutoId().setValue(createRoomInfo, withCompletionBlock: { (err, ref) in
                self.chatRoomUid = ref.key
//                print(self.chatRoomUid)
                self.performSegue(withIdentifier: "detailChatSegue", sender: nil)
            })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailChatSegue" {
            let vc = segue.destination as! ChatViewController
            vc.chatRoomUid/*채팅 화면*/ = chatRoomUid/*친구목록*/
        }
    }
}

class MyItemCell: UITableViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}
