//
//  WalkPhotoBoothDisplayCollection.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

class WalkPhotoBoothDisplayCollection: DisplayDataCollection {
  // MARK: - Static Properties
  static var modelsForRegistration: [AnyViewDataModelType.Type] {
    return [WalkPhotoBoothTableItemDataModel.self]
  }
  // MARK: - Private Properties
  fileprivate let viewModel: AnyWalkPhotoBoothCollectionViewModel
  // MARK: - Init
  init(_ viewModel: AnyWalkPhotoBoothCollectionViewModel) {
    self.viewModel = viewModel
  }
  // MARK: DataSource
  func numberOfRows(in section: Int) -> Int {
    return viewModel.numberOfItems()
  }
  func model(for indexPath: IndexPath) -> AnyViewDataModelType {
    guard let searchItem = viewModel.item(indexPath: indexPath)
      else { return EmptyDataModel() }
    let dataItem = WalkPhotoBoothTableItemDataModel(
      title: searchItem.title,
      thumbImageURL: searchItem.url)
    return dataItem
  }
  func heightForRow(at indexPath: IndexPath) -> CGFloat {
    return 180.0
  }
}

// MARK: - ViewDataModelType
extension WalkPhotoBoothDisplayCollection: ViewDataModelType {
  func setup(on tableView: UITableView) {
    tableView.registerNibs(from: self)
  }
}
