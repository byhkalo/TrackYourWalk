//
//  LocalPhotoDatabaseMock.swift
//  TrackYourWalkTests
//
//  Created by Konstantyn on 7/26/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
@testable import TrackYourWalk

class LocalPhotoDatabaseMock: AnyLocalPhotoDatabase {
  // MARK: - Test Properties
  var lastMethodCall: String?
  var photosForReturn: [AnyWalkPhotoModel] = []
  var createPhotoModel: AnyWalkPhotoModel?
  var localPhotoDatabaseHandler: CoreDataServiceHandler?
  // MARK: - Protocols Methods
  func getAllPlacePhotos() -> [AnyWalkPhotoModel] {
    lmc(#function); return photosForReturn
  }
  func create(photoModel: AnyWalkPhotoModel) {
    createPhotoModel = photoModel; lmc(#function)
  }
  func getModel(withUrl url: String) -> CoreDataPhotoModel? { lmc(#function); return nil }
  func update(photoModel: AnyWalkPhotoModel) { lmc(#function) }
  func delete(photoModel: AnyWalkPhotoModel) { lmc(#function) }
  func deleteAll() { lmc(#function) }
  func photosNumberOfSections() -> Int {
    lmc(#function); return 0
  }
  func photoNumberOfRowsInSection(_ section: Int) -> Int {
    lmc(#function); return 0
  }
  func photo(at indexPath: IndexPath) -> CoreDataPhotoModel {
    lmc(#function); return CoreDataPhotoModel()
  }
  func addDatabaseHandler(_ completion: @escaping CoreDataServiceHandler) -> Int {
    localPhotoDatabaseHandler = completion
    lmc(#function)
    return 0
  }
  func removeDatabaseHandler(handlerId: Int) { lmc(#function) }
  // MARK: - Private Help Methods
  private func lmc(_ call: Any) {
    lastMethodCall = "\(call)"
  }
}
