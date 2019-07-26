//
//  ViewController+Error.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/25/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func presentErrorAlert(with message: String) {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
    alertController.addAction(okAction)
    present(alertController, animated: true, completion: nil)
  }
}
