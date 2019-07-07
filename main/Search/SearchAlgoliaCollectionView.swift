//
//  SearchAlgoliaCollectionView.swift
//  AFNetworking
//
//  Created by Murray Toews on 2018/05/04.
//

import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents
import AlgoliaSearch
import InstantSearchCore
import JGProgressHUD


enum SearchType {
    case USR
    case PRD
    case LOC
}

class SearchAlgoliaCollectionView: MDCCollectionViewController , UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, SearchProgressDelegate , SearchHeaderDelegate  {
    
    var fullTextSearch: Searcher!
    
    var postHits: [JSONObject] = []
    var locationHits: [JSONObject] = []
    var userHits: [JSONObject] = []
    
    var originIsLocal: Bool = false
    
    let postCellId = "postCellId"
    let headerId = "headerId"
    let mapCellId = "mapCellId"
    let userCellId = "userCellId"
    
    var TYPE = SearchType.PRD
    var searchProgressController: SearchProgressController!
    
    @objc func didSearchLocation() {
        print("SearchAlgoliaCollectionView::didSearchLocation")
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = NSLocalizedString("FetchLocations", comment: "Fetching Locations")
        hud.show(in: view)
        
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
         hud.dismiss(afterDelay: 1)
        
    }
    
    
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    
    @objc func didSearchUser() {
        print("SearchAlgoliaCollectionView::didSearchUser")
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = NSLocalizedString("FetchUsers", comment: "Fetching Users")
        hud.show(in: view)
        
        TYPE = .USR
        // refresh with Users Search
        fullTextSearch = Searcher(index: AlgoliaManager.sharedInstance.users, resultHandler: self.handleUserResults)
        fullTextSearch.params.hitsPerPage = 30
        
        fullTextSearch.params.attributesToRetrieve = ["*" ]
        fullTextSearch.params.attributesToHighlight = ["user"]
        
        // Configure search progress monitoring.
        searchProgressController = SearchProgressController(searcher: fullTextSearch)
        searchProgressController.delegate = self
        updateSearchResults(for: searchController)
        hud.dismiss(afterDelay: 1)
    }
    
  
    @objc func didSearchProducts() {
        TYPE = .PRD
        print("SearchAlgoliaCollectionView::didSearchProducts")
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = NSLocalizedString("FetchProd", comment: "Fetch Products")
        hud.show(in: view)
        
        fullTextSearch = Searcher(index: AlgoliaManager.sharedInstance.posts, resultHandler: self.handleSearchResults)
        fullTextSearch.params.hitsPerPage = 30
        fullTextSearch.params.attributesToRetrieve = ["*" ]
        fullTextSearch.params.attributesToHighlight = ["product"]
        
        // Configure search progress monitoring.
        searchProgressController = SearchProgressController(searcher: fullTextSearch)
        searchProgressController.delegate = self
        updateSearchResults(for: searchController)
        hud.dismiss(afterDelay: 1)
    }
    
    @objc func didSearch(index: String, name: String)
    {
        print("SearchAlgoliaCollectionView::didSearch")
        
        var algoIndex = AlgoliaManager.sharedInstance.posts
        fullTextSearch = Searcher(index: algoIndex  , resultHandler: self.handleSearchResults)
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = NSLocalizedString(name, comment: name)
        hud.show(in: view)
        
        switch index {
             case "product" :
                 TYPE = .PRD
                 algoIndex = AlgoliaManager.sharedInstance.posts
                 fullTextSearch = Searcher(index: algoIndex  , resultHandler: self.handleSearchResults)
                 fullTextSearch.params.attributesToHighlight = [index]
                 break
            case "user":
                 TYPE = .USR
                 algoIndex = AlgoliaManager.sharedInstance.users
                 fullTextSearch = Searcher(index: algoIndex  , resultHandler: self.handleUserResults)
                break
            case "location":
                 TYPE = .LOC
                 algoIndex = AlgoliaManager.sharedInstance.location
                 fullTextSearch = Searcher(index: algoIndex  , resultHandler: self.handleLocationResults)
                break
            default:
            TYPE = .PRD
        }
        
        
        fullTextSearch.params.hitsPerPage = 30
        
        fullTextSearch.params.attributesToRetrieve = ["*" ]
        fullTextSearch.params.attributesToHighlight = [index]
        
        // Configure search progress monitoring.
        searchProgressController = SearchProgressController(searcher: fullTextSearch)
        searchProgressController.delegate = self
        updateSearchResults(for: searchController)
        hud.dismiss(afterDelay: 1)
        
    }
    

    // lets implement a UISearchController
    let searchController = UISearchController(searchResultsController: nil)
    
    /*
    
    lazy var searchController: UISearchController = {
            let sc = UISearchController(searchResultsController: nil)
            sc.hidesNavigationBarDuringPresentation = true
            sc.dimsBackgroundDuringPresentation = true
            //sc.searchBar.barTintColor = UIColor.collectionBackGround()
            sc.searchBar.delegate = self
            return sc
    }()
     */
    
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
        
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        //searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("search_bar_placeholder", comment: "Search control bar")
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.searchBar.sizeToFit()
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        
        collectionView?.backgroundColor = UIColor.collectionBackGround()
        collectionView?.register(PostSearchCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)

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
        didSearch(index: "products", name: "FetchProd")
        // First load
        self.navigationItem.title = "Search"
        UINavigationBar.appearance().prefersLargeTitles = true
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
            case .USR :
                let userRecord = UserRecord(json: userHits[indexPath.item])
                self.openUserSelected(userRecord: userRecord)
                break
            case .LOC :
                let locationRecord = LocationRecord(json: locationHits[indexPath.item])
                self.openLocationSelected(locationRecord: locationRecord)
                break
            case .PRD :
                let postRecord = PostRecord(json: postHits[indexPath.item])
                print("Post Record from Search Prod .... \(postRecord)")
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
            case .USR :
                let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserCollectionCell
                if indexPath.row + 30 >= userHits.count {
                    fullTextSearch.loadMore()
                }
                userCell.userRecord = UserRecord(json: userHits[indexPath.row])
                return userCell
            case .LOC :
                let locationCell = collectionView.dequeueReusableCell(withReuseIdentifier: mapCellId, for: indexPath) as! MapCollectionCell
                if indexPath.row + 30 >= locationHits.count {
                    fullTextSearch.loadMore()
                }
                locationCell.locationRecord = LocationRecord(json: locationHits[indexPath.row])
                return locationCell
            case .PRD :
                let postcell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostCollectionCell
                if indexPath.row + 30 >= postHits.count {
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
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: view.frame.width, height: 40)
//    }
//

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
               // self.searchController.searchBar.becomeFirstResponder()
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
        print ("Results hits : \(results.hits.count)")
        if results.page == 0 {
            postHits = results.hits
        } else {
            postHits.append(contentsOf: results.hits)
        }
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.collectionViewLayout.prepare()
            self.collectionView.reloadData()
        }
        
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
        case .USR :
            return CGSize(width: view.frame.width - 15 , height: 110)
        case .LOC :
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 60)
            let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(15))]
            
            if locationHits.count > 0 {
                let location = locationHits[indexPath.item]
                let estimatedFrame = NSString(string: location.description ).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                return CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + 55)
            }
            else {
                return CGSize(width: view.frame.width - 15 , height: 120)
            }
        case .PRD :
            let approximateWidthOfBioTextView = view.frame.width
            let size = CGSize(width: approximateWidthOfBioTextView, height: 60)
            let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(15))]
            let post = postHits[indexPath.item]
            let estimatedFrame = NSString(string: post.description).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            var description = post.description
            description = description.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if description.count < 850 {
               return CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + 90)
            }
            else {
                 return CGSize(width: view.frame.width - 15 , height: estimatedFrame.height + 140)
            }
           
        }
    }
    
    let db = Firestore.firestore()
    
    func openSearchSelected(postRecord: PostRecord)
    {
        if let postId = postRecord.objectID {
            Firestore.fetchPostByPostId(postId: postId) { (post) in
                    Firestore.fetchUserWithUID(uid: post.uid) { [weak self] (user) in
                        guard let strongSelf = self else {return}
                        DispatchQueue.main.async {
                            //let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
                            //userProfileController.user = user
                            //strongSelf.navigationController?.pushViewController(userProfileController, animated: true)
                            
                            let userProductController = UserProductController(collectionViewLayout: UICollectionViewFlowLayout())
                            userProductController.setPostId(postId: postId)
                            userProductController.user = user
                            strongSelf.navigationController?.pushViewController(userProductController, animated: true)
                        }
                }
            }
        }
    }
    
    
    func openLocationSelected(locationRecord: LocationRecord)
    {
         // should be pointing to the location entry that contains a post id.
        
        guard let postId = locationRecord.postId else {
            print("Error fetching postId")
            return
        }
        
        let docRef = db.collection("posts").document(postId)
            docRef.getDocument()
                { (document, error) in
                    if let document = document {
                        if let dataDescription = document.data().map(String.init(describing:)) {
                            let data = document.data() as! [String: Any]
                            let post = Post(dictionary: data, postId: postId)
                            
                            //editPostController.post = post
                            //self.navigationController?.pushViewController( editPostController, animated: true)
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
                Firestore.fetchUserWithUID(uid: uid) { (user) in
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



