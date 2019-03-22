import UIKit
import Firebase
import MaterialComponents

class CommentsController: MDCCollectionViewController, CommentInputAccessoryViewDelegate {
    
    var post: FSPost?
    let cellId = "cellId"
    var sizingCell: CommentCell!
    var insets: UIEdgeInsets!
    var comments = [Comment]()
    var docRef : DocumentReference!
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        collectionView?.backgroundColor = UIColor.veryLightGray()
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: -20, right: -10)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -40, right: -10)
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        sizingCell = CommentCell()
        styler.cellStyle = .card
        styler.gridColumnCount = 2
        styler.cellLayoutType = .grid
        styler.gridPadding = 4
        
        let insets = self.collectionView(collectionView!,
                                         layout: collectionViewLayout,
                                         insetForSectionAt: 0)
        let cellFrame = CGRect(x: 0, y: 0, width: (collectionView?.bounds.width)! - insets.left - insets.right,
                               height: (collectionView?.bounds.height)!)
        sizingCell.frame = cellFrame
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            collectionView?.refreshControl = refreshControl
            
            
        }
        
        //fetchComments()
        observeComments()
    }
    
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        sender.beginRefreshing()
        observeComments()
        sender.endRefreshing()
    }
    
    
//    fileprivate func fetchComments() {
//        comments.removeAll()
//        if let postId = self.post?.id {
//            Firestore.firestore().collection("posts").document(postId).collection("comments").getDocuments() {
//                (querySnapshot, err) in
//                if let err = err  {
//                    print("Error getting documents: \(err)");
//                }
//                else  {
//                    
//                    for document in querySnapshot!.documents {
//                        let uid = document["uid"] as! String
//                        Database.fetchUserWithUID(uid: uid, completion: { (user) in
//                            let comment = Comment(user: user, dictionary: document.data())
//                            self.comments.append(comment)
//                        })
//                        self.collectionView?.reloadData()
//                    }
//                }
//            }
//        }
//    }
//    
    
   
    deinit {
        listener?.remove()
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func observeComments()
    {
        stopObserving()
        comments.removeAll()
        self.collectionView?.reloadData()
        if let postId = self.post?.id {
            self.listener =
                db.collection("posts").document(postId).collection("comments")
                    .order(by: "creationDate", descending: false)
                    .addSnapshotListener{  (snapshot, error) in
                        guard let snapshot = snapshot else {
                            print("Error fetching snapshot results: \(error!)")
                            return
                        }
                        self.comments.removeAll()
                        for document in snapshot.documents {
                            let comment = Comment(dictionary: document.data())
                            self.comments.append(comment)
                            self.collectionView?.reloadData()
                        }
                        
            }
        }
    }
    
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        comments.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()

        let targetSize = CGSize(width: view.frame.width  , height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)

        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width - 30, height: height)
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellHeightAt indexPath: IndexPath) -> CGFloat {
        let comment = self.comments[indexPath.item]
        sizingCell.populateContent(username: comment.username, profileImageUrl: comment.profileImageUrl , text: comment.text, date: comment.creationDate, index: indexPath.item, isDryRun: true )
        sizingCell.setNeedsUpdateConstraints()
        sizingCell.updateConstraintsIfNeeded()
        sizingCell.contentView.setNeedsLayout()
        sizingCell.contentView.layoutIfNeeded()

        var fittingSize = UILayoutFittingCompressedSize
        fittingSize.width = sizingCell.frame.width
        let size = sizingCell.contentView.systemLayoutSizeFitting(fittingSize)
        return size.height
    }

    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        let comment = self.comments[indexPath.item]
        cell.populateContent(username: comment.username, profileImageUrl: comment.profileImageUrl , text: comment.text, date: comment.creationDate, index: indexPath.item, isDryRun: false)
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    func didSubmit(for comment: String) {
        if comment.count > 0 {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let postId = self.post?.id ?? ""
            
            Firestore.fetchUserWithUID(uid: uid ,  completion: { (mapleUser) in
                let values = ["text": comment,
                              "creationDate": Date().timeIntervalSince1970,
                              "postUid" : self.post?.uid ?? "uid",
                              "username" : mapleUser.username,
                              "imageProfileUrl" : mapleUser.profileImageUrl,
                              "uid": uid,
                              "postId" : self.post?.id ?? ""
                    ]
                    as [String : Any]
                
                self.db.collection("posts").document(postId).collection("comments").document().setData(values)
                {
                    err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully postId: " + postId)
                    }
                }
            })
        }
    }
    
   
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

