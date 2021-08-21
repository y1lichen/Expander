//
//  SnippetData+CoreDataProperties.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/19.
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
    @NSManaged public var date: Date?

}

extension SnippetData : Identifiable {
}
