//
//  CategoryViewController.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 20/04/2022.
//

import UIKit
import RealmSwift
import DropDown

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
}

class CategoryViewController: UITableViewController{
    
    let realm = try! Realm()
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "Settings",
            "Subscribed",
        ]
        return menu
    }()
    
    var categories: Results<Category>?
    
    var images = [UIImage(named: "physics"), UIImage(named: "mathematics"), UIImage(named: "computerscience"), UIImage(named: "quantitativebiology"), UIImage(named: "quantitativefinance"), UIImage(named: "statistics"), UIImage(named: "eeass"), UIImage(named: "economics")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true;
        loadCategories()
        menu.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                Utility.pressedSettings(sender: self)
            }
            else {
                performSegue(withIdentifier: "categoryToSubscribed", sender: self)
            }
        }
        tableView.rowHeight = 100
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    @IBAction func pressedDropDownButton(_ sender: Any) {
        menu.anchorView = navigationItem.rightBarButtonItem
        menu.show()
    }
    
    //MARK: TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        if let category = categories?[indexPath.row] {
            cell.categoryLabel.text = category.title
        }
        else
        {
            cell.categoryLabel.text = "No categories, error"
        }
        cell.categoryImage.image = images[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToSubcategory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryToSubcategory" {
            let destinationVC = segue.destination as! SubcategoryViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
        if segue.identifier == "categoryToSubscribed" {
            let destinationVC = segue.destination as! SubscribedSubsViewController
            let subcategoriesPrepare = realm.objects(Subcategory.self)
            destinationVC.subcategories = subcategoriesPrepare.filter("subscribed = true").sorted(byKeyPath: "title", ascending: true)
        }
    }
}


