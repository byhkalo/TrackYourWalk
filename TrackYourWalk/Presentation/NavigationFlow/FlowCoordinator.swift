//
//  FlowCoordinator.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Coordinator
class FlowCoordinator<RootController, FlowContext> {
  // MARK: - Property
  fileprivate(set) var rootController: RootController
  fileprivate(set) var context: FlowContext
  // MARK: - Init
  required init(rootController: RootController, context: FlowContext) {
    self.rootController = rootController
    self.context = context
  }
  // MARK: - Subclasses
  /// Starting navigation flow. Override this method in subclasses
  func start() {
    assertionFailure("Need to override in subclasses")
  }
}
