import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents

class UserFollowersController : UserFollowingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Following"
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(UserFollowingCell.self, forCellWithReuseIdentifier: cellId)
        fetchData()
        
    }
    
    override func fetchData()
    {
        if let uid = Auth.auth().currentUser?.uid {
            if uid != user?.uid {
                return
            }
            Firestore.fetchUserFollowedByUserId(uid: uid) { (userList) in
                for uid in userList {
                    print(uid)
                    Firestore.fetchUserWithUID(uid: uid) {  [weak self] (user) in
                        guard let strongSelf = self else {return}
                        DispatchQueue.main.async {
                            strongSelf.userFollowing.append(user)
                            strongSelf.collectionView?.reloadData()
                        }
                    }
                }
            }
        }
    }
}
