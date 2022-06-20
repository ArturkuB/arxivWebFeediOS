//
//  Category.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 22/04/2022.
//


import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var title: String = ""
    let subcategories = List<Subcategory>()
}

