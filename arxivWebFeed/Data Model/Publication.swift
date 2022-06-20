//
//  Publication.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 22/04/2022.
//


import Foundation
import RealmSwift

class Publication: Object {
    @objc dynamic var publicationTag: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var link: String = ""
    @objc dynamic var dateCreated: Date?
    var parentSubcategory = LinkingObjects(fromType: Subcategory.self, property: "publications")
    
    override static func primaryKey() -> String? {
        return "publicationTag"
    }
}

