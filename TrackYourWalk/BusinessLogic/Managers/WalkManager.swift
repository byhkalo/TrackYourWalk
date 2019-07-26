//
//  WalkManager.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

enum WalkUpdate: Equatable {
  case started
  case stoped
  case photoUpdated
  case authorizationStatusDenied
  case catchError(Error)
  // MARK: - Equatable implementation
  static func == (lhs: WalkUpdate, rhs: WalkUpdate) -> Bool {
    switch (lhs, rhs) {
    case let (.catchError(left), .catchError(right)):
      return left.localizedDescription == right.localizedDescription
    case (.started, .started): return true
    case (.stoped, .stoped): return true
    case (.photoUpdated, .photoUpdated): return true
    case (.authorizationStatusDenied, .authorizationStatusDenied): return true
    default: return false
    }
  }
}

protocol AnyWalkManager {
  /// Properties
  var isStarted: Bool { get }
  /// Manage Methods
  func startWalk()
  func finishWalk()
  func fetchAllPhotoBooth() -> [AnyWalkPhotoModel]
  /// Handler
  func addHandler(_ completion: @escaping CompletionChangeHandler<WalkUpdate>) -> Int
  func removeHandler(handlerId: Int)
}
// MARK: - WalkManager
class WalkManager {
  // MARK: - Properties
  // MARK: - Private Properties
  ///State Properties
  internal var isStarted: Bool {
    return locationService.isStarted
  }
  ///Services
  fileprivate var locationService: AnyWalkTrackLocationService
  fileprivate var photoNetworkService: AnyPhotoPlacesNetworkService
  fileprivate var photoDatabaseService: AnyLocalPhotoDatabase
  ///Observing Handlers
  fileprivate var observingHandlers: [Int: CompletionChangeHandler<WalkUpdate>] = [:]
  ///Handlers Identifiers
  fileprivate var locationServiceHandlerId: Int = 0
  fileprivate var photoDatabseHandlerId: Int = 0
  // MARK: - Init
  init(locationService: AnyWalkTrackLocationService,
       photoNetworkService: AnyPhotoPlacesNetworkService,
       photoDatabaseService: AnyLocalPhotoDatabase) {
    self.locationService = locationService
    self.photoNetworkService = photoNetworkService
    self.photoDatabaseService = photoDatabaseService
    subscribe()
  }
  deinit {
    unsubscribe()
  }
}
// MARK: - Extend by AnyWalkManager
extension WalkManager: AnyWalkManager {
  /// Manage Methods
  func startWalk() {
    guard locationService.isStarted == false else { return }
    locationService.startTracking()
  }
  func finishWalk() {
    guard locationService.isStarted else { return }
    locationService.finishTracking()
  }
  func fetchAllPhotoBooth() -> [AnyWalkPhotoModel] {
    return photoDatabaseService.getAllPlacePhotos()
  }
}

// MARK: - Observing Handlers
extension WalkManager {
  func addHandler(_ completion: @escaping CompletionChangeHandler<WalkUpdate>) -> Int {
    var maxId = observingHandlers.keys.max() ?? 0
    maxId += 1
    observingHandlers[maxId] = completion
    return maxId
  }
  func removeHandler(handlerId: Int) {
    observingHandlers.removeValue(forKey: handlerId)
  }
  private func notifyObservers(about change: WalkUpdate) {
    DispatchQueue.global().async {
      self.observingHandlers.forEach { (handler) in
        handler.value(change)
      }
    }
  }
}

// MARK: - Private Main Functions
fileprivate extension WalkManager {
  func getPhoto() {
    guard let lastLocation = locationService.lastLocation?.coordinate else { return }
    photoNetworkService
      .getPhotoModel(byLat: lastLocation.latitude, lon: lastLocation.longitude) { (state) in
        switch state {
        case .error(let error):
          self.notifyObservers(about: .catchError(error))
        case .success(let photoModel):
          if let photoModel = photoModel {
            self.save(photo: photoModel)
          } else {
            ///Just No photos for current Location
          }
        }
    }
  }
  func save(photo: AnyWalkPhotoModel) {
    photoDatabaseService.create(photoModel: photo)
  }
}

// MARK: - Private Subcsribe/Unsubscribe Methods
fileprivate extension WalkManager {
  func subscribe() {
    locationServiceHandlerId = locationService.addHandler({ [weak self] locationUpdate in
      guard let `self` = self else { return }
      switch locationUpdate {
      case .started: self.notifyObservers(about: .started)
      case .stoped: self.notifyObservers(about: .stoped)
      case .regionUpdate: self.getPhoto()
      case .authorizationStatusDenied:
        self.notifyObservers(about: .authorizationStatusDenied)
      case .genericError(let error):
        self.notifyObservers(about: .catchError(error))
      }
    })
    photoDatabseHandlerId = photoDatabaseService.addDatabaseHandler({ [weak self] databaseChange in
      guard let `self` = self else { return }
      switch databaseChange {
      case .deletedAll: self.notifyObservers(about: .photoUpdated)
      case .photoSaved: self.notifyObservers(about: .photoUpdated)
      case .photosDidChange: self.notifyObservers(about: .photoUpdated)
      }
    })
  }
  func unsubscribe() {
    locationService.removeHandler(handlerId: locationServiceHandlerId)
    photoDatabaseService.removeDatabaseHandler(handlerId: photoDatabseHandlerId)
  }
}
