//
//  WalkPhotoBoothViewModel.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

enum WalkPhotoBoothChange {
  case none
  case update
  case showLoadingView
  case updateStartStopTitle
  case showError(String)
}

typealias WalkPhotoBoothUpdateHandler = CompletionChangeHandler<WalkPhotoBoothChange>

// MARK: - AnyWalkPhotoBoothCollectionViewModel
protocol AnyWalkPhotoBoothCollectionViewModel {
  func numberOfItems() -> Int
  func item(indexPath: IndexPath) -> AnyWalkPhotoModel?
}

// MARK: - AnyWalkPhotoBoothViewModel
protocol AnyWalkPhotoBoothViewModel: AnyObject {
  /// Properties
  var walkPhotoBoothUpdateHandler: WalkPhotoBoothUpdateHandler? { get set }
  var walkManageButtonTitle: String { get }
  /// Open Detail Screen
  func selectItem(at indexPath: IndexPath)
  func startStopWalkSession()
}

class WalkPhotoBoothViewModel {
  // MARK: - Properties
  var walkPhotoBoothUpdateHandler: WalkPhotoBoothUpdateHandler?
  var walkManageButtonTitle: String {
    return context.walkManager.isStarted ? "Stop" : "Start"
  }
  // MARK: - Private Properties
  fileprivate(set) var context: AnyWalkPhotoBoothObservableFlowContext
  fileprivate(set) weak var router: AnyWalkPhotoBoothRouter?
  fileprivate var photoItemModels = [AnyWalkPhotoModel]()
  ///Handlers Identifiers
  fileprivate var walkManagerHandlerId: Int = 0
  // MARK: - Init
  init(context: AnyWalkPhotoBoothObservableFlowContext, router: AnyWalkPhotoBoothRouter) {
    self.context = context
    self.router = router
    fetchPhoto()
    subscribe()
  }
  deinit {
    unsubscribe()
  }
}

// MARK: - Private Help Methods
fileprivate extension WalkPhotoBoothViewModel {
  func fetchPhoto() {
    self.photoItemModels = context.walkManager.fetchAllPhotoBooth()
    self.walkPhotoBoothUpdateHandler?(WalkPhotoBoothChange.update)
  }
}
// MARK: - Extension AnyWalkPhotoBoothViewModel
extension WalkPhotoBoothViewModel: AnyWalkPhotoBoothViewModel {
  func selectItem(at indexPath: IndexPath) { }
  func startStopWalkSession() {
    if context.walkManager.isStarted {
      context.walkManager.finishWalk()
    } else {
      context.walkManager.startWalk()
    }
    print(#function)
  }
}
// MARK: - Extension AnyWalkPhotoBoothCollectionViewModel
extension WalkPhotoBoothViewModel: AnyWalkPhotoBoothCollectionViewModel {
  func numberOfItems() -> Int {
    return photoItemModels.count
  }
  func item(indexPath: IndexPath) -> AnyWalkPhotoModel? {
    guard indexPath.row >= 0 && indexPath.row < photoItemModels.count
      else { return nil }
    return photoItemModels[indexPath.row]
  }
}
// MARK: - Subscribe/Unsubscribe Methods
fileprivate extension WalkPhotoBoothViewModel {
  func subscribe() {
    walkManagerHandlerId = context.walkManager.addHandler { [weak self] change in
      guard let `self` = self else { return }
      switch change {
      case .started: self.walkPhotoBoothUpdateHandler?(.updateStartStopTitle)
      case .stoped: self.walkPhotoBoothUpdateHandler?(.updateStartStopTitle)
      case .photoUpdated: self.fetchPhoto()
      case .catchError(let error):
        self.walkPhotoBoothUpdateHandler?(.showError(error.localizedDescription))
      case .authorizationStatusDenied:
        self.walkPhotoBoothUpdateHandler?(.showError(Constants.Text.authorizationDeniedError))
      }
    }
  }
  func unsubscribe() {
    context.walkManager.removeHandler(handlerId: walkManagerHandlerId)
  }
}
