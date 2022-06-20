//
//  AppDelegate.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 19/04/2022.
//

import UIKit
import RealmSwift
import SwiftSoup
import Alamofire
import DropDown

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        let connected = self.sharedInstance.isReachable
        return connected
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let realm = try! Realm()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .black
        let proxy = UINavigationBar.appearance()
        proxy.tintColor = .white
        proxy.standardAppearance = appearance
        proxy.scrollEdgeAppearance = appearance
        DropDown.startListeningToKeyboard()
        let hasLaunchedKey = "FirstLaunch"
        let titleSelectorDefault = ".list-title"
        let authorsSelectorDefault = ".list-authors"
        let pdfLinkSelectorDefault = ".list-identifier a:nth-child(2)"
        
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        
        if Connectivity.isConnectedToInternet {
            if !hasLaunched {
                parseSite()
                defaults.set(titleSelectorDefault, forKey: "titleSelectorDefault")
                defaults.set(authorsSelectorDefault, forKey: "authorsSelectorDefault")
                defaults.set(pdfLinkSelectorDefault, forKey: "pdfLinkSelectorDefault")
                defaults.set(titleSelectorDefault, forKey: "titleSelector")
                defaults.set(authorsSelectorDefault, forKey: "authorsSelector")
                defaults.set(pdfLinkSelectorDefault, forKey: "pdfLinkSelector")
                defaults.set(true, forKey: hasLaunchedKey)
            }
            print(Realm.Configuration.defaultConfiguration.fileURL)
        }
        return true
    }
    
    // MARK: Parsing methods
    
    func parseSite(){
        do {
            let url = URL(string:"https://arxiv.org/")!
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            let elements: SwiftSoup.Elements = try document.select("ul:nth-child(20), .columns, #details-econ, #details-eess, #details-stat, #details-q-fin, #details-q-bio, #details-cs, #details-math, a:nth-child(3), a:nth-child(4), a:nth-child(5)")
            try elements.forEach{ e in
                try e.remove()
            }
            self.parseSection(selektor: "ul:nth-child(2) a", document: document, categoryTitle: "Physics")
            self.parseSection(selektor: "ul:nth-child(4) a", document: document, categoryTitle: "Mathematics")
            self.parseSection(selektor: "ul:nth-child(6) a", document: document, categoryTitle: "Computer Science")
            self.parseSection(selektor: "ul:nth-child(8) a", document: document, categoryTitle: "Quantitative Biology")
            self.parseSection(selektor: "ul:nth-child(10) a", document: document, categoryTitle: "Quantitative Finance")
            self.parseSection(selektor: "ul:nth-child(12) a", document: document, categoryTitle: "Statistics")
            self.parseSection(selektor: "ul:nth-child(14) a", document: document, categoryTitle: "Electrical Engineering and Systems Science")
            self.parseSection(selektor: "ul:nth-child(16) a", document: document, categoryTitle: "Economics")
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    
    func parseSection(selektor: String, document: SwiftSoup.Document, categoryTitle: String){
        do {
            let subcategories: Elements = try document.select(selektor)
            let category = Category()
            category.title = categoryTitle
            try subcategories.forEach{ e in
                if(try e.attr("href").contains("archive"))
                {
                    let subcategory = Subcategory()
                    subcategory.title = try e.text()
                    subcategory.link = try "https://arxiv.org" + e.attr("href").replacingOccurrences(of: "archive", with: "list") +   "/recent"
                    category.subcategories.append(subcategory)
                }
                else
                {
                    if(try e.attr("href").contains("corr"))
                    {
                        let subcategory = Subcategory()
                        subcategory.title = try e.text()
                        subcategory.link = "https://arxiv.org/list/cs/recent"
                        category.subcategories.append(subcategory)
                    }
                    else
                    {
                        let subcategory = Subcategory()
                        subcategory.title = try e.text()
                        subcategory.link = try "https://arxiv.org" +  e.attr("href")
                        category.subcategories.append(subcategory)
                    }
                }
            }
            save(category: category)
        }
        catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    
    // MARK: Data manipulation methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

