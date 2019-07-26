//
//  WalkManagerTest.swift
//  TrackYourWalkTests
//
//  Created by Konstantyn on 7/26/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import XCTest
import CoreLocation
@testable import TrackYourWalk

class WalkManagerTest: XCTestCase {
  // MARK: - Properties
  ///Test Managers
  var sut: WalkManager!
  ///Mock Services
  let locationServiceMock = WalkTrackLocationServiceMock()
  let photoNetworkService = PhotoPlacesNetworkServiceMock()
  let photoDatabaseService = LocalPhotoDatabaseMock()
  // MARK: - Configuration Functions
  override func setUp() {
    super.setUp()
    sut = WalkManager(
      locationService: locationServiceMock,
      photoNetworkService: photoNetworkService,
      photoDatabaseService: photoDatabaseService)
  }
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  // MARK: - Test Functions
  func testWalkManagerInitiating() {
    ///-
    ///Object Created
    XCTAssertEqual(sut.isStarted, false)
    XCTAssertEqual(locationServiceMock.lastMethodCall, "addHandler(_:)")
    XCTAssertEqual(photoDatabaseService.lastMethodCall, "addDatabaseHandler(_:)")
    XCTAssertNil(photoNetworkService.lastMethodCall)
  }
  func testWalkManagerDestroy() {
    ///-
    ///Object Deinitiating
    ///Given
    XCTAssertEqual(locationServiceMock.lastMethodCall, "addHandler(_:)")
    XCTAssertEqual(photoDatabaseService.lastMethodCall, "addDatabaseHandler(_:)")
    ///When
    sut = nil
    ///Then
    XCTAssertEqual(locationServiceMock.lastMethodCall, "removeHandler(handlerId:)")
    XCTAssertEqual(photoDatabaseService.lastMethodCall, "removeDatabaseHandler(handlerId:)")
  }
  func testManualChangeToStopState() {
    ///-
    ///Manual Changing start state to negative
    ///Given
    XCTAssertEqual(sut.isStarted, false)
    ///When
    locationServiceMock.isStarted = false
    ///Then
    XCTAssertEqual(sut.isStarted, false)
  }
  func testManualChangeToStartState() {
    ///-
    ///Manual Changing start state to positive
    ///Given
    XCTAssertEqual(sut.isStarted, false)
    ///When
    locationServiceMock.isStarted = true
    ///Then
    XCTAssertEqual(sut.isStarted, true)
  }
  func testCallStartWalkFromStopState() {
    ///-
    ///Calling START method (check with NEGATIVE "Start" state)
    ///Given
    locationServiceMock.isStarted = false
    locationServiceMock.lastMethodCall = nil
    ///When
    sut.startWalk()
    ///Than
    XCTAssertEqual(locationServiceMock.lastMethodCall, "startTracking()")
  }
  func testCallStartWalkFromStartState() {
    ///-
    ///Calling START method (check with POSITIVE "Start" state)
    ///Given
    locationServiceMock.isStarted = true
    locationServiceMock.lastMethodCall = nil
    ///When
    sut.startWalk()
    ///Then
    XCTAssertNil(locationServiceMock.lastMethodCall)
  }
  func testCallStopWalkFromStopState() {
    ///-
    ///Calling FINISH method (check with NEGATIVE "Start" state)
    ///Given
    locationServiceMock.isStarted = false
    locationServiceMock.lastMethodCall = nil
    ///Given
    sut.finishWalk()
    ///Then
    XCTAssertNil(locationServiceMock.lastMethodCall)
  }
  func testCallStopWalkFromStartState() {
    ///-
    ///Calling FINISH method (check with POSITIVE "Start" state)
    ///Given
    locationServiceMock.isStarted = true
    locationServiceMock.lastMethodCall = nil
    ///When
    sut.finishWalk()
    ///Then
    XCTAssertEqual(locationServiceMock.lastMethodCall, "finishTracking()")
  }
  func testStartStopNotifications() {
    ///Given
    let promise = expectation(description: "Expect States")
    var walkUpdate: WalkUpdate?
    let handlerId = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    XCTAssertEqual(handlerId, 1)
    XCTAssertNotNil(locationServiceMock.locationServiceHandler)
    ///When
    locationServiceMock.locationServiceHandler?(.started)
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .started)
  }
  func testStopNotifications() {
    ///Given
    let promise = expectation(description: "Expect States")
    var walkUpdate: WalkUpdate?
    let handlerId = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    XCTAssertEqual(handlerId, 1)
    XCTAssertNotNil(locationServiceMock.locationServiceHandler)
    ///When
    locationServiceMock.locationServiceHandler?(.stoped)
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .stoped)
  }
  func testGenericErrorNotifications() {
    ///Given
    let promise = expectation(description: "Expect States")
    var walkUpdate: WalkUpdate?
    let handlerId = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    XCTAssertEqual(handlerId, 1)
    XCTAssertNotNil(locationServiceMock.locationServiceHandler)
    ///When
    let tempError = NSError(domain: "Some Test Error", code: 0, userInfo: nil)
    locationServiceMock.locationServiceHandler?(.genericError(tempError))
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .catchError(tempError))
  }
  func testAccessDenyNotifications() {
    ///Given
    let promise = expectation(description: "Expect States")
    var walkUpdate: WalkUpdate?
    let handlerId = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    XCTAssertEqual(handlerId, 1)
    XCTAssertNotNil(locationServiceMock.locationServiceHandler)
    ///When
    locationServiceMock.locationServiceHandler?(.authorizationStatusDenied)
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .authorizationStatusDenied)
  }
  func testHandlersIdentifiersCreating() {
    ///Given
    var handlerId1 = 0
    var handlerId2 = 0
    XCTAssertEqual(handlerId1, 0)
    XCTAssertEqual(handlerId2, 0)
    ///When
    handlerId1 = sut.addHandler { _ in }
    handlerId2 = sut.addHandler { _ in }
    ///Then
    XCTAssertEqual(handlerId1, 1)
    XCTAssertEqual(handlerId2, 2)
  }
  func testHandlersIdentifiersRecreating() {
    ///Given
    let handlerId1 = sut.addHandler { _ in }
    _ = sut.addHandler { _ in }
    sut.removeHandler(handlerId: handlerId1)
    ///When
    let handlerId3 = sut.addHandler { _ in }
    ///Then
    XCTAssertEqual(handlerId3, 3)
  }
  func testHandlersIdentifiersReuseOldIdentifier() {
    ///Given
    let handlerId1 = sut.addHandler { _ in }
    _ = sut.addHandler { _ in }
    var handlerId3 = sut.addHandler { _ in }
    sut.removeHandler(handlerId: handlerId1)
    sut.removeHandler(handlerId: handlerId3)
    ///When
    handlerId3 = sut.addHandler { _ in }
    ///Then
    XCTAssertEqual(handlerId3, 3)
  }
  func testFetchMethodWithEmptyCollection() {
    ///-
    ///Calling FETCH methods with EMPTY models Collection
    ///Given
    photoDatabaseService.lastMethodCall = nil
    XCTAssertNil(photoDatabaseService.lastMethodCall)
    ///When
    let allPhotos = sut.fetchAllPhotoBooth()
    ///Then
    XCTAssertEqual(photoDatabaseService.lastMethodCall, "getAllPlacePhotos()")
    XCTAssertEqual(allPhotos.count, 0)
  }
  func testFetchMethodWithModelsCollection() {
    ///-
    ///Calling FETCH methods with NOT EMPTY models Collection
    ///Given
    photoDatabaseService.lastMethodCall = nil
    XCTAssertNil(photoDatabaseService.lastMethodCall)
    let photosForReturn: [AnyWalkPhotoModel] = [WalkPhotoModel(url: "1", title: "1", date: Date())]
    photoDatabaseService.photosForReturn = photosForReturn
    ///When
    let allPhotos2 = sut.fetchAllPhotoBooth()
    ///Then
    XCTAssertEqual(photoDatabaseService.lastMethodCall, "getAllPlacePhotos()")
    XCTAssertNotNil(allPhotos2)
    XCTAssertEqual(allPhotos2.count, 1)
    XCTAssertEqual(allPhotos2.first?.url, "1")
    XCTAssertEqual(allPhotos2.first?.title, "1")
  }
  func testPhotosRequestingSuccess() {
    ///-
    ///Calling Save (Local database) methods Through location service notifying
    ///Given
    photoDatabaseService.lastMethodCall = nil
    XCTAssertNil(photoDatabaseService.lastMethodCall)
    let tempPhotoModel = WalkPhotoModel(url: "2", title: "2", date: Date())
    locationServiceMock.lastLocation = CLLocation(latitude: 50.01, longitude: 32.01)
    ///When
    locationServiceMock.locationServiceHandler?(.regionUpdate)
    photoNetworkService.completion?(.success(tempPhotoModel))
    ///Then
    XCTAssertEqual(photoNetworkService.lat, 50.01)
    XCTAssertEqual(photoNetworkService.lon, 32.01)
    XCTAssertNotNil(photoNetworkService.completion)
    XCTAssertEqual(photoNetworkService.lastMethodCall, "getPhotoModel(byLat:lon:completion:)")
    XCTAssertEqual(photoDatabaseService.lastMethodCall, "create(photoModel:)")
    XCTAssertNotNil(photoDatabaseService.createPhotoModel)
    XCTAssertEqual(photoDatabaseService.createPhotoModel?.url, "2")
    XCTAssertEqual(photoDatabaseService.createPhotoModel?.title, "2")
  }
  func testPhotosRequestingEmpty() {
    ///-
    ///Shouldn't call any methods for database service if response models (from network service) is nil
    ///Given
    photoDatabaseService.lastMethodCall = nil
    XCTAssertNil(photoDatabaseService.lastMethodCall)
    locationServiceMock.lastLocation = CLLocation(latitude: 50.01, longitude: 32.01)
    ///When
    locationServiceMock.locationServiceHandler?(.regionUpdate)
    photoNetworkService.completion?(.success(nil))
    ///Then
    XCTAssertEqual(photoNetworkService.lat, 50.01)
    XCTAssertEqual(photoNetworkService.lon, 32.01)
    XCTAssertNotNil(photoNetworkService.completion)
    XCTAssertEqual(photoNetworkService.lastMethodCall, "getPhotoModel(byLat:lon:completion:)")
    XCTAssertNil(photoDatabaseService.lastMethodCall)
    XCTAssertNil(photoDatabaseService.createPhotoModel)
  }
  func testPhotosRequestingWithoutLocation() {
    ///-
    ///Shouldn't call getPhoto method from network model if we don't have a location coordinates
    ///Given
    photoDatabaseService.lastMethodCall = nil
    XCTAssertNil(photoDatabaseService.lastMethodCall)
    locationServiceMock.lastLocation = nil
    ///When
    locationServiceMock.locationServiceHandler?(.regionUpdate)
    photoNetworkService.completion?(.success(nil))
    ///Then
    XCTAssertNil(photoNetworkService.lat)
    XCTAssertNil(photoNetworkService.lon)
    XCTAssertNil(photoNetworkService.completion)
    XCTAssertNil(photoNetworkService.lastMethodCall)
  }
  func testPhotosRequestingWithError() {
    ///-
    ///Calling Save (Local database) methods Through location service notifying
    ///Given
    photoDatabaseService.lastMethodCall = nil
    locationServiceMock.lastLocation = CLLocation(latitude: 50.01, longitude: 32.01)
    let tempError = NSError(domain: "Some Test Error", code: 0, userInfo: nil)
    let promise = expectation(description: "Expect photoUpdate")
    var walkUpdate: WalkUpdate?
    _ = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    ///When
    locationServiceMock.locationServiceHandler?(.regionUpdate)
    photoNetworkService.completion?(.error(tempError))
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .catchError(tempError))
    XCTAssertEqual(photoNetworkService.lat, 50.01)
    XCTAssertEqual(photoNetworkService.lon, 32.01)
    XCTAssertNotNil(photoNetworkService.completion)
    XCTAssertEqual(photoNetworkService.lastMethodCall, "getPhotoModel(byLat:lon:completion:)")
    XCTAssertNil(photoDatabaseService.lastMethodCall)
    XCTAssertNil(photoDatabaseService.createPhotoModel)
  }
  func testDatabasePhotosUpdate() {
    ///-
    ///Calling Update notification by local database service notifying
    ///Given
    let promise = expectation(description: "Expect photoUpdate")
    var walkUpdate: WalkUpdate?
    _ = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    XCTAssertNotNil(photoDatabaseService.localPhotoDatabaseHandler)
    ///When
    photoDatabaseService.localPhotoDatabaseHandler?(.photosDidChange)
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .photoUpdated)
  }
  func testDatabasePhotosDeletedAll() {
    ///-
    ///Calling Update notification by local database service notifying
    ///Given
    let promise = expectation(description: "Expect photoUpdate")
    var walkUpdate: WalkUpdate?
    _ = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    XCTAssertNotNil(photoDatabaseService.localPhotoDatabaseHandler)
    ///When
    photoDatabaseService.localPhotoDatabaseHandler?(.deletedAll)
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .photoUpdated)
  }
  func testDatabasePhotosSaved() {
    ///-
    ///Calling Update notification by local database service notifying
    ///Given
    let promise = expectation(description: "Expect photoUpdate")
    var walkUpdate: WalkUpdate?
    _ = sut.addHandler { (state) in
      walkUpdate = state
      promise.fulfill()
    }
    XCTAssertNotNil(photoDatabaseService.localPhotoDatabaseHandler)
    ///When
    photoDatabaseService.localPhotoDatabaseHandler?(.photoSaved)
    ///Then
    wait(for: [promise], timeout: 5)
    XCTAssertNotNil(walkUpdate)
    XCTAssertTrue(walkUpdate == .photoUpdated)
  }

}
