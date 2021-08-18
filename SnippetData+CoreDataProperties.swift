//
//  SnippetData+CoreDataProperties.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/17.
//
//

import Foundation
import CoreData


extension SnippetData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SnippetData> {
        return NSFetchRequest<SnippetData>(entityName: "SnippetData")
    }

    @NSManaged public var snippetContent: String?
    @NSManaged public var snippetTrigger: String?

}

extension SnippetData : Identifiable {

}
