//
//  ImageCollectionView.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 14.10.2024.
//

import UIKit

final class ImageCollectionView: UICollectionView {
  private static var layout: UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = .zero
    layout.minimumLineSpacing = 12
    layout.minimumInteritemSpacing = 12
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    return layout
  }
  
  convenience init() {
    self.init(frame: .zero, collectionViewLayout: Self.layout)
    isScrollEnabled = true
    showsHorizontalScrollIndicator = false
    backgroundColor = .clear
  }
}
