//
//  SearchAlgoliaCollectionView.swift
//  AFNetworking
//
//  Created by Murray Toews on 2018/05/04.
//


//import AFNetworking
import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents
import AlgoliaSearch
import InstantSearchCore


enum SearchType {
    case USR
    case PRD
    case LOC
}

class SearchAlgoliaCollectionView: MDCCollectionViewController , UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, SearchProgressDelegate , SearchHeaderDelegate  {
    
     // let searchController = UISearchController(searchResultsController: nil)
    
    var fullTextSearch: Searcher!
    
    var postHits: [JSONObject] = []
    var locationHits: [JSONObject] = []
    var userHits: [JSONObject] = []
    
    var originIsLocal: Bool = false
    
    let postCellId = "postCellId"
    let headerId = "headerId"
    let mapCellId = "mapCellId"
    let userCellId = "userCellId"
    
    @objc func didSearchLocation() {
        print("SearchAlgoliaCollectionView::didSearchLocation")
        //spinner = displaySpinner()
        TYPE = SearchType.LOC
        fullTextSearch = Searcher(index: AlgoliaManager.sharedInstance.location, resultHandler: self.handleLocationResults)
        fullTextSearch.params.hitsPerPage = 15
        
        fullTextSearch.params.attributesToRetrieve = ["*" ]
        fullTextSearch.params.attributesToHighlight = ["location"]
        
        // Configure search progress monitoring.
        searchProgressController = SearchProgressController(searcher: fullTextSearch)
        searchProgressController.delegate = self
        updateSearchResults(for: searchController)
        
        // refresh with Location seach
        
    }
    
    
    
    @objc func didSearchUser() {
        print("SearchAlgoliaCollectionView::didSearchUser")
        TYPE = SearchType.USR
        // refresh with Users Search
        fullTextSearch = Searcher(index: AlgoliaManager.sharedInstance.users, resultHandler: self.handleUserResults)
        fullTextSearch.params.hitsPerPage = 15
        
        fullTextSearch.params.attributesToRetrieve = ["*" ]
        fullTextSearch.params.attributesToHighlight = ["user"]
        
        // Configure search progress monitoring.
        searchProgressController = SearchProgressController(searcher: fullTextSearch)
        searchProgressController.delegate = self
        updateSearchResults(for: searchController)
    }
    
    @objc func didSearchProducts() {
        print("SearchAlgoliaCollectionView::didSearchProducts")
        TYPE = SearchType.PRD
        //spinner = displaySpinner()
        //refresh with products search
        fullTextSearch = Searcher(index: AlgoliaManager.sharedInstance.posts, resultHandler: self.handleSearchResults)
        fullTextSearch.params.hitsPerPage = 15
        
        fullTextSearch.params.attributesToRetrieve = ["*" ]
        fullTextSearch.params.attributesToHighlight = ["product"]
        
        // Configure search progress monitoring.
        searchProgressController = SearchProgressController(searcher: fullTextSearch)
        searchProgressController.delegate = self
        updateSearchResults(for: searchController)
    }

    var TYPE = SearchType.PRD
    var searchProgressController: SearchProgressController!
    
    
    lazy var searchController: UISearchController = {
            let sc = UISearchController(searchResultsController: nil)
            sc.hidesNavigationBarDuringPresentation = false
            sc.dimsBackgroundDuringPresentation = true
            //sc.searchBar.barTintColor = UIColor.collectionBackGround()
            sc.searchBar.delegate = self
            return sc
    }()
    
    @objc func pressCancelButton(button: UIButton) {
        //searchEvent.isEnabled = true
    }
    
    func setUpSearchBar(){
        searchController.searchBar.showsCancelButton = true
        var cancelButton: UIButton
        
        let topView: UIView = self.searchController.searchBar.subviews[0] as UIView
        for subView in topView.subviews {
            if let pvtClass = NSClassFromString("UINavigationButton") {
                if subView.isKind(of: pvtClass) {
                    cancelButton = subView as! UIButton
                    
                    cancelButton.setTitle("", for: .normal)
                    cancelButton.setImage(UIImage(named:"ic_close"), for: .normal)
                    cancelButton.addTarget(self, action: #selector(pressCancelButton(button:)), for: .touchUpInside)
                }
            }
        }
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("search_bar_placeholder", comment: "Search control bar")
        
        searchController.hidesNavigationBarDuringPresentation = false
        //searchController.searchBar.tintColor = UIColor.themeColor()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .default
        navigationItem.titleView = searchController.searchBar
        searchController.searchBar.sizeToFit()
    }
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        
        collectionView?.backgroundColor = UIColor.collectionBackGround()
        collectionView?.register(PostSearchCollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)

        // Algolia Search
        collectionView?.register(PostCollectionCell.self, forCellWithReuseIdentifier: postCellId)
        collectionView?.register(MapCollectionCell.self,  forCellWithReuseIdentifier: mapCellId)
        collectionView?.register(UserCollectionCell.self, forCellWithReuseIdentifier: userCellId)
        definesPresentationContext = false
        

        self.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        
        // Search controller
        didSearchProducts()
        // First load
        self.navigationItem.title = "Search"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch TYPE
        {
            case SearchType.USR :
                let userRecord = UserRecord(json: userHits[indexPath.item])
                self.openUserSelected(userRecord: userRecord)
                break
            case SearchType.LOC :
                let locationRecord = LocationRecord(json: locationHits[indexPath.item])
                self.openLocationSelected(locationRecord: locationRecord)
                break
            case SearchType.PRD :
                let postRecord = PostRecord(json: postHits[indexPath.item])
                self.openSearchSelected(postRecord: postRecord)
                break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         switch TYPE
            {
            case SearchType.USR :
                let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserCollectionCell
                if indexPath.row + 10 >= userHits.count {
                    fullTextSearch.loadMore()
                }
                userCell.userRecord = UserRecord(json: userHits[indexPath.row])
                return userCell
            case SearchType.LOC :
                let locationCell = collectionView.dequeueReusableCell(withReuseIdentifier: mapCellId, for: indexPath) as! MapCollectionCell
                if indexPath.row + 10 >= locationHits.count {
                    fullTextSearch.loadMore()
                }
                locationCell.locationRecord = LocationRecord(json: locationHits[indexPath.row])
                return locationCell
            case SearchType.PRD :
                let postcell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostCollectionCell
                if indexPath.row + 10 >= postHits.count {
                    fullTextSearch.loadMore()
                }
                postcell.post = PostRecord(json: postHits[indexPath.row])
                return  postcell
            }
    }
    
     override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PostSearchCollectionHeader
        header.delegate = self
        return header
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 1, 1, 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                self.searchController.searchBar.becomeFirstResponder()
            })
        })
        navigationController?.navigationBar.tintColor = .gray
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.navigationBar.barTintColor = UIColor.themeColor()
        navigationController?.navigationBar.tintColor = UIColor.collectionBackGround()
    }

    
    private func handleSearchResults(results: SearchResults?, error: Error?, userInfo: [String: Any]) {
        guard let results = results else { return }
        if results.page == 0 {
            postHits = results.hits
        } else {
            postHits.append(contentsOf: results.hits)
        }
        originIsLocal = results.content["origin"] as? String == "local"
        self.collectionView?.reloadData()
    }
    
    private func handleLocationResults(results: SearchResults?, error: Error?, userInfo: [String: Any]) {
        guard let results = results else { return }
        if results.page == 0 {
            locationHits = results.hits
        } else {
            locationHits.append(contentsOf: results.hits)
        }
        originIsLocal = results.content["origin"] as? String == "local"
        self.collectionView?.reloadData()
    }
    
    private func handleUserResults(results: SearchResults?, error: Error?, userInfo: [String: Any]) {
        guard let results = results else { return }
        if results.page == 0 {
            userHits = results.hits
        } else {
            userHits.append(contentsOf: results.hits)
        }
        originIsLocal = results.content["origin"] as? String == "local"
        self.collectionView?.reloadData()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch TYPE
        {
        case SearchType.USR :
            return CGSize(width: view.frame.width - 15 , height: 110)
        case SearchType.LOC :
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 60)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            
            if locationHits.count > 0 {
                let location = locationHits[indexPath.item]
                let estimatedFrame = NSString(string: location.description ).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                return CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + 55)
            }
            else {
                return CGSize(width: view.frame.width - 15 , height: 120)
            }
        case SearchType.PRD :
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 60)
            let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = postHits[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            return CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + 60)
        }
    }
    
    let db = Firestore.firestore()
    
    func openSearchSelected(postRecord: PostRecord)
    {
        if let postId = postRecord.objectID {
            let docRef = db.collection("posts").document(postId)
            docRef.getDocument()
                { (document, error) in
                    if let document = document {
                        if let dataDescription = document.data().map(String.init(describing:)) {
                        
                            let data = document.data() as! [String: Any]
                            let post = FSPost(dictionary: data, postId: postId)
                            let editPostController = PostViewerController()
                            editPostController.post = post
                            self.navigationController?.pushViewController( editPostController, animated: true)
                        
                            print("Cached document data: \(dataDescription)")
                        }
                    } else {
                        print("Document does not exist in cache")
                    }
            }
        }
    }
    
    
    func openLocationSelected(locationRecord: LocationRecord)
    {
          let postId = locationRecord.objectID
            let docRef = db.collection("posts").document(postId)
            docRef.getDocument()
                { (document, error) in
                    if let document = document {
                        if let dataDescription = document.data().map(String.init(describing:)) {
                            
                            let data = document.data() as! [String: Any]
                            let post = FSPost(dictionary: data, postId: postId)
                            let editPostController = PostViewerController()
                            editPostController.post = post
                            self.navigationController?.pushViewController( editPostController, animated: true)
                            
                            print("Cached document data: \(dataDescription)")
                        }
                    } else {
                        print("Document does not exist in cache")
                    }
            }
    }
        
    func openUserSelected(userRecord: UserRecord)
    {
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            if let uid = userRecord.objectID {
                Database.fetchUserWithUID(uid: uid) { (user) in
                    userProfileController.user = user
                    self.navigationController?.pushViewController(userProfileController, animated: true)
                }
            }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch TYPE
        {
        case SearchType.USR :
             return userHits.count
        case SearchType.LOC :
             return locationHits.count
        case SearchType.PRD :
             return postHits.count
        }
    }
    
    // MARK: - Search
    
    func updateSearchResults(for searchController: UISearchController) {
        fullTextSearch.params.query = searchController.searchBar.text
        fullTextSearch.search()
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
    
    func searchDidStart(_ searchProgressController: SearchProgressController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func searchDidStop(_ searchProgressController: SearchProgressController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}



