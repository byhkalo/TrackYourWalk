//
//  MainFlowContext.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

enum MainFlowChange: AnyContextChange {
  /// Cases
  case none
  /// Init
  init() { self = .none }
}

protocol AnyMainFlowContext: AnyObservableContext {
  // It's MainFlowContext Interfase
  var walkPhotoBoothContext: AnyWalkPhotoBoothObservableFlowContext { get }
}

class MainFlowContext: ObservableContext<MainFlowChange> {
  fileprivate let locationService: AnyWalkTrackLocationService = WalkTrackLocationService()
  fileprivate let photoNetworkService: AnyPhotoPlacesNetworkService = PhotoPlacesNetworkService()
  fileprivate let photoDatabaseService: AnyLocalPhotoDatabase = LocalPhotoDatabase.shared
  fileprivate lazy var walkManager: AnyWalkManager =
    WalkManager(locationService: locationService,
                photoNetworkService: photoNetworkService,
                photoDatabaseService: photoDatabaseService)
  // Paste Storage Properties
  lazy var walkPhotoBoothContext: AnyWalkPhotoBoothObservableFlowContext =
    WalkPhotoBoothFlowContext(walkManager: self.walkManager)
}

extension MainFlowContext: AnyMainFlowContext {
  // Implement AnyMainFlowContext methods
}
