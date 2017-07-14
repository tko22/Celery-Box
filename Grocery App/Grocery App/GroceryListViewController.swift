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
    var list_items = ["Asparagus","Broccoli","Carrots","Cauliflower","Celery","Corn","Cucumbers","Lettuce ","Mushrooms","Onions","Peppers","Potatoes","Spinach","Squash","Zucchini","Tomatoes","Apples","Avocados","Bananas","Berries","Cherries","Grapefruit","Grapes","Kiwis","Lemons ","Limes","Melon","Nectarines","Oranges","Peaches","Pears","Plums","Bagels","Chip dip","Eggs","Fake eggs","English muffins","Fruit juice","Hummus","Ready-bake breads","Tofu","Tortillas","Breakfasts","Burritos","Fish sticks","Fries","Tater tots","Ice cream ","Sorbet","Juice concentrate","Pizza","Pizza Rolls","Popsicles","TV dinners","Vegetables","BBQ sauce","Gravy","Honey","Hot sauce","Jam ","Jelly ","Preserves","Ketchup","Mustard","Mayonnaise","Pasta sauce","Relish","Salad dressing","Salsa","Soy sauce","Steak sauce","Syrup","Worcestershire sauce","Bouillon cubes","Cereal","Coffee","Coffee filters","Instant potatoes","Lemon juice","Lime juice","Mac & cheese","Olive oil","Packaged meals","Pancake mix","Waffle mix","Pasta","Peanut butter","Pickles","Rice","Tea","Vegetable oil","Vinegar","Applesauce","Baked beans","Broth","Fruit","Olives","Tinned meats","Tuna","Chicken","Soup","Chili","Tomatoes","Veggies","Basil","Black pepper","Cilantro","Cinnamon","Garlic","Ginger","Mint","Oregano","Paprika","Parsley","Red pepper","Salt","Vanilla extract","Butter","Margarine","Cottage cheese","Half & half","Milk","Sour cream","Whipped cream","Yogurt","Bleu cheese","Cheddar","Cottage cheese","Cream cheese","Feta","Goat cheese","Mozzarella","Parmesan","Provolone","Ricotta","Sandwich slices","Swiss","Bacon ","Sausage","Beef","Steak ","Chicken","Ground beef ","Turkey","Ham","Pork","Hot dogs","Lunchmeat","Turkey","Catfish","Crab","Lobster","Mussels","Oysters","Salmon","Shrimp","Tilapia","Tuna","Beer","Club soda ","Champagne","Gin","Juice","Mixers","Red wine","White wine","Rum","Sake","Soda pop","Sports drink","Whiskey","Vodka","Bagels","Croissants","Buns ","Cake","Cookies","Donuts ","Pastries","Fresh bread","Pie","Pita bread","Sliced bread","Baking powder","Baking Soda","Bread crumbs","Cake mix","Brownie mix","Cake icing","Cake Decorations","Chocolate chips/Cocoa ","Flour","Shortening","Sugar","Sugar substitute","Yeast","Candy ","Gum","Cookies","Crackers","Dried fruit","Granola bars ","Granola mix","Nuts","Seeds","Oatmeal","Popcorn","Potato Chips","Corn chips","Pretzels","Burger night","Chili night","Pizza night","Spaghetti night","Taco night","Take-out deli food","Baby food","Diapers","Formula","Lotion","Baby wash","Wipes","Cat food / Treats","Cat litter","Dog food / Treats","Flea treatment","Pet shampoo","Deodorant","Bath soap / Hand soap","Condoms / Other b.c.","Cosmetics","Cotton swabs / Balls","Facial cleanser","Facial tissue","Feminine products","Floss","Hair gel ","Hair spray","Lip balm","Moisturizing lotion","Mouthwash","Razors ","Shaving cream","Shampoo ","Conditioner","Sunblock","Toilet paper","Toothpaste","Vitamins ","Supplements","Allergy","Antibiotic","Antidiarrheal","Aspirin","Antacid","Band-aids / Medical","Cold / Flu / Sinus","Pain reliever","Prescription pick-up","Aluminum foil","Napkins","Non-stick spray","Paper towels","Plastic wrap","Sandwich / Freezer bags","Wax paper","Air freshener","Bathroom cleaner","Bleach ","Detergent","Dish / Dishwasher soap","Garbage bags","Glass cleaner","Mop head ","Vacuum bags","Sponges","Notepad ","Envelopes","Glue ","Tape","Printer paper","Pens ","Pencils","Postage stamps","Arsenic","Asbestos","Cigarettes","Radionuclides","Vinyl chloride"]
    
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

        
        print("fetched")
        self.tableView.tableFooterView = UIView()
        configureSearchController()
        
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemTypes")
//        fetchRequest.predicate = NSPredicate(format:"lists.name contains [cd] %@", "defaultList")
//        
//        do {
//            let results = try managedObjectContext.fetch(fetchRequest) as! [ItemTypes]
//            print(results[0].name ?? "default string")
//        }catch{
//            fatalError("yay")
//        }

//        do {
//            let results = try managedObjectContext.fetch(fetchRequest) as! [GroceryLists]
//            print(results.count)
//            if let flist = results.first {
//                print(flist.name ?? "default")
//                for x in flist.items?.allObjects as! [ItemTypes]{
//                    print(x.name ?? "default item")
//                    
//                }
//            }
//            
//
//        } catch {
//            fatalError("Failed to fetch employees: \(error)")
//        }
    

        

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
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredArray = list_items.filter({ (item) -> Bool in
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
        searchActive = false
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            self.tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchActive = true;
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
            print("num of row",sectionInfo.numberOfObjects)
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
            print(item.name ?? "default")
            cell.itemNameLabel?.text = item.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchActive{
            let item_name = filteredArray[indexPath.row]
            searchController.isActive = false
            do {
                let itemtype = NSEntityDescription.insertNewObject(forEntityName: "ItemTypes", into: managedObjectContext) as! ItemTypes
                itemtype.name = item_name
                itemtype.creationDate = NSDate()
                //TODO: add list relationship
                searchActive = false
                self.tableView.reloadData()
                
                print(searchActive)
                try managedObjectContext.save()
                print("saved item")
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
