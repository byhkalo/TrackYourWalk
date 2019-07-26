//
//  UITableView+CellViewDataModel.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit.UITableView

extension UITableView {
  func dequeueReusableCell(for indexPath: IndexPath, with model: AnyViewDataModelType) -> UITableViewCell {
    let cellIdentifier = String(describing: type(of: model).viewClass())
    let cell = dequeueReusableCell(withIdentifier: cellIdentifier,
                                   for: indexPath)
    cell.selectionStyle = .none
    model.updateAppearance(of: cell, in: self, at: indexPath)
    model.setup(on: cell)
    return cell
  }
  func dequeueReusableHeaderFooterView(with model: AnyViewDataModelType) -> UITableViewHeaderFooterView {
    let headerIdentifier = String(describing: type(of: model).viewClass())
    let header = dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier)!
    model.setup(on: header)
    return header
  }
}
