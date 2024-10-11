//
//  CustomPhotoPickerViewController.swift
//  CustomPhotoPicker
//
//  Created by Magilnitsky Denis on 11.10.2024.
//

import UIKit
import Cartography
import PhotosUI
import AVFoundation

struct Item: Identifiable, Equatable {
  let id = UUID()
  let url: URL
}

final class CustomPhotoPickerViewController: UIViewController {
  
  private let photoPickerView = CustomPhotoPickerView()
  private let imagePickerController = UIImagePickerController()
  
  private var capturedImages = [UIImage]()
  
  private var album: PHAssetCollection?
  
  private var assets: PHFetchResult<PHAsset>? {
    guard let album else { return nil }
    let options = PHFetchOptions()
//    options.predicate = NSPredicate(format: "title = %@", folderName)
    return PHAsset.fetchAssets(in: album, options: options)
  }
  
//  private lazy var assets: PHFetchResult<PHAsset>? = {
//    guard let album = self.album else { return nil }
//    let options = PHFetchOptions()
//    return PHAsset.fetchAssets(in: album, options: options)
//  }()
  
  private var images = [UIImage]()
  
  private let mockMenuItems = MenuItems(
    clickableModels: [MenuModel(type: .openGallery), MenuModel(type: .takeFoto)],
    imagesModels: []
  )

  override func loadView() {
    super.loadView()
    
    view = photoPickerView
  }
  
  func makeAlbum(completion: @escaping (PHAssetCollection?) -> Void) {
    var placeholder: PHObjectPlaceholder?
    
    PHPhotoLibrary.shared().performChanges {
      let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: folderName)
      placeholder = request.placeholderForCreatedAssetCollection
    } completionHandler: { success, error in
      if success, let id = placeholder?.localIdentifier {
        let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
        completion(fetchResult.firstObject)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imagePickerController.modalPresentationStyle = .currentContext
    imagePickerController.delegate = self
    
    photoPickerView.onAddButtonTapped = { [weak self] in
      guard let self else { return }
      self.showMenu(items: self.mockMenuItems)
    }
    
    if let album = collection.firstObject {
      self.album = album
    } else {
      makeAlbum { [weak self] album in
        self?.album = album
      }
    }
  }

}

extension CustomPhotoPickerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  func showMenu(items: MenuItems) {
    
    if let assets = self.assets, assets.count > 0 {
      self.images.removeAll()
      
      for index in 0...assets.count - 1 {
        let asset = assets[index]
        PHImageManager.default().requestImage(
          for: asset,
          targetSize: CGSize(width: 100, height: 100),
          contentMode: .aspectFill,
          options: nil) { [weak self] (image, _) -> Void in
            guard let image else { return }
            self?.images.append(image)
          }
      }
    }
    
    let menu = MenuViewController(
      clickableModels: items.clickableModels,
      imagesModels: images.map { ImageModel(id: "", image: $0) }
    )
    
    menu.modalPresentationStyle = .popover
    let width: CGFloat = 360
    let height: CGFloat = ClickableTableViewCell.cellHeight * CGFloat(items.clickableModels.count) + ScrollTableViewCell.cellHeight + 16
    menu.preferredContentSize = CGSize(width: width, height: height)
    
    let presentationController = menu.popoverPresentationController
    presentationController?.backgroundColor = .black
    presentationController?.sourceView = self.photoPickerView.addButton
    presentationController?.sourceRect = CGRect(
      x: self.photoPickerView.addButton.bounds.midX,
      y: self.photoPickerView.addButton.bounds.minY + 2,
      width: 0,
      height: 0
    )
    presentationController?.permittedArrowDirections = .down

    self.present(menu, animated: true)
    
    menu.onItemSelect = { [weak self] itemType in
      self?.dismiss(animated: true)
      
      switch itemType {
      case .takeFoto:
        self?.showImagePickerForCamera()
      case .openGallery:
        self?.showImagePickerForPhotoPicker()
      }
      
      // Easy way to show photo view
//      let cameraVc = UIImagePickerController()
//      cameraVc.sourceType = UIImagePickerController.SourceType.camera
//      self?.present(cameraVc, animated: true, completion: nil)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.originalImage] as? UIImage else { return }
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    
    PHPhotoLibrary.shared().performChanges({ [weak self] in
      
      guard let album = self?.album, let assets = self?.assets else { return }
      let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
      
      let albumChangeRequest = PHAssetCollectionChangeRequest(for: album, assets: assets)
      if let assetPlaceholder = assetRequest.placeholderForCreatedAsset {
        let assetPlaceholders: NSArray = [assetPlaceholder]
        albumChangeRequest?.addAssets(assetPlaceholders)
      }
    }, completionHandler: nil)
    
    picker.dismiss(animated: true, completion: nil)
  }
  
}

private extension CustomPhotoPickerViewController {
  
  func showImagePickerForPhotoPicker() {
    showImagePicker(sourceType: UIImagePickerController.SourceType.photoLibrary)
  }
  
  func showImagePickerForCamera() {
    let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    
    if authStatus == AVAuthorizationStatus.denied {
      // The system denied access to the camera. Alert the user.
      
      /*
       The user previously denied access to the camera. Tell the user this
       app requires camera access.
       */
      let alert = UIAlertController(
        title: "Unable to access the Camera",
                                    message: "To turn on camera access, choose Settings > Privacy > Camera and turn on Camera access for this app.",
                                    preferredStyle: UIAlertController.Style.alert
      )
      
      let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
      alert.addAction(okAction)
      
      let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
        // Take the user to the Settings app to change permissions.
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
          UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            // The resource finished opening.
          })
        }
      })
      alert.addAction(settingsAction)
      
      present(alert, animated: true, completion: nil)
    } else if authStatus == AVAuthorizationStatus.notDetermined {
      /*
       The user never granted or denied permission for media capture with
       the camera. Ask for permission.
       
       Note: The app must provide a `Privacy - Camera Usage Description`
       key in the Info.plist with a message telling the user why the app
       is requesting access to the device’s camera. See this app's
       Info.plist for such an example usage description.
       */
      AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
        if granted {
          DispatchQueue.main.async {
//            self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
            self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera)
          }
        }
      })
    } else {
      /*
       The user granted permission to access the camera. Present the
       picker for capture.
       
       Set the image picker `sourceType` property to
       `UIImagePickerController.SourceType.camera` to configure the picker
       for media capture instead of browsing saved media.
       */
//      showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
      showImagePicker(sourceType: UIImagePickerController.SourceType.camera)
    }
  }
  
//  func showImagePicker(sourceType: UIImagePickerController.SourceType, button: UIView) {
  func showImagePicker(sourceType: UIImagePickerController.SourceType) {
    // Stop animating the images in the view.
    if photoPickerView.imageView.isAnimating {
      photoPickerView.imageView.stopAnimating()
    }
    if !capturedImages.isEmpty {
      capturedImages.removeAll()
    }
    
    imagePickerController.sourceType = sourceType
    imagePickerController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//    (sourceType == UIImagePickerController.SourceType.camera) ?
//    UIModalPresentationStyle.fullScreen : UIModalPresentationStyle.popover
    
    let presentationController = imagePickerController.popoverPresentationController
    // Display a popover from the UIBarButtonItem as an anchor.
//    presentationController?.barButtonItem = button
//    presentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
    
    if sourceType == UIImagePickerController.SourceType.camera {
      /*
       The user tapped the camera button in the app's interface which
       specifies the device’s built-in camera as the source for the image
       picker controller.
       */
      
      /*
       Hide the default controls.
       This sample provides its own custom controls for still image
       capture in an overlay view.
       */
      imagePickerController.showsCameraControls = true
      
      /*
       Apply the overlay view. This view contains a toolbar with custom
       controls for capturing still images in various ways.
       */
//      overlayView?.frame = (imagePickerController.cameraOverlayView?.frame)!
//      imagePickerController.cameraOverlayView = overlayView
    }
    
    /*
     The creation and configuration of the camera or media browser
     interface is now complete.
     
     Asynchronously present the picker interface using the
     `present(_:animated:completion:)` method.
     */
    present(imagePickerController, animated: true, completion: {
      // The block to execute after the presentation finishes.
    })
  }
  
}

struct MenuItems {
  let clickableModels: [MenuModel]
  let imagesModels: [ImageModel]
}

private var collection: PHFetchResult<PHAssetCollection> {
  let options = PHFetchOptions()
  options.predicate = NSPredicate(format: "title = %@", folderName)
  return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
}

private let folderName = "Temp"

