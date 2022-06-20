//
//  CategoryViewController.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 20/04/2022.
//
import UIKit
import RealmSwift

class PickSegueViewController: UIViewController{
    
    let realm = try! Realm()
    
    var subcategories: Results<Subcategory>?
    var destination: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAndCheckForSubscribedSubcategories()
    }
    
    func loadAndCheckForSubscribedSubcategories() {
        subcategories = realm.objects(Subcategory.self)
        subcategories = subcategories?.filter("subscribed = true").sorted(byKeyPath: "title", ascending: true)
        if subcategories?.count ?? 0 > 0 {
            destination = true
            performSegue(withIdentifier: "pickSegueToSubscribed", sender: self)
        }
        else
        {
            destination = false
            performSegue(withIdentifier: "pickSegueToCategories", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if destination {
            let destinationVC = segue.destination as! SubscribedSubsViewController
            destinationVC.subcategories = subcategories
        }
    }
}


