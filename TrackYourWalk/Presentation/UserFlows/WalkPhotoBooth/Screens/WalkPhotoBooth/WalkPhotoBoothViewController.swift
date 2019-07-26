//
//  WalkPhotoBoothViewController.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation
import UIKit

class WalkPhotoBoothViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet fileprivate var tableView: UITableView!
  // MARK: - Properties
  ///Views
  lazy var startStopButton: UIBarButtonItem = {
    let tempButton = UIBarButtonItem(
      title: viewModel.walkManageButtonTitle, style: UIBarButtonItem.Style.plain,
      target: self, action: #selector(startStopWalkSession))
    return tempButton
  }()
  ///State Objects
  var viewModel: AnyWalkPhotoBoothViewModel! {
    didSet {
      guard oldValue !== self.viewModel else { return }
      if let oldValue = oldValue { unsubscribe(anyViewModel: oldValue) }
      if self.viewModel != nil { subscribe() }
    }
  }
  var displayCollection: WalkPhotoBoothDisplayCollection!
  // MARK: - Private Properties
  // MARK: - Init
  deinit {
    self.unsubscribe(anyViewModel: viewModel)
  }
  // MARK: - ViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureTableView()
    configureNavigationBar()
  }
  // MARK: - Configure Methods
  func configureTableView() {
    displayCollection.setup(on: tableView)
    tableView.dataSource = self
    tableView.delegate = self
  }
  func configureNavigationBar() {
    navigationItem.title = "Walk Tracker"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItem = startStopButton
  }
  // MARK: - Actions
  @objc func startStopWalkSession() {
    viewModel.startStopWalkSession()
  }
}

// MARK: - Private Help Methods
extension WalkPhotoBoothViewController {
  func updateStartStopButton() {
    let newTitle = viewModel.walkManageButtonTitle
    startStopButton.title = newTitle
  }
}

// MARK: - UITableViewDataSource
extension WalkPhotoBoothViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayCollection.numberOfRows(in: section)
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = displayCollection.model(for: indexPath)
    return tableView.dequeueReusableCell(for: indexPath, with: model)
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return displayCollection.heightForRow(at: indexPath)
  }
}
// MARK: - UITableViewDelegate
extension WalkPhotoBoothViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.selectItem(at: indexPath)
  }
}
// MARK: - Private Subscribe
fileprivate extension WalkPhotoBoothViewController {
  func unsubscribe(anyViewModel: AnyWalkPhotoBoothViewModel) {
    anyViewModel.walkPhotoBoothUpdateHandler = nil
  }
  func subscribe() {
    viewModel.walkPhotoBoothUpdateHandler = { [weak self] change in
      guard let `self` = self else { return }
      DispatchQueue.main.async {
        switch change {
        case .update:
          self.tableView.reloadData()
        case .showLoadingView: break
        case .updateStartStopTitle:
          self.updateStartStopButton()
        case .showError(let message):
          self.presentErrorAlert(with: message)
        case .none: break
        }
      }
    }
  }
}
