//
//  ImageGalleryViewController.swift
//  WikipediaUnitTests
//
//  Created by Jozef Matus on 17/02/2020.
//  Copyright © 2020 Wikimedia Foundation. All rights reserved.
//

import XCTest
@testable import Wikipedia

class ImageGalleryViewController: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let vc = WMFPOTDImageGalleryViewController(dates: [Date()], theme: theme, overlayViewTopBarHidden: false)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
