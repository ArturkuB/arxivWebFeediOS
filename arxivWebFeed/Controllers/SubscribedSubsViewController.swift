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

class SubscribedSubTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subscribedLabel: UILabel!
    @IBOutlet weak var subscribedButton: UIButton!
}
    
class SubscribedSubsViewController: UITableViewController {
    
    let realm = try! Realm()
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "Settings",
            "Main Menu",
        ]
        return menu
    }()
    
    var subcategories: Results<Subcategory>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true;
        menu.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                Utility.pressedSettings(sender: self)
            }
            else {
                performSegue(withIdentifier: "subscribedToCategory", sender: self)
            }
        }
    }
    
    func reloadTable(){
        subcategories = realm.objects(Subcategory.self)
        subcategories = subcategories?.filter("subscribed = true").sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        if subcategories?.count == 0 {
            performSegue(withIdentifier: "subscribedToCategory", sender: self)
        }
    }
    
    @IBAction func pressedDropDownMenu(_ sender: Any) {
        menu.anchorView = navigationItem.rightBarButtonItem
        menu.show()
    }
    
    //MARK: - Tableview Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(subcategories?.count == 0){
            return 1
        }
        return subcategories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "subscribedCell", for: indexPath) as! SubscribedSubTableViewCell
       
        if(subcategories?.count == 0){
            cell.subscribedButton.isHidden = true
            cell.subscribedLabel.text = "No subscribed subcategories"
            cell.isUserInteractionEnabled = false
        }
        else
        {
            if let subcategory = subcategories?[indexPath.row] {
                cell.subscribedLabel.text = subcategory.title
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
                        realm.delete(subcategory.publications)
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
            print("on")
        }
        reloadTable()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: "subscribedToPublication", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subscribedToPublication" {
                let destinationVC = segue.destination as! PublicationViewController
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.selectedSubcategory = subcategories?[indexPath.row]
                    destinationVC.activityIndicator()
                    destinationVC.indicator.startAnimating()
                    destinationVC.indicator.backgroundColor = .white
                }
        }
    }
}
