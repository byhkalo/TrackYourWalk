//
//  WalkPhotoBoothTableCell.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

class WalkPhotoBoothTableCell: UITableViewCell {
  // MARK: - Outlets
  @IBOutlet fileprivate var photoImageView: UIImageView!
  @IBOutlet fileprivate(set) var dateTimeLabel: UILabel!
  // MARK: - Properties
  ///State Objects
  var loadTask: URLSessionDataTask?
  var loadLink: String?
  // MARK: - Load Action
  func downloadFrom(link: String?, contentMode mode: UIView.ContentMode) {
    guard loadLink != link else { return }
    photoImageView.contentMode = mode
    photoImageView.image = nil
    if let loadTask = loadTask {
      loadTask.suspend()
    }
    if let link = link, let url = URL(string: link) {
      loadLink = link
      let tempLoadTask = URLSession.shared
        .dataTask(with: url, completionHandler: { [weak self] (data, _, error) -> Void in
        guard let `self` = self else { return }
        guard let data = data, error == nil
          else { print("\nerror on download \(error?.localizedDescription ?? "image")"); return }
        DispatchQueue.main.async {
          self.photoImageView.image = UIImage(data: data)
          self.layoutSubviews()
        }
      })
      tempLoadTask.resume()
      self.loadTask = tempLoadTask
    } else {
      photoImageView.image = nil
    }
  }
}
