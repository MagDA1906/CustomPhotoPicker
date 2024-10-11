//
//  ScrollTableViewCell.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 14.10.2024.
//

import UIKit
import Cartography
import TableKit

final class ScrollTableViewCell: UITableViewCell, ConfigurableCell {
  
  static var cellHeight: CGFloat { 162 }
  static var defaultHeight: CGFloat? { cellHeight }
  
  private let imageCollectionView = ImageCollectionView()
  private lazy var scrollController = ImageScrollController(imageCollectionView: imageCollectionView)
  
  override init(style: CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addLayout()
    addStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with models: [ImageModel]) {
    scrollController.setHeaderWith(models)
  }
  
  private func addLayout() {
    contentView.addSubview(imageCollectionView)
    constrain(contentView, imageCollectionView) { root, imageCollectionView in
      imageCollectionView.top == root.top
      imageCollectionView.bottom == root.bottom
      imageCollectionView.leading == root.leading
      imageCollectionView.trailing == root.trailing
    }
  }
  
  private func addStyles() {
    backgroundColor = .clear
    selectionStyle = .none
  }
}
