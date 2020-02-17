//import Foundation
//import WMF.Swift
//
//protocol ImageGalleryViewControllerReferenceViewDelegate: class {
//    func referenceView(forImageController controller: ImageGalleryViewController)
//}
//
//protocol ExposedPhotoDataSource: NYTPhotosViewControllerDataSource {
//    var photos: [Any] { get set }
//}
//
//class ImageGalleryViewController: NYTPhotosViewController, Themeable {
//
//    weak var referenceViewDelegate: ImageGalleryViewControllerReferenceViewDelegate!
//    var indexOfCurrentImage: Int = 0
//    var currentImageView: UIImageView!
//    let photos: [NYTPhoto] = []
//    var dataSource: ExposedPhotoDataSource!
//
//    init(photos: [WMFPhoto], initialPhoto: WMFPhoto, delegate: NYTPhotosViewControllerDelegate?, theme: Theme, overlayViewTopBarHidden: Bool) {
//
//        super.init(photos: photos, initialPhoto: initialPhoto, delegate: delegate)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func apply(theme: Theme) {
//
//    }
//
//
//}
//
//class BasePhoto {
//
//    private (set) var _typedImageData: TypedImageData?
//    var typedImageData: TypedImageData? {
//        get {
//            let serialQueue = DispatchQueue(label: "com.wikipedia.serialQueue")
//            return serialQueue.sync { () -> TypedImageData? in
//                guard _typedImageData == nil, let URL = self.imageInfo?.canonicalFileURL else { return _typedImageData }
//                _typedImageData = ImageController.shared.data(withURL: URL)
//                return _typedImageData
//            }
//        }
//    }
//    var imageDataUTType: String? {
//        get {
//            return nil
//        }
//    }
//    var imageData: Data? {
//        get {
//            return nil
//        }
//    }
//
//    //used for metadaata
//    var imageInfo: MWKImageInfo?
//
//
//    func isGif() -> Bool {
//        return self.imageInfo?.canonicalFileURL?.absoluteString.lowercased().hasSuffix(".gif") ?? false
//    }
//
//}
//
//class POTDImageGalleryViewController: WMFImageGalleryViewController {
//
//}
