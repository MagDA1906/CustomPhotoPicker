//
//  MenuView.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 11.10.2024.
//

import UIKit
import Cartography
import TableKit

final class MenuView: UIView {
  
  let tableView = UITableView(frame: .zero, style: .grouped)
  let tableDirector: TableDirector
  
  init() {
    self.tableDirector = TableDirector(tableView: tableView)
    super.init(frame: .zero)
    
    addLayout()
    addStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

private extension MenuView {
  
  func addLayout() {
    addSubview(tableView)
    let inset: CGFloat = 1 / UIScreen.main.scale
    constrain(self, tableView) { parent, tableView in
      tableView.top == parent.safeAreaLayoutGuide.top + inset
      tableView.leading == parent.safeAreaLayoutGuide.leading + inset
      tableView.trailing == parent.safeAreaLayoutGuide.trailing - inset
      tableView.bottom == parent.safeAreaLayoutGuide.bottom - inset
    }
  }
  
  func addStyles() {
    backgroundColor = .darkGray
    tableView.layer.cornerRadius = 12
    tableView.layer.masksToBounds = true
    tableView.backgroundColor = .clear
  }
  
}



struct MenuModel {
  
  enum `Type` {
    case openGallery
    case takeFoto
    
    var title: String {
      
      switch self {
      case .openGallery: return "Photos"
      case .takeFoto: return "Take photo"
      }
      
    }
  }
  
  let type: `Type`
}
