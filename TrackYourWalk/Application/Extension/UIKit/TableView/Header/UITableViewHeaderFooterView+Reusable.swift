//
//  UITableViewHeaderFooterView+Reusable.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import UIKit

extension UITableViewHeaderFooterView: Reusable {
  @objc static var identifier: String {
    return String(describing: self)
  }
}
