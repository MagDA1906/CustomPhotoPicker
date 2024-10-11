//
//  MenuViewController.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 11.10.2024.
//

import UIKit
import TableKit

final class MenuViewController: UIViewController {
  
  var onItemSelect: ((MenuModel.`Type`) -> Void)?
  
  private let clickableModels: [MenuModel]
  private let imagesModels: [ImageModel]
  private let menuView = MenuView()
  
  init(clickableModels: [MenuModel], imagesModels: [ImageModel]) {
    self.clickableModels = clickableModels
    self.imagesModels = imagesModels
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    
    view = menuView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNeedsStatusBarAppearanceUpdate()
    navigationController?.isNavigationBarHidden = true
    
    menuView.tableDirector.tableView?.tableHeaderView = UIView()
    menuView.tableDirector.tableView?.tableFooterView = UIView()
    
    menuView.tableView.isScrollEnabled = false
    setupDataSource()
  }
  
}

private extension MenuViewController {
  
  func setupDataSource() {
    let clickableRows = clickableModels.map {
      TableRow<ClickableTableViewCell>(item: $0)
        .on(.click) { [weak self] options in
          self?.onItemSelect?(options.item.type)
        }
    }
    
    let imagesRow = TableRow<ScrollTableViewCell>(item: imagesModels)
      .on(.click) { [weak self] options in
        print("onImaheSelect")
      }
    
    menuView.tableDirector.clear().append(rows: clickableRows + [imagesRow]).reload()
  }
  
}
