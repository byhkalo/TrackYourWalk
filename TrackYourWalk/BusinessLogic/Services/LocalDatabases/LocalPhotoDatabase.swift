//
//  LocalPhotoDatabase.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CoreDataServiceChange
enum CoreDataServiceChange {
  case photosDidChange
  case photoSaved
  case deletedAll
}

// MARK: - Typealias
typealias CoreDataServiceHandler = CompletionChangeHandler<CoreDataServiceChange>

// MARK: - LocalPhotoDatabase Interface
protocol AnyLocalPhotoDatabase {
  ///Fetch DataSource Methods
  func getAllPlacePhotos() -> [AnyWalkPhotoModel]
  ///Manage DatabaseMethods
  func create(photoModel: AnyWalkPhotoModel)
  func getModel(withUrl url: String) -> CoreDataPhotoModel?
  func update(photoModel: AnyWalkPhotoModel)
  func delete(photoModel: AnyWalkPhotoModel)
  func deleteAll()
  func photosNumberOfSections() -> Int
  func photoNumberOfRowsInSection(_ section: Int) -> Int
  func photo(at indexPath: IndexPath) -> CoreDataPhotoModel
  ///Handlers subscribe
  func addDatabaseHandler(_ completion: @escaping CoreDataServiceHandler) -> Int
  func removeDatabaseHandler(handlerId: Int)
}

// MARK: - LocalPhotoDatabase
class LocalPhotoDatabase: NSObject {
  // MARK: - Static Properties
  static let shared: LocalPhotoDatabase = LocalPhotoDatabase()
  // MARK: - Properties
  var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "TrackYourWalk")
    container.loadPersistentStores(completionHandler: { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  var managedObjectContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  lazy var photosFetchedResultsController: NSFetchedResultsController<CoreDataPhotoModel> = {
    return createController(key: "date", cacheName: "Photos")
  } ()
  // MARK: - Private Properties
  fileprivate var observingCoreDataHandlers: [Int: CompletionChangeHandler<CoreDataServiceChange>] = [:]
  // MARK: - Init
  private override init() {
    super.init()
  }
  deinit {
    observingCoreDataHandlers.removeAll()
  }
  // MARK: - Private controller methods
  private func createController<T: NSManagedObject>(key: String, cacheName: String) -> NSFetchedResultsController<T> {
    // Fetch request
    // swiftlint:disable:next force_cast
    let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
    fetchRequest.fetchBatchSize = 20
    // Sort descriptor
    let sortDescriptor = NSSortDescriptor(key: key, ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    // Result controller
    let aFetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext,
      sectionNameKeyPath: nil, cacheName: cacheName)
    aFetchedResultsController.delegate = self
    // Perform fetch
    // swiftlint:disable:next force_try
    try! aFetchedResultsController.performFetch()
    return aFetchedResultsController
  }
  private func handle(error: Error) {
    let nserror = error as NSError
    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
  }
}
// MARK: - Extend by AnyLocalPhotoDatabase
extension LocalPhotoDatabase: AnyLocalPhotoDatabase {
  ///Fetch DataSource Methods
  func getAllPlacePhotos() -> [AnyWalkPhotoModel] {
    return selectAllPhotos()
  }
  ///Manage DatabaseMethods
  func create(photoModel: AnyWalkPhotoModel) {
    guard getModel(withUrl: photoModel.url) == nil else { return }
    let privateContext = managedObjectContext
    let newPhoto = CoreDataPhotoModel(context: privateContext)
    newPhoto.title = photoModel.title
    newPhoto.url = photoModel.url
    newPhoto.date = photoModel.date
    do {
      try privateContext.save()
      notifyCoreDataObservers(change: .photoSaved)
    } catch {
      handle(error: error)
    }
  }
  func getModel(withUrl url: String) -> CoreDataPhotoModel? {
    //We need to create a context from this container
    let privateContext = managedObjectContext
    let fetchRequest = CoreDataPhotoModel.fetchRequestResult
    fetchRequest.fetchLimit = 1
    fetchRequest.predicate = NSPredicate(format: "url = %@", url)
    do {
      let tempFetchModel = try privateContext.fetch(fetchRequest)
      return tempFetchModel.first as? CoreDataPhotoModel
    } catch {
      return nil
    }
  }
  func update(photoModel: AnyWalkPhotoModel) {
    //We need to create a context from this container
    let privateContext = managedObjectContext
    let fetchRequest = CoreDataPhotoModel.fetchRequestResult
    fetchRequest.fetchLimit = 1
    fetchRequest.predicate = NSPredicate(format: "url = %@", photoModel.url)
    do {
      let tempFetchModel = try privateContext.fetch(fetchRequest)
      if let objectUpdate = tempFetchModel.first as? CoreDataPhotoModel {
        objectUpdate.title = photoModel.title
        objectUpdate.url = photoModel.url
        do {
          try privateContext.save()
        } catch {
          handle(error: error)
        }
      }
    } catch {
      handle(error: error)
    }
  }
  func delete(photoModel: AnyWalkPhotoModel) {
    let fetchRequest = CoreDataPhotoModel.fetchRequestResult
    fetchRequest.fetchLimit = 1
    fetchRequest.predicate = NSPredicate(format: "url = %@", photoModel.url)
    do {
      let fetchResult = try managedObjectContext.fetch(fetchRequest)
      if let objectToDelete = fetchResult.first as? NSManagedObject {
        managedObjectContext.delete(objectToDelete)
        try managedObjectContext.save()
      }
    } catch {
      handle(error: error)
    }
  }
  func deleteAll() {
    let fetchRequest = CoreDataPhotoModel.fetchRequestResult
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      try managedObjectContext.execute(deleteRequest)
      try managedObjectContext.save()
    } catch let error as NSError {
      handle(error: error)
    }
  }
}

// MARK: - Observing Handlers
extension LocalPhotoDatabase {
  func addDatabaseHandler(_ completion: @escaping CoreDataServiceHandler) -> Int {
    var maxId = observingCoreDataHandlers.keys.max() ?? 0
    maxId += 1
    observingCoreDataHandlers[maxId] = completion
    return maxId
  }
  func removeDatabaseHandler(handlerId: Int) {
    observingCoreDataHandlers.removeValue(forKey: handlerId)
  }
  private func notifyCoreDataObservers(change: CoreDataServiceChange) {
    observingCoreDataHandlers.forEach { (handler) in
      handler.value(change)
    }
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension LocalPhotoDatabase: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    if controller == photosFetchedResultsController {
      notifyCoreDataObservers(change: .photosDidChange)
    }
  }
}
// MARK: - AnyCoreDataService
extension LocalPhotoDatabase {
  // DataSource Methods
  func photosNumberOfSections() -> Int {
    return photosFetchedResultsController.sections?.count ?? 0
  }
  func photoNumberOfRowsInSection(_ section: Int) -> Int {
    let sectionInfo = photosFetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }
  func photo(at indexPath: IndexPath) -> CoreDataPhotoModel {
    return photosFetchedResultsController.object(at: indexPath)
  }
  // MARK: - AnyDatabaseService -
  // MARK: - Generate Methods
  private func selectAllPhotos() -> [CoreDataPhotoModel] {
    return photosFetchedResultsController.fetchedObjects ?? []
  }
}
