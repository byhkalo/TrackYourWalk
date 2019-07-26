//
//  WalkPhotoBoothFlowCoordinator.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

protocol AnyWalkPhotoBoothRouter: class {
  func openDetailScreen()
  func closeDetailScreen()
}

class WalkPhotoBoothFlowCoordinator: FlowCoordinator<UINavigationController, AnyWalkPhotoBoothObservableFlowContext> {
  // MARK: - Override
  override func start() {
    let viewModel = WalkPhotoBoothViewModel(context: context, router: self)
    let walkPhotoBoothViewController = WalkPhotoBoothViewController()
    let displayCollection = WalkPhotoBoothDisplayCollection(viewModel)
    if walkPhotoBoothViewController.viewModel == nil {
      walkPhotoBoothViewController.viewModel = viewModel
    }
    if walkPhotoBoothViewController.displayCollection == nil {
      walkPhotoBoothViewController.displayCollection = displayCollection
    }
    self.rootController.pushViewController(walkPhotoBoothViewController, animated: false)
    walkPhotoBoothViewController.navigationItem.hidesBackButton = true
  }
}

extension WalkPhotoBoothFlowCoordinator: AnyWalkPhotoBoothRouter {
  func openDetailScreen() { }
  func closeDetailScreen() { }
}
