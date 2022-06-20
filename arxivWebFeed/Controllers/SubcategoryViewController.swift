//
//  SubcategoryViewController.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 21/04/2022.
//

import Foundation
import UIKit
import RealmSwift
import DropDown

class SubcategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subscribedButton: UIButton!
    @IBOutlet weak var subcategoryLabel: UILabel!
}

class SubcategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "Settings",
            "Subscribed",
        ]
        return menu
    }()
    
    var subcategories: Results<Subcategory>?
    var selectedCategory: Category? {
        didSet {
            loadSubcategories()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menu.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                Utility.pressedSettings(sender: self)
            }
            else {
                performSegue(withIdentifier: "subcategoryToSubscribed", sender: self)
            }
        }
    }
    
    func loadSubcategories() {
        subcategories = selectedCategory?.subcategories.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    @IBAction func pressedDropDownMenu(_ sender: Any) {
        menu.anchorView = navigationItem.rightBarButtonItem
        menu.show()
    }
    
    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subcategories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell", for: indexPath) as! SubcategoryTableViewCell
        
        if let subcategory = subcategories?[indexPath.row] {
            cell.subcategoryLabel.text = subcategory.title
            
            if subcategory.subscribed == false {
                cell.subscribedButton.isSelected = false
                cell.subscribedButton.setBackgroundImage(UIImage(named:"star"), for: UIControl.State.normal)
            }
            else
            {
                cell.subscribedButton.isSelected = true
                cell.subscribedButton.setBackgroundImage(UIImage(named:"starclick"), for: UIControl.State.selected)
                
            }
        }
        
        cell.subscribedButton.tag = indexPath.row
        cell.subscribedButton.addTarget(self, action: #selector(whichButtonPressed(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func whichButtonPressed(sender: UIButton) {
        print(sender.tag)
        
        if sender.isSelected {
            sender.isSelected = false
            sender.setBackgroundImage(UIImage(named:"star"), for: UIControl.State.normal)
            if let subcategory = subcategories?[sender.tag] {
                do {
                    try realm.write{
                        subcategory.subscribed = false
                        self.realm.delete(subcategory.publications)
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
            }
        }
        else
        {
            sender.isSelected = true
            sender.setBackgroundImage(UIImage(named:"starclick"), for: UIControl.State.selected)
            if let subcategory = subcategories?[sender.tag] {
                do {
                    try realm.write{
                        subcategory.subscribed = true
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "subcategoryToPublication", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "subcategoryToPublication"
        {
            let destinationVC = segue.destination as! PublicationViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedSubcategory = subcategories?[indexPath.row]
                destinationVC.activityIndicator()
                destinationVC.indicator.startAnimating()
                destinationVC.indicator.backgroundColor = .white
            }
        }
        if segue.identifier == "subcategoryToSubscribed" {
            let destinationVC = segue.destination as! SubscribedSubsViewController
            let subcategoriesPrepare = realm.objects(Subcategory.self)
            destinationVC.subcategories = subcategoriesPrepare.filter("subscribed = true").sorted(byKeyPath: "title", ascending: true)
        }
    }
}
