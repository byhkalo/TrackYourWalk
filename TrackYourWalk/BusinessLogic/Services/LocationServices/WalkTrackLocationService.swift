//
//  WalkTrackLocationService.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationUpdate {
  case started
  case stoped
  case regionUpdate
  ///Errors
  case authorizationStatusDenied
  case genericError(Error)
}

protocol AnyWalkTrackLocationService {
  /// Properties
  var isStarted: Bool { get }
  var lastLocation: CLLocation? { get }
  var authorizationStatus: CLAuthorizationStatus? { get }
  /// Check System Methods
  func requestLocationAccess(completion: @escaping CompletionChangeStateHandler<Bool>)
  /// Manage Methods
  func startTracking()
  func finishTracking()
  /// Handler
  func addHandler(_ completion: @escaping CompletionChangeHandler<LocationUpdate>) -> Int
  func removeHandler(handlerId: Int)
}

class WalkTrackLocationService: NSObject {
  // MARK: - Properties
  fileprivate(set) var isStarted: Bool = false
  fileprivate(set) var lastLocation: CLLocation? {
    didSet {
      if oldValue == nil, self.lastLocation != nil, isStarted {
        reregisterRegion()
      }
    }
  }
  fileprivate(set) var authorizationStatus: CLAuthorizationStatus?
  // MARK: - Private Properties
  ///System Mangers
  fileprivate var locationManager = CLLocationManager()
  fileprivate var walkRegion: CLCircularRegion?
  ///Update Handlers
  fileprivate var observingHandlers: [Int: CompletionChangeHandler<LocationUpdate>] = [:]
  fileprivate var requestAuthorizationHandler: CompletionChangeHandler<CLAuthorizationStatus>?
  // MARK: - Init
  override init() {
    super.init()
    configureBeaconManager()
  }
}

extension WalkTrackLocationService: AnyWalkTrackLocationService {
  func requestLocationAccess(completion: @escaping CompletionChangeStateHandler<Bool>) {
    requestAuthorizationHandler = { [weak self] status in
      guard let `self` = self else { return }
      switch status {
      case .authorizedAlways, .authorizedWhenInUse:
        completion(.success(true))
      case .denied:
        completion(.success(false))
      case .notDetermined:
        self.requestLocationAccess(completion: completion)
      case .restricted:
        let error = NSError(domain: "This application is not authorized to use location services.",
                            code: 1, userInfo: nil)
        completion(.error(error))
      @unknown default:
        let error = NSError(domain: "Unknown Authorisation State",
                            code: 1, userInfo: nil)
        completion(.error(error))
      }
    }
    locationManager.requestAlwaysAuthorization()
  }
  /// Manage Methods
  func startTracking() {
    guard let authorizationStatus = authorizationStatus else { return }
    switch authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      isStarted = true
      reregisterRegion()
      notifyObservers(about: .started)
    case .notDetermined:
      requestLocationAccess { [weak self] state in
        guard let `self` = self else { return }
        switch state {
        case .success:
          self.startTracking()
        case .error(let error):
          self.notifyObservers(about: .genericError(error))
        }
      }
    case .denied, .restricted:
      self.notifyObservers(about: .authorizationStatusDenied)
    @unknown default:
      let error = NSError(domain: "Authorization Status unknown default status",
                          code: 0, userInfo: nil)
      self.notifyObservers(about: .genericError(error))
    }
  }
  func finishTracking() {
    guard isStarted else { return }
    isStarted = false
    if let tempWalkRegion = walkRegion {
      locationManager.stopMonitoring(for: tempWalkRegion)
    }
    notifyObservers(about: LocationUpdate.stoped)
  }
}
// MARK: - Configure Methods
fileprivate extension WalkTrackLocationService {
  func configureBeaconManager() {
    locationManager.delegate = self
    locationManager.startUpdatingLocation()
  }
  func reregisterRegion() {
    if let tempWalkRegion = walkRegion {
      locationManager.stopMonitoring(for: tempWalkRegion)
    }
    if let location = lastLocation {
      let newWalkRegion = CLCircularRegion(center: location.coordinate,
                                           radius: Constants.activateDistance,
                                           identifier: "WalkRegionIdentifier")
      locationManager.startMonitoring(for: newWalkRegion)
      notifyObservers(about: .regionUpdate)
    }
  }
}
// MARK: - Observing Handlers
extension WalkTrackLocationService {
  func addHandler(_ completion: @escaping CompletionChangeHandler<LocationUpdate>) -> Int {
    var maxId = observingHandlers.keys.max() ?? 0
    maxId += 1
    observingHandlers[maxId] = completion
    return maxId
  }
  func removeHandler(handlerId: Int) {
    observingHandlers.removeValue(forKey: handlerId)
  }
  private func notifyObservers(about change: LocationUpdate) {
    DispatchQueue.global().async {
      self.observingHandlers.forEach { (handler) in
        handler.value(change)
      }
    }
  }
}
// MARK: - Observing Handlers
extension WalkTrackLocationService: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    authorizationStatus = status
    requestAuthorizationHandler?(status)
  }
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    lastLocation = locations.first
  }
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    guard isStarted else { return }
    notifyObservers(about: .regionUpdate)
    reregisterRegion()
  }
}
