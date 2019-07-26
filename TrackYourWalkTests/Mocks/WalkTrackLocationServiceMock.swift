//
//  WalkTrackLocationServiceMock.swift
//  TrackYourWalkTests
//
//  Created by Konstantyn on 7/26/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import CoreLocation
@testable import TrackYourWalk

class WalkTrackLocationServiceMock: AnyWalkTrackLocationService {
  // MARK: - Protocol Properties
  var isStarted: Bool = false
  // MARK: - Test Properties
  var lastMethodCall: String?
  var lastLocation: CLLocation?
  var authorizationStatus: CLAuthorizationStatus?
  var locationServiceHandler: CompletionChangeHandler<LocationUpdate>?
  // MARK: - Protocol Functions
  func requestLocationAccess(completion: @escaping CompletionChangeStateHandler<Bool>) {
    lmc(#function)
  }
  func startTracking() { lmc(#function) }
  func finishTracking() { lmc(#function) }
  ///Handlers
  func addHandler(_ completion: @escaping CompletionChangeHandler<LocationUpdate>) -> Int {
    locationServiceHandler = completion
    lmc(#function)
    return 1
  }
  func removeHandler(handlerId: Int) { lmc(#function) }
  // MARK: - Private Help Methods
  private func lmc(_ call: Any) {
    lastMethodCall = "\(call)"
  }
}
