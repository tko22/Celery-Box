//
//  GroceryListViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/10/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit
import CoreData

class GroceryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UISearchResultsUpdating{
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    @IBOutlet weak var findStoreButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //LATER: get from text file
    var list_items = [Int:String]()
    
    var searchActive = false
    var filteredArray = [String]()
    var searchController: UISearchController!
    let lightlightGray = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<ItemTypes> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<ItemTypes> = ItemTypes.fetchRequest()
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        //fetchRequest.predicate = NSPredicate(format: "lists.name contains [cd] %@", "defaultList")
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        list_items = fillItemListArry(fileName: "items")!
        
        self.tableView.tableFooterView = UIView()
        configureSearchController()
        tableView.delegate = self
        searchBar.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection OK")
        }
        else{
            let alert = UIAlertController(title: "Connection Error", message: "Oops! Check if your internet connection is working." , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                self.dismiss(animated: true,completion:nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addListAction(_ sender: Any) {
        let items = fetchedResultsController.fetchedObjects
        do {
            for x in items!{
                managedObjectContext.delete(x)
                try managedObjectContext.save()
                searchActive = false
                self.tableView.reloadData()
                
            }
        } catch{
            print("cant delete")
        }
       
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func editButton(){
        findStoreButton.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        findStoreButton.setImage(UIImage(named:"cart"), for: .normal)
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.placeholder = "Add Item..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        self.tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.setImage(UIImage(named: "add"), for: .search, state: .normal)
        searchController.searchBar.backgroundColor = lightlightGray
        searchController.searchBar.searchTextPositionAdjustment = UIOffsetMake(10.0, 0.0)
        let txtSearchField = searchController.searchBar.value(forKey: "_searchField") as? UITextField
        txtSearchField?.borderStyle = .none
        txtSearchField?.backgroundColor = lightlightGray
        txtSearchField?.textAlignment = .left
        txtSearchField?.rightViewMode = .always
        txtSearchField?.frame.size.height = 35
        txtSearchField?.font = UIFont(name: "Raleway",size: 14)
    }
    func fillItemListArry(fileName: String) -> [Int:String]? {
        let path = Bundle.main.path(forResource: fileName, ofType: "txt")
        var return_array = [Int:String]()
        do {
            let text = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let itemsarray = text.components(separatedBy: ",")
            for item in itemsarray{
                let arr = item.components(separatedBy: "^")
                return_array[Int(arr.first!)!]=arr[1].replacingOccurrences(of: "_", with: " ")
            }
            return(return_array)
        } catch _ as NSError {
            return nil
        }

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredArray = list_items.values.filter({ (item) -> Bool in
            let itemText: NSString = item as NSString
            
            return (itemText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchController.searchBar.resignFirstResponder()
        searchActive = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            self.tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        self.tableView.reloadData()
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive{
            return filteredArray.count
        }
        else {
            guard let sections = fetchedResultsController.sections else {
                fatalError("No sections in fetchedResultsController")
            }
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroceryListTableViewCell.reuseIdentifier, for: indexPath) as? GroceryListTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        if searchActive{
            self.tableView.allowsSelection = true
            cell.itemNameLabel?.text = filteredArray[indexPath.row]
        }
        else {
            self.tableView.allowsSelection = false
            let item = fetchedResultsController.object(at: indexPath)
            cell.itemNameLabel?.text = item.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchActive {
            let item_name = filteredArray[indexPath.row]
            searchController.isActive = false
            do {
                let itemtype = NSEntityDescription.insertNewObject(forEntityName: "ItemTypes", into: managedObjectContext) as! ItemTypes
                itemtype.name = item_name
                itemtype.creationDate = NSDate()
                if let key = self.list_items.someKey(forValue: item_name) {
                    itemtype.id = Int64(key)
                    print("saved item",key)
                }
                //TODO: add list relationship
                searchActive = false
                self.tableView.reloadData()
                
                try managedObjectContext.save()
            } catch {
                print("cant save item")
            }
        }
        else{
            print("row selected when search isn't activated")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managedObjectContext.delete(fetchedResultsController.object(at: indexPath))
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

}

extension GroceryListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            searchActive = false
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.0
    }
}
