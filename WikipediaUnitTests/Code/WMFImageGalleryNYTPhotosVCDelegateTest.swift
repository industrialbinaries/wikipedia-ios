import XCTest
import Foundation
import NYTPhotoViewerCore
@testable import Wikipedia
@testable import WMF


class WMFImageGalleryNYTPhotosVCDelegateTest: XCTestCase {

    private var photoVC: WMFImageGalleryViewController_Test!
    private let photos: [NYTPhoto] = [Photo(), Photo(longDescription: false)]
    
    override func setUp() {
        photoVC = WMFImageGalleryViewController_Test(photos: photos as? [WMFPhoto], initialPhoto: photos[0] as? WMFPhoto, delegate: nil, theme: Theme.dark, overlayViewTopBarHidden: false)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSetOverlayViewTopBarHidden() {
        photoVC.setOverlayViewTopBarHidden(true)
        XCTAssertEqual(photoVC.overlayView?.rightBarButtonItem, nil)
        XCTAssertEqual(photoVC.overlayView?.leftBarButtonItem, nil)
        XCTAssertEqual(photoVC.overlayView?.topCoverBackgroundColor, UIColor.clear)
        photoVC.setOverlayViewTopBarHidden(false)
        XCTAssertNotNil(photoVC.overlayView?.rightBarButtonItem)
        XCTAssertNotNil(photoVC.overlayView?.leftBarButtonItem)
    }

    func testOwnerTap() {

        guard let caption = photoVC.delegate?.photosViewController?(photoVC, captionViewFor: photos[0]) as? WMFImageGalleryDetailOverlayView else {
            return assertionFailure("Invalid caption")
        }
        
        _ = expectation(forNotification: .WMFNavigateToActivity,
         object: nil,
        handler: nil)
        caption.ownerTapCallback()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testInfoTap() {
        guard let caption = photoVC.delegate?.photosViewController?(photoVC, captionViewFor: photos[0]) as? WMFImageGalleryDetailOverlayView else {
            return assertionFailure("Invalid caption")
        }
        
        _ = expectation(forNotification: .WMFNavigateToActivity,
         object: nil,
        handler: nil)
        caption.infoTapCallback()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // If description is long enough, description section should expand and change icon. Expansion part should be tested in WMFImageGalleryDetailOverlayView, here we just check if closure was called
    func testLongDescriptionTap() throws {
        guard let caption = photoVC.delegate?.photosViewController?(photoVC, captionViewFor: photos[0]) as? WMFImageGalleryDetailOverlayView else {
            return assertionFailure("Invalid caption")
        }
        caption.descriptionTapCallback()
        let gradietnView = caption.subviews.filter { $0 is WMFImageGalleryBottomGradientView }.first
        let image = try XCTUnwrap((gradietnView?.subviews.filter { $0 is UIImageView }.first as? UIImageView)?.image)
        let output = image.pngData() == UIImage(named: "gallery-line-bent")!.pngData()
        XCTAssert(output)
    }
    
    func testShortDescriptionTap() throws {
        guard let caption = photoVC.delegate?.photosViewController?(photoVC, captionViewFor: photos[1]) as? WMFImageGalleryDetailOverlayView else {
            return assertionFailure("Invalid caption")
        }
        caption.descriptionTapCallback()
        let gradietnView = caption.subviews.filter { $0 is WMFImageGalleryBottomGradientView }.first
        let image = try XCTUnwrap((gradietnView?.subviews.filter { $0 is UIImageView }.first as? UIImageView)?.image)
        let output = image.pngData() == UIImage(named: "gallery-line")!.pngData()
        XCTAssert(output)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    class Photo: NSObject, WMFPhoto {
        
        let longDescription: Bool
        
        init(longDescription: Bool = true) {
            self.longDescription = longDescription
        }
        
        func bestImageURL() -> URL? {
            nil
        }
        
        func bestImageInfo() -> MWKImageInfo? {
            let canonicalFileURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/0/01/Daubeny%27s_water_lily_at_BBG_%2850824%29.jpg")
            let imageDescription = longDescription ? "Picture of the day for Feb 19, 2020\n\nDaubeny's water lily ( Nymphaea \u{00d7} daubenyana ), Brooklyn Botanic Garden in January 2019 Picture of the day for Feb 19, 2020\n\nDaubeny's water lily ( Nymphaea \u{00d7} daubenyana ), Brooklyn Botanic Garden in January 2019 Picture of the day for Feb 19, 2020\n\nDaubeny's water lily ( Nymphaea \u{00d7} daubenyana ), Brooklyn Botanic Garden in January 2019 Picture of the day for Feb 19, 2020\n\nDaubeny's water lily ( Nymphaea \u{00d7} daubenyana ), Brooklyn Botanic Garden in January 2019 Picture of the day for Feb 19, 2020\n\nDaubeny's water lily ( Nymphaea \u{00d7} daubenyana ), Brooklyn Botanic Garden in January 2019" : "Picture of the day for Feb 19, 2020"
            let license = MWKLicense(code: "\"cc-by-sa-4.0\";\n", shortDescription: "\"CC BY-SA 4.0\";\n} cc-by-sa-4.0 CC BY-SA 4.0" , url: URL(string: "https://creativecommons.org/licenses/by-sa/4.0"))
            let filePageURL = URL(string: "https://commons.wikimedia.org/wiki/File:Daubeny%27s_water_lily_at_BBG_(50824).jpg")
            let info = MWKImageInfo(canonicalPageTitle: "File:Daubeny's water lily at BBG (50824).jpg", canonicalFileURL: canonicalFileURL, imageDescription: imageDescription, imageDescriptionIsRTL: false, license: license, filePageURL: filePageURL, imageThumbURL: nil, owner: "Rhododendrites", imageSize: CGSize(width: 4028, height: 3346), thumbSize: CGSize(width: 640, height: 532))
            return info
        }
        
        var image: UIImage?
        
        var imageData: Data?
        
        var imageDataUTType: String?
        
        var placeholderImage: UIImage?
        
        var attributedCaptionTitle: NSAttributedString?
        
        var attributedCaptionSummary: NSAttributedString?
        
        var attributedCaptionCredit: NSAttributedString?
    }

}

func ==(lhs: UIImage, rhs: UIImage) -> Bool {
    if let lhsData = lhs.pngData(), let rhsData = rhs.pngData() {
        return lhsData == rhsData
    }
    return false
}

class WMFImageGalleryViewController_Test: WMFImageGalleryViewController {
    
}
