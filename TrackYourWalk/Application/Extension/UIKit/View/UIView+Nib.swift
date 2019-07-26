//
//  UIView+Nib.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  // MARK: - Static Properties
  @objc static var nib: UINib {
    return UINib(nibName: String(describing: self), bundle: nil)
  }
  // MARK: - Static Functions
  static func instantiateFromNib<ViewType: UIView>(withName initialNibName: String? = nil) -> ViewType {
    var result: ViewType?
    let nibName = initialNibName ?? String(describing: self)
    if let views = Bundle.main.loadNibNamed(nibName, owner: self, options: nil) {
      if views.isEmpty == false {
        result = views.first as? ViewType
      }
    }
    return result!
  }
}
