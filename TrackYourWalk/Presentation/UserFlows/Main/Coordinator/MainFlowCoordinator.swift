//
//  MainFlowCoordinator.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

class MainFlowCoordinator: FlowCoordinator<UINavigationController, AnyMainFlowContext> {
  // MARK: - Private Properties
  fileprivate var mainViewController: MainViewController!
  fileprivate var walkPhotoBoothFlowCoordinator: WalkPhotoBoothFlowCoordinator!
  // MARK: - Public
  override func start() {
    startMainFlow()
  }
}

private extension MainFlowCoordinator {
  func startMainFlow() {
    guard let currentMainViewController = rootController.viewControllers.first as? MainViewController
      else { return }
    mainViewController = currentMainViewController
    mainViewController.model = MainViewModel()
    /// Correct place for deciding what flow should start.
    /// In this case we start only One First Flow - WalkPhotoBoothFlow
    startWalkPhotoBoothFlow()
  }
  func startWalkPhotoBoothFlow() {
    if walkPhotoBoothFlowCoordinator == nil {
      walkPhotoBoothFlowCoordinator =
        WalkPhotoBoothFlowCoordinator(rootController: rootController,
                                     context: context.walkPhotoBoothContext)
    }
    walkPhotoBoothFlowCoordinator.start()
  }
}
