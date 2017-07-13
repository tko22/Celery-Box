//
//  GroceryListViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/10/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit
import CoreData

class GroceryListViewController: UIViewController {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var list_items = ["Product","Asparagus","Broccoli","Carrots","Cauliflower","Celery","Corn","Cucumbers","Lettuce ","Mushrooms","Onions","Peppers","Potatoes","Spinach","Squash","Zucchini","Tomatoes","Apples","Avocados","Bananas","Berries","Cherries","Grapefruit","Grapes","Kiwis","Lemons ","Limes","Melon","Nectarines","Oranges","Peaches","Pears","Plums","Bagels","Chip dip","Eggs","Fake eggs","English muffins","Fruit juice","Hummus","Ready-bake breads","Tofu","Tortillas","Breakfasts","Burritos","Fish sticks","Fries","Tater tots","Ice cream ","Sorbet","Juice concentrate","Pizza","Pizza Rolls","Popsicles","TV dinners","Vegetables","BBQ sauce","Gravy","Honey","Hot sauce","Jam ","Jelly ","Preserves","Ketchup","Mustard","Mayonnaise","Pasta sauce","Relish","Salad dressing","Salsa","Soy sauce","Steak sauce","Syrup","Worcestershire sauce","Bouillon cubes","Cereal","Coffee","Coffee filters","Instant potatoes","Lemon juice","Lime juice","Mac & cheese","Olive oil","Packaged meals","Pancake mix","Waffle mix","Pasta","Peanut butter","Pickles","Rice","Tea","Vegetable oil","Vinegar","Applesauce","Baked beans","Broth","Fruit","Olives","Tinned meats","Tuna","Chicken","Soup","Chili","Tomatoes","Veggies","Basil","Black pepper","Cilantro","Cinnamon","Garlic","Ginger","Mint","Oregano","Paprika","Parsley","Red pepper","Salt","Vanilla extract","Butter","Margarine","Cottage cheese","Half & half","Milk","Sour cream","Whipped cream","Yogurt","Bleu cheese","Cheddar","Cottage cheese","Cream cheese","Feta","Goat cheese","Mozzarella","Parmesan","Provolone","Ricotta","Sandwich slices","Swiss","Bacon ","Sausage","Beef","Steak ","Chicken","Ground beef ","Turkey","Ham","Pork","Hot dogs","Lunchmeat","Turkey","Catfish","Crab","Lobster","Mussels","Oysters","Salmon","Shrimp","Tilapia","Tuna","Beer","Club soda ","Champagne","Gin","Juice","Mixers","Red wine","White wine","Rum","Sake","Soda pop","Sports drink","Whiskey","Vodka","Bagels","Croissants","Buns ","Cake","Cookies","Donuts ","Pastries","Fresh bread","Pie","Pita bread","Sliced bread","Baking powder","Baking Soda","Bread crumbs","Cake mix","Brownie mix","Cake icing","Cake Decorations","Chocolate chips/Cocoa ","Flour","Shortening","Sugar","Sugar substitute","Yeast","Candy ","Gum","Cookies","Crackers","Dried fruit","Granola bars ","Granola mix","Nuts","Seeds","Oatmeal","Popcorn","Potato Chips","Corn chips","Pretzels","Burger night","Chili night","Pizza night","Spaghetti night","Taco night","Take-out deli food","Baby food","Diapers","Formula","Lotion","Baby wash","Wipes","Cat food / Treats","Cat litter","Dog food / Treats","Flea treatment","Pet shampoo","Deodorant","Bath soap / Hand soap","Condoms / Other b.c.","Cosmetics","Cotton swabs / Balls","Facial cleanser","Facial tissue","Feminine products","Floss","Hair gel ","Hair spray","Lip balm","Moisturizing lotion","Mouthwash","Razors ","Shaving cream","Shampoo ","Conditioner","Sunblock","Toilet paper","Toothpaste","Vitamins ","Supplements","Allergy","Antibiotic","Antidiarrheal","Aspirin","Antacid","Band-aids / Medical","Cold / Flu / Sinus","Pain reliever","Prescription pick-up","Aluminum foil","Napkins","Non-stick spray","Paper towels","Plastic wrap","Sandwich / Freezer bags","Wax paper","Air freshener","Bathroom cleaner","Bleach ","Detergent","Dish / Dishwasher soap","Garbage bags","Glass cleaner","Mop head ","Vacuum bags","Sponges","Notepad ","Envelopes","Glue ","Tape","Printer paper","Pens ","Pencils","Postage stamps","Arsenic","Asbestos","Cigarettes","Radionuclides","Vinyl chloride"]


    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<ItemTypes> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<ItemTypes> = ItemTypes.fetchRequest()
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        //fetchRequest.predicate = NSPredicate(format: "lists.name contains [cd] %@", "defaultList")
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "listCache")
        
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
        
        setupView()
        
        print(fetchedResultsController.fetchedObjects)
        print("fetched")
        
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func checkEmpty() {
        var hasItems = false
        
        if let items = fetchedResultsController.fetchedObjects {
            hasItems = items.count > 0
        }
        tableView.isHidden = !hasItems
        messageLabel.isHidden = hasItems
    }
    
    private func setupView() {
        setupMessageLabel()
        
        checkEmpty()
    }
    
    private func setupMessageLabel() {
        messageLabel.text = ""
    }
    private func fetchList() -> NSFetchRequest<ItemTypes>{
        let fetchRequest = NSFetchRequest<ItemTypes>(entityName: "ItemTypes")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "defaultList")
        print(fetchRequest)
        return fetchRequest
    }
}


extension GroceryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroceryListTableViewCell.reuseIdentifier, for: indexPath) as? GroceryListTableViewCell else {
                fatalError("Unexpected Index Path")
        }
            let item = fetchedResultsController.object(at: indexPath)
            print(item.name ?? "default")
            cell.itemNameLabel?.text = item.name
            return cell
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
