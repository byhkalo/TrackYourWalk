//
//  Reusable.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import UIKit

protocol Reusable {
  static var identifier: String { get }
  static var nib: UINib { get }
}

extension Reusable {
  static var identifier: String {
    return String(describing: self)
  }
}
