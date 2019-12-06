//
//  SignUpViewController.swift
//  TalkApp
//
//  Created by 박인수 on 10/11/2019.
//  Copyright © 2019 inswag. All rights reserved.
//

// TOPIC
// SDWebImage vs Kingfisher ? - 속도차이인데 크게 차이나진 않음. 웹 이미지가 킹피셔보다 쓰기 편해서 걍 씀...
//.observe 와 .observeSingleEvent 의 차이는 파베의 값이 바뀌었을 때 바로 알랴줌. 옵저브만. 이를 통해 값을 바꿔주면서 채팅앱 구현 가능.


import UIKit
import Firebase
import SDWebImage

class SignUpViewController: UIViewController, UINavigationControllerDelegate {
    
    // Image
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var albumButton: UIButton!
    
    // Text
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonAction()
    }
    
    func addButtonAction() {
        signUpButton.addTarget(self, action: #selector(actionSignup), for: .touchUpInside)
        albumButton.addTarget(self, action: #selector(actionSelectImage), for: .touchUpInside)
    }
    
    @objc func actionSignup() {
        var userModel = UserModel()
        
        // 1단계 : 아이디 생성 (Auth 이용) & PW는 꼭 6자리 이상 그리고 이메일 형식 지키기.
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (auth, err) in
            
            if err == nil {
                // 현재 유저의 고유값 가져오기(주민번호)
                guard let uid = auth?.user.uid else { return }
                // data : Image Picker Controller 에서 선택했던 이미지를 Storage 에 올리기 위해 데이터화(이미지 용량이 크니까 0.3 압축)
                guard let data = self.mainImageView.image?.jpegData(compressionQuality: 0.3) else { return }
                // riversRef : 이미지 데이터를 Storage 에 저장하기 위한 경로 설정(파일 이름은 Unique 해야 한다)
                let riversRef = Storage.storage().reference().child("images").child("\(uid).png")
                
                // 2단계 : 이미지 업로드 코드 (예전에는 putData 의 클로저를 통해 받았지만 이제 위의 riversRef 를 통해 접근하게 되었다)
                riversRef.putData(data, metadata: nil) { (metadata, error) in
                    // 이미지 다운로드 URL
                    riversRef.downloadURL { (url, error) in
                        
                        userModel.userName = self.nameTextField.text
                        userModel.uid = uid
                        userModel.profileImageUrl = url?.absoluteString
                        
                        // 3단계 : 데이터베이스에 매핑 처리할 userModel 을 JSON 형식으로 저장.
                        Database.database().reference()
                            .child("users")
                            .child(uid)
                            .setValue(userModel.toJSON())
                    }
                }
            
            }
            print("Finished your enrollment to Firebase")
        }
    }
    
    @objc func actionSelectImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        self.mainImageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
}
