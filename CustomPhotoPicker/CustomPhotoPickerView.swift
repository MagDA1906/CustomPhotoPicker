//
//  CustomPhotoPickerView.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 11.10.2024.
//

import UIKit
import Cartography

final class CustomPhotoPickerView: UIView {
  
  var onAddButtonTapped: (() -> Void)?
  
  let addButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "ic_plus")?.withTintColor(.blue, renderingMode: .alwaysTemplate), for: .normal)
    return button
  }()
  
  var imageView = UIImageView()
  
  init() {
    super.init(frame: .zero)
    
    addLayout()
    addStyles()
    
    addButton.addTarget(self, action: #selector(buttonTaped), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func buttonTaped() {
    onAddButtonTapped?()
  }
  
}

private extension CustomPhotoPickerView {
  
  func addLayout() {
    addSubview(addButton)
    addSubview(imageView)
    constrain(self, addButton, imageView) { root, addButton, imageView in
      addButton.centerX == root.centerX
      addButton.bottom == root.bottom - 16
      
      imageView.center == root.center
    }
  }
  
  func addStyles() {
    backgroundColor = .lightGray
  }
  
}
