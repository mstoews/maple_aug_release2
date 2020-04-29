//
//  RegistrationViewModel.swift
//  Maple
//
//  Created by Murray Toews on 2020/03/31.
//  Copyright © 2020 Murray Toews. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                completion(err)
                return
            }
            
            print("Successfully registered user:", res?.user.uid ?? "")
            self.saveImageToFirebase(completion: completion)
        }
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) ->()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: { (_, err) in
            
            if let err = err {
                completion(err)
                return // bail
            }
            
            print("Finished upading image to storage")
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
            
        })
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        if let fullName = fullName {
            let values: [String: Any] = ["profileImageUrl": imageUrl,
                                         "username": fullName as Any,
                                         "followCount": 0  ,
                                         "followerCount": 0 ,
                                         "postCount": 0  ,
                                         "_search_index": ["full_name": fullName.lowercased(),
                                                           "reversed_full_name": fullName.components(separatedBy: " ")
                                                            .reversed().joined(separator: "")]]
            
            Firestore.firestore().collection("users").document(uid).collection("profile").document(uid).setData(values) { (err) in
                self.bindableIsRegistering.value = false
                if let err = err {
                    completion(err)
                    return
                }
                completion(nil)
            }
        }
    }
}

