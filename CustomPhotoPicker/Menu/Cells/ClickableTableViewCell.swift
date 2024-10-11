//
//  ClickableTableViewCell.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 14.10.2024.
//

import UIKit
import Cartography
import TableKit

final class ClickableTableViewCell: UITableViewCell, ConfigurableCell {
  
  static var cellHeight: CGFloat { 44 }
  static var defaultHeight: CGFloat? { cellHeight }
  
  private var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 17, weight: .regular)
    label.textColor = .white
    return label
  }()
  
  override init(style: CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addLayout()
    addStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with model: MenuModel) {
    titleLabel.text = model.type.title
  }
  
  private func addLayout() {
    contentView.addSubview(titleLabel)
    constrain(contentView, titleLabel) { root, titleLabel in
      titleLabel.centerY == root.centerY
      titleLabel.leading == root.leading + 16
      titleLabel.trailing == root.trailing - 16
    }
  }
  
  private func addStyles() {
    backgroundColor = .clear
    selectionStyle = .none
  }
}
