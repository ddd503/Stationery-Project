//
//  SaveData+CoreDataProperties.swift
//  Model
//
//  Created by kawaharadai on 2018/10/17.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//
//

import Foundation
import CoreData


extension SaveData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SaveData> {
        return NSFetchRequest<SaveData>(entityName: "SaveData")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var content: String?

}
