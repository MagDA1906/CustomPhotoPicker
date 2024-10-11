//
//  ImageScrollController.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 11.10.2024.
//

import UIKit
import Cartography

final class ImageScrollController: NSObject {
  
  private let imageCollectionView: ImageCollectionView
  var onImageItemSelect: ((String) -> ())?
  
  private var dataSource: [ImageModel] = [] {
    didSet {
      guard oldValue != dataSource else { return }
      
      imageCollectionView.reloadData()
      imageCollectionView.isHidden = dataSource.isEmpty
    }
  }
  
  private var cellType = ImageCollectionViewCell.self
  
  init(imageCollectionView: ImageCollectionView) {
    self.imageCollectionView = imageCollectionView
    super.init()
    setup()
  }
  
  private func setup() {
    imageCollectionView.delegate = self
    imageCollectionView.dataSource = self
    
    imageCollectionView.register(cellType, forCellWithReuseIdentifier: cellType.reusableIdentifier)
    
    imageCollectionView.reloadData()
    imageCollectionView.isHidden = dataSource.isEmpty
  }
  
  func setHeaderWith(_ models: [ImageModel]) {
    self.dataSource = models
  }
  
  private func modelForRow(at indexPath: IndexPath) -> ImageModel? {
    dataSource.getOrNil(indexPath.item)
  }
}

// MARK: - Data source
extension ImageScrollController: UICollectionViewDataSource  {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    dataSource.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let viewCell = collectionView.dequeueReusableCell(
      withReuseIdentifier: cellType.reusableIdentifier,
      for: indexPath
    )
    
    if
      let cell = viewCell as? ImageCollectionViewCell,
      let model = modelForRow(at: indexPath)
    {
      cell.configure(with: model)
    }
    
    return viewCell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    canMoveItemAt indexPath: IndexPath
  ) -> Bool {
    false
  }
}

//MARK: - Handle selection
extension ImageScrollController: UICollectionViewDelegate {
  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    if let model = modelForRow(at: indexPath) {
      onImageItemSelect?(model.id)
    }
  }
}

struct ImageModel: Equatable {
  let id: String
  let image: UIImage
}

public extension Array {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  func getOrNil(_ index: Int) -> Element? {
    index >= 0 && index < count ? self[index] : nil
  }
}
