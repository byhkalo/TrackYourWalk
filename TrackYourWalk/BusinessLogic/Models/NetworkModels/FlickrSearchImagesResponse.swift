//
//  FlickrSearchImagesResponse.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

struct FlickrSearchImagesResponse: Codable {
  let photos: FlickrPhotos
  let stat: String
}

struct FlickrPhotos: Codable {
  let page: Int
  let pages: Int
  let perpage: Int
  let total: String
  let photo: [FlickrPhotoModel]
}

struct FlickrPhotoModel: Codable {
  //swiftlint:disable:next identifier_name
  let id: String
  let owner: String
  let secret: String
  let server: String
  let farm: Int
  let title: String
}

extension FlickrPhotoModel: AnyWalkPhotoModel {
  var url: String {
    return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_z.jpg"
  }
  var date: Date {
    return Date()
  }
}
