//
//  PhotoPlacesNetworkService.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/20/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

protocol AnyPhotoPlacesNetworkService {
  func getPhotoModel(byLat lat: Double, lon: Double,
                     completion: @escaping CompletionChangeStateHandler<AnyWalkPhotoModel?>)
}

class PhotoPlacesNetworkService {
}

extension PhotoPlacesNetworkService: AnyPhotoPlacesNetworkService {
  func getPhotoModel(byLat lat: Double, lon: Double,
                     completion: @escaping CompletionChangeStateHandler<AnyWalkPhotoModel?>) {
    _ = API.getPhotos(apiKey: Constants.flickrKey, lat: lat, lon: lon)
      .fetchWithMapping(completion: { (state: SuccessCompletionChangeState<FlickrSearchImagesResponse>) in
        switch state {
        case .success(let flickrSearchImages):
          let pfotos = flickrSearchImages.photos.photo
          if pfotos.isEmpty {
            completion(.success(nil))
          } else {
            completion(.success(flickrSearchImages.photos.photo.first))
          }
        case .error(let error): completion(.error(error))
        }
      })
  }
}

// MARK: - API -
typealias DataHandler = CompletionChangeStateHandler<Data>
typealias ModelHandler<T: Codable> = CompletionChangeStateHandler<T>

enum API {
  //Webhook GET
  case getPhotos(apiKey: String, lat: Double, lon: Double)
  // Properties
  var mainURLString: String {
    switch self {
    case .getPhotos:
      return "https://www.flickr.com/services/rest/"
    }
  }
  var httpMethod: String {
    switch self {
    case .getPhotos:
      return "GET"
    }
  }
  var requestPart: String {
    switch self {
    case let .getPhotos(apiKey, lat, lon):
      return "?method=flickr.photos.search&api_key=\(apiKey)&lat=\(lat)&lon=\(lon)&radius=0.5&radius_units=km&format=json&nojsoncallback=1"
    }
  }
  var body: Data? {
    switch self {
    case .getPhotos: return nil
    }
  }
  private var path: URL {
    return URL(string: mainURLString + requestPart)!
  }
  // Fetch Methods
  func fetchWithMapping<Model: Codable>(completion: @escaping ModelHandler<Model>) -> URLSessionDataTask {
    return fetch(completion: { (state) in
      switch state {
      case .success(let data):
        do {
          let serverResponseModel = try JSONDecoder().decode(Model.self, from: data)
          completion(.success(serverResponseModel))
        } catch {
          completion(.error(error))
        }
      case .error(let error): completion(.error(error))
      }
    })
  }
  func fetch(completion: @escaping DataHandler) -> URLSessionDataTask {
    var request = URLRequest(url: path)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpMethod = httpMethod
    if let bodyData = body {
      request.httpBody = bodyData
    }
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      let genericError =  NSError(domain: "Unknown Error Function: \(#function) Line: \(#line)", code: 1, userInfo: nil)
      guard let response = response as? HTTPURLResponse
        else { completion(.error(genericError)); return }
      if let error = error {
        completion(.error(error))
      } else if response.statusCode >= 400 {
        let genericError =  NSError(domain: "Get error", code: response.statusCode, userInfo: nil)
        if let data = data, let answerError = try? JSONSerialization.jsonObject(with: data,
                                                                                options: .allowFragments) {
          print(answerError)
        }
        completion(.error(genericError))
      } else if let data = data {
        completion(.success(data))
      } else {
        completion(.error(genericError))
      }
    }
    task.resume()
    return task
  }
}
