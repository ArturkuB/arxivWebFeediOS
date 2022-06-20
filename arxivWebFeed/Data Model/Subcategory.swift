//
//  Subcategory.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 22/04/2022.
//

import Foundation
import RealmSwift

class Subcategory: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var link: String = ""
    @objc dynamic var subscribed: Bool = false
    let publications = List<Publication>()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "subcategories")
}

