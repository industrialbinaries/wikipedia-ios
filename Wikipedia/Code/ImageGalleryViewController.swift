import Foundation
import WMF.Swift

protocol ImageGalleryViewControllerReferenceViewDelegate: class {
    func referenceView(forImageController controller: ImageGalleryViewController)
}

protocol ExposedPhotoDataSource: NYTPhotosViewControllerDataSource {
    var photos: []
}

class ImageGalleryViewController: NYTPhotosViewController, Themeable {
    
    weak var referenceViewDelegate: ImageGalleryViewControllerReferenceViewDelegate!
    var indexOfCurrentImage: Int
    var currentImageView: UIImageView
    let photos: [NYTPhoto]
    var dataSource:
    
    init(photos: [WMFPhoto], initialPhoto: WMFPhoto, delegate: NYTPhotosViewControllerDelegate?, theme: Theme, overlayViewTopBarHidden: Bool) {
        
        super.init(photos: photos, initialPhoto: initialPhoto, delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(theme: Theme) {
        
    }
    
    
}

class POTDImageGalleryViewController: WMFImageGalleryViewController {
    
}
