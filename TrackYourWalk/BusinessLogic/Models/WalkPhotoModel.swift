//
//  WalkPhotoModel.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

// MARK: - Protocol
protocol AnyWalkPhotoModel {
  // MARK: - Properties
  var url: String { get }
  var title: String { get }
  var date: Date { get }
}

// MARK: - WalkPhotoModel
struct WalkPhotoModel: Codable {
  // MARK: - Properties
  let url: String
  var title: String
  var date: Date
}
// MARK: - Extend by AnyWalkPhotoModel
extension WalkPhotoModel: AnyWalkPhotoModel { }
