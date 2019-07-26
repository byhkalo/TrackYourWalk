//
//  CoreDataPhotoModel+CoreDataProperties.swift
//  
//
//  Created by Konstantyn on 7/25/19.
//
//

import Foundation
import CoreData

extension CoreDataPhotoModel: AnyWalkPhotoModel {
  ///Class Properties
  public class var fetchRequestResult: NSFetchRequest<NSFetchRequestResult> {
    return NSFetchRequest.init(entityName: "CoreDataPhotoModel")
  }
  ///Class Function
  @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataPhotoModel> {
    return NSFetchRequest<CoreDataPhotoModel>(entityName: "CoreDataPhotoModel")
  }
  ///MARK: - Properties
  @NSManaged public var title: String
  @NSManaged public var url: String
  @NSManaged public var date: Date
}
