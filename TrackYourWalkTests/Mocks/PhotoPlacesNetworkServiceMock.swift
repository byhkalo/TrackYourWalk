//
//  PhotoPlacesNetworkServiceMock.swift
//  TrackYourWalkTests
//
//  Created by Konstantyn on 7/26/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
@testable import TrackYourWalk

class PhotoPlacesNetworkServiceMock: AnyPhotoPlacesNetworkService {
  var lastMethodCall: String?
  var lat: Double?
  var lon: Double?
  var completion: CompletionChangeStateHandler<AnyWalkPhotoModel?>?
  func getPhotoModel(byLat lat: Double, lon: Double,
                     completion: @escaping CompletionChangeStateHandler<AnyWalkPhotoModel?>) {
    self.lat = lat
    self.lon = lon
    self.completion = completion
    lastMethodCall = "\(#function)"
  }
}
