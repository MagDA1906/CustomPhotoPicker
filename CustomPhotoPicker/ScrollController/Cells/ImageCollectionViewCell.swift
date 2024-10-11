//
//  ImageCollectionViewCell.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 14.10.2024.
//

import UIKit
import Cartography

final class ImageCollectionViewCell: UICollectionViewCell {
  
  private var imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
    setupAppearance()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func setupLayout() {
    contentView.addSubview(imageView)
    constrain(contentView, imageView) { contentView, imageView in
      imageView.top == contentView.top
      imageView.bottom == contentView.bottom
      imageView.leading == contentView.leading
      imageView.trailing == contentView.trailing
      
      imageView.height == 126
      imageView.width == 96
    }
  }
  
  private func setupAppearance() {
    
    contentView.layer.cornerRadius = 12
    contentView.clipsToBounds = true
  }
  
  func configure(with model: ImageModel) {
    imageView.image = model.image
  }
}

public extension UICollectionViewCell {
  
  static var reusableIdentifier: String {
    String(describing: self)
  }
}
