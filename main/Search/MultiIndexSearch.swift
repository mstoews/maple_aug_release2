import UIKit
import InstantSearchCore

class HitsViewController: MultiHitsTableViewController {
    
    @IBOutlet weak var tableView: MultiHitsTableWidget!
    
    
    let searcherIds = [SearcherId(index: "posts"), SearcherId(index: "location"), SearcherId(index: "Users") ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        InstantSearch.shared.configure(appID:  AlgoliaManager.appId , apiKey: AlgoliaManager.apiKey, searcherIds: searcherIds)
        
        hitsTableView = tableView
        
        InstantSearch.shared.registerAllWidgets(in: self.view)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, containing hit: [String : Any]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hitCell", for: indexPath)
        
        if indexPath.section == 0 { // bestbuy
            cell.textLabel?.highlightedTextColor = .blue
            cell.textLabel?.highlightedBackgroundColor = .yellow
            cell.textLabel?.highlightedText = SearchResults.highlightResult(hit: hit, path: "name")?.value
        } else { // store_index
            cell.textLabel?.highlightedTextColor = .white
            cell.textLabel?.highlightedBackgroundColor = .black
            cell.textLabel?.highlightedText = SearchResults.highlightResult(hit: hit, path: "name")?.value
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        
        let view = UIView()
        view.addSubview(label)
        view.backgroundColor = UIColor.gray
        return view
    }
}

