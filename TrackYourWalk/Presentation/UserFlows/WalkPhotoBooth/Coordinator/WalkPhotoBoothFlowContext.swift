//
//  WalkPhotoBoothFlowContext.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

enum WalkPhotoBoothFlowChange: AnyContextChange {
  /// Cases
  case none
  /// Init
  init() { self = .none }
}

protocol AnyWalkPhotoBoothFlowContext {
  // It's WalkPhotoBoothFlowContext Interfase
  var walkManager: AnyWalkManager { get }
}

typealias AnyWalkPhotoBoothObservableFlowContext = (ObservableContext<WalkPhotoBoothFlowChange> &
  AnyWalkPhotoBoothFlowContext)

class WalkPhotoBoothFlowContext: ObservableContext<WalkPhotoBoothFlowChange> {
  // Paste Storage Properties
  // MARK: - Properties
  let walkManager: AnyWalkManager
  // MARK: - Init
  init(walkManager: AnyWalkManager) {
    self.walkManager = walkManager
  }
}

extension WalkPhotoBoothFlowContext: AnyWalkPhotoBoothFlowContext {
  // Implement AnyWalkPhotoBoothObservableFlowContext methods
}
