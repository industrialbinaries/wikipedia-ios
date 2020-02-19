//
//  WMFImageGalleryNYTPhotosVCDelegateTest.swift
//  WikipediaUnitTests
//
//  Created by Jozef Matus on 18/02/2020.
//  Copyright © 2020 Wikimedia Foundation. All rights reserved.
//

import XCTest
import Foundation
import NYTPhotoViewerCore
@testable import Wikipedia
@testable import WMF


class WMFImageGalleryNYTPhotosVCDelegateTest: XCTestCase {


    
    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPhotosViewController() {
        let delegate = WMFImageGalleryNYTPhotosVCDelegate()
        let vc = WMFPOTDImageGalleryViewController(dates: [Date()], theme: Theme.dark, overlayViewTopBarHidden: false)
        let photo = Photo()

        guard let caption = delegate.photosViewController(vc, captionViewFor: photo) as? WMFImageGalleryDetailOverlayView else {
            return assertionFailure("Invalid caption")
        }
        
        _ = expectation(forNotification: .WMFNavigateToActivity,
         object: nil,
        handler: nil)
        caption.ownerTapCallback()
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    class Photo: NSObject, WMFPhoto {
        func bestImageURL() -> URL? {
            nil
        }
        
        func bestImageInfo() -> MWKImageInfo? {
            let canonicalFileURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/0/01/Daubeny%27s_water_lily_at_BBG_%2850824%29.jpg")
            let imageSescription = "Picture of the day for Feb 19, 2020\n\nDaubeny's water lily ( Nymphaea \u{00d7} daubenyana ), Brooklyn Botanic Garden in January 2019"
            let license = MWKLicense(code: "\"cc-by-sa-4.0\";\n", shortDescription: "\"CC BY-SA 4.0\";\n} cc-by-sa-4.0 CC BY-SA 4.0" , url: URL(string: "https://creativecommons.org/licenses/by-sa/4.0"))
            let filePageURL = URL(string: "https://commons.wikimedia.org/wiki/File:Daubeny%27s_water_lily_at_BBG_(50824).jpg")
            let info = MWKImageInfo(canonicalPageTitle: "File:Daubeny's water lily at BBG (50824).jpg", canonicalFileURL: canonicalFileURL, imageDescription: imageSescription, imageDescriptionIsRTL: false, license: license, filePageURL: filePageURL, imageThumbURL: nil, owner: "Rhododendrites", imageSize: CGSize(width: 4028, height: 3346), thumbSize: CGSize(width: 640, height: 532))
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
