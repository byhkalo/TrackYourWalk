//
//  WalkPhotoBoothTableItemDataModel.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

struct WalkPhotoBoothTableItemDataModel {
  let title: String
  let thumbImageURL: String
}

extension WalkPhotoBoothTableItemDataModel: ViewDataModelType {
  func setup(on cell: WalkPhotoBoothTableCell) {
    cell.dateTimeLabel.text = title
    cell.downloadFrom(link: thumbImageURL, contentMode: .scaleAspectFill)
  }
}
