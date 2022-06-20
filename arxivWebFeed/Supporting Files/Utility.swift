//
//  Utility.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 06/05/2022.
//

import Foundation
import UIKit

class Utility {
    static func pressedSettings(sender: UITableViewController) {
        var textFieldTitle = UITextField()
        var textFieldAuthors = UITextField()
        var textFieldPdfLink = UITextField()
        let defaults = UserDefaults.standard
        let titleSelector = defaults.string(forKey: "titleSelector")
        let authorsSelector = defaults.string(forKey: "authorsSelector")
        let pdfLinkSelector = defaults.string(forKey: "pdfLinkSelector")
        let alert = UIAlertController(title: "Change selectors", message: "", preferredStyle: .alert)
        
        let restoreDefaultsAction = UIAlertAction(title: "Restore defaults", style: .default) { (restoreDefaultsAction) in
            
            let titleSelectorDefault = defaults.string(forKey: "titleSelectorDefault")
            let authorsSelectorDefault = defaults.string(forKey: "authorsSelectorDefault")
            let pdfLinkSelectorDefault = defaults.string(forKey: "pdfLinkSelectorDefault")
            
            defaults.set(titleSelectorDefault, forKey: "titleSelector")
            defaults.set(authorsSelectorDefault, forKey: "authorsSelector")
            defaults.set(pdfLinkSelectorDefault, forKey: "pdfLinkSelector")
            
            textFieldTitle.placeholder = titleSelectorDefault! + " <- Title"
            textFieldAuthors.placeholder = authorsSelectorDefault! + " <- Authors"
            textFieldPdfLink.placeholder = pdfLinkSelectorDefault! + " <- Link"
        }
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            if textFieldTitle.text != "" {
                defaults.set(textFieldTitle.text, forKey: "titleSelector")
            }
            if textFieldAuthors.text != "" {
                defaults.set(textFieldAuthors.text, forKey: "authorsSelector")
            }
            if textFieldPdfLink.text != "" {
                defaults.set(textFieldPdfLink.text, forKey: "pdfLinkSelector")
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
        }))
        
        alert.addAction(restoreDefaultsAction)
        alert.addAction(action)
        alert.addTextField { (titleField) in
            textFieldTitle = titleField
            textFieldTitle.placeholder = titleSelector! + " <- Title"
        }
        alert.addTextField { (authorsField) in
            textFieldAuthors = authorsField
            textFieldAuthors.placeholder = authorsSelector! + " <- Authors"
        }
        alert.addTextField { (pdfLinkField) in
            textFieldPdfLink = pdfLinkField
            textFieldPdfLink.placeholder = pdfLinkSelector! + " <- Link"
        }
        sender.present(alert, animated: true, completion: nil)
    }
    
    
}
