import XCTest
@testable import WMF

final class LocationManagerTests: XCTestCase {

    private var mockCLLocationManager: MockCLLocationManager!
    private var mockDevice: MockUIDevice!
    private var locationManager: WMFLocationManager!
    private var delegate: TestLocationManagerDelegate!

    override func setUp() {
        super.setUp()

        mockCLLocationManager = MockCLLocationManager()
        mockCLLocationManager.simulate(authorizationStatus: .authorizedAlways)

        mockDevice = MockUIDevice(orientation: .unknown)

        locationManager = WMFLocationManager(locationManager: mockCLLocationManager, device: mockDevice)

        delegate = TestLocationManagerDelegate()
        locationManager.delegate = delegate
    }

    // MARK: - WMFLocationManager tests

    func testFineLocationManager() {
        let locationManager = WMFLocationManager.fine()
        XCTAssertEqual(locationManager.locationManager.distanceFilter, 1)
        XCTAssertEqual(locationManager.locationManager.desiredAccuracy, kCLLocationAccuracyBest)
        XCTAssertEqual(locationManager.locationManager.activityType, .fitness)
    }

    func testCoarseLocationManager() {
        let locationManager = WMFLocationManager.coarse()
        XCTAssertEqual(locationManager.locationManager.distanceFilter, 1000)
        XCTAssertEqual(locationManager.locationManager.desiredAccuracy, kCLLocationAccuracyKilometer)
        XCTAssertEqual(locationManager.locationManager.activityType, .fitness)
    }

    func testStartMonitoring() {
        locationManager.startMonitoringLocation()
        XCTAssertEqual(locationManager.isUpdating, true)
        XCTAssertEqual(mockCLLocationManager.isUpdatingLocation, true)
        XCTAssertEqual(mockCLLocationManager.isUpdatingHeading, true)
    }

    func testStartLocationWithoutPermission() {
        mockCLLocationManager.simulate(authorizationStatus: .denied)
        locationManager.startMonitoringLocation()
        XCTAssertEqual(locationManager.isUpdating, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingLocation, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingHeading, false)


        mockCLLocationManager.simulate(authorizationStatus: .restricted)
        locationManager.startMonitoringLocation()
        XCTAssertEqual(locationManager.isUpdating, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingLocation, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingHeading, false)
    }

    func testStopMonitoring() {
        locationManager.startMonitoringLocation()
        locationManager.stopMonitoringLocation()
        XCTAssertEqual(locationManager.isUpdating, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingLocation, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingHeading, false)
    }

    // MARK: - Authorization

    func testStartMonitoringCalledWhenAuthorizationSuccessfull() {
        mockCLLocationManager.simulate(authorizationStatus: .notDetermined)
        locationManager.startMonitoringLocation()

        XCTAssertEqual(mockCLLocationManager.isRequestedForAuthorization, true)

        XCTAssertEqual(locationManager.isUpdating, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingLocation, false)
        XCTAssertEqual(mockCLLocationManager.isUpdatingHeading, false)

        // Simulate user allow location services to the app
        mockCLLocationManager.simulate(authorizationStatus: .authorizedAlways)

        XCTAssertEqual(locationManager.isUpdating, true)
        XCTAssertEqual(mockCLLocationManager.isUpdatingLocation, true)
        XCTAssertEqual(mockCLLocationManager.isUpdatingHeading, true)
    }

    func testAuthorizedStatus() {
        // Test authorizedAlways status
        mockCLLocationManager.simulate(authorizationStatus: .authorizedAlways)
        XCTAssertEqual(locationManager.isAuthorized(), true)
        XCTAssertEqual(locationManager.isAuthorizationNotDetermined(), false)
        XCTAssertEqual(locationManager.isAuthorizationDenied(), false)
        XCTAssertEqual(locationManager.isAuthorizationRestricted(), false)

        // Test notDetermined status
        mockCLLocationManager.simulate(authorizationStatus: .notDetermined)
        XCTAssertEqual(locationManager.isAuthorized(), false)
        XCTAssertEqual(locationManager.isAuthorizationNotDetermined(), true)
        XCTAssertEqual(locationManager.isAuthorizationDenied(), false)
        XCTAssertEqual(locationManager.isAuthorizationRestricted(), false)

        // Test denied status
        mockCLLocationManager.simulate(authorizationStatus: .denied)
        XCTAssertEqual(locationManager.isAuthorized(), false)
        XCTAssertEqual(locationManager.isAuthorizationNotDetermined(), false)
        XCTAssertEqual(locationManager.isAuthorizationDenied(), true)
        XCTAssertEqual(locationManager.isAuthorizationRestricted(), false)

        // Test restricted status
        mockCLLocationManager.simulate(authorizationStatus: .restricted)
        XCTAssertEqual(locationManager.isAuthorized(), false)
        XCTAssertEqual(locationManager.isAuthorizationNotDetermined(), false)
        XCTAssertEqual(locationManager.isAuthorizationDenied(), false)
        XCTAssertEqual(locationManager.isAuthorizationRestricted(), true)
    }

    // MARK: - WMFLocationManagerDelegate tests

    func testUpdateLocation() {
        locationManager.startMonitoringLocation()

        let location = CLLocation(latitude: 10, longitude: 20)
        mockCLLocationManager.simulateUpdate(location: location)
        XCTAssertEqual(locationManager.location, location) // Test new location on location manager
        XCTAssertEqual(delegate.location, location)  // Test new location on delegate
    }

    // When the location has already been fetched, a new instance of CLLocationManager contains the last known location in its location variable, even before startMonitoringLocation() has been called
    func testExistingLocationWithoutCallback() {
        let location = CLLocation(latitude: 10, longitude: 20)
        mockCLLocationManager.simulateUpdate(location: location)
        // startMonitoringLocation() not called
        let locationManager = WMFLocationManager(locationManager: mockCLLocationManager, device: mockDevice)
        XCTAssertEqual(locationManager.location, location)
    }

    func testUpdateHeading() {
        locationManager.startMonitoringLocation()

        let heading = MockCLHeading(headingAccuracy: 10)
        mockCLLocationManager.simulateUpdate(heading: heading)
        XCTAssertEqual(locationManager.heading, heading) // Test new heading on location manager
        XCTAssertEqual(delegate.heading, heading)  // Test new heading on delegate
    }

    // When the heading has already been fetched, a new instance of CLLocationManager contains the last known heading in its heading variable, even before startMonitoringLocation() has been called
    func testExistingHeadingWithoutCallback() {
        let heading = MockCLHeading(headingAccuracy: 10)
        mockCLLocationManager.simulateUpdate(heading: heading)
        XCTAssertEqual(locationManager.heading, heading) // Test last know heading on location manager
    }

    func testStopUpdating() {
        locationManager.startMonitoringLocation()
        // Setup value when monitoring
        let location1 = CLLocation(latitude: 10, longitude: 20)
        mockCLLocationManager.simulateUpdate(location: location1)
        let heading1 = MockCLHeading(headingAccuracy: 10)
        mockCLLocationManager.simulateUpdate(heading: heading1)

        locationManager.stopMonitoringLocation()
        // Update with new values after stop monitoring for location
        let location2 = CLLocation(latitude: 100, longitude: 200)
        mockCLLocationManager.simulateUpdate(location: location2)
        let heading2 = MockCLHeading(headingAccuracy: 100)
        mockCLLocationManager.simulateUpdate(heading: heading2)

        // Check the values are not updated
        XCTAssertEqual(locationManager.heading, heading1)
        XCTAssertEqual(delegate.heading, heading1)
        XCTAssertEqual(locationManager.location, location1)
        XCTAssertEqual(delegate.location, location1)

        // Check the error is not propagated
        let error = NSError(domain: "org.wikimedia.wikipedia.test", code: -1, userInfo: nil)
        mockCLLocationManager.simulate(error: error)
        XCTAssertNil(delegate.error)
    }

    func testReceiveError() {
        locationManager.startMonitoringLocation()

        let error = NSError(domain: "org.wikimedia.wikipedia.test", code: -1, userInfo: nil)
        mockCLLocationManager.simulate(error: error)
        XCTAssertEqual((delegate.error as NSError?), error)
    }

    func testChangeAuthorizedState() {
        mockCLLocationManager.simulate(authorizationStatus: .denied)
        XCTAssertEqual(delegate.authorized, false)

        mockCLLocationManager.simulate(authorizationStatus: .authorizedAlways)
        XCTAssertEqual(delegate.authorized, true)
    }

    // MARK: - Test heading

    func testUpdateDeviceHeading() {
        locationManager.startMonitoringLocation()

        mockDevice.simulateUpdate(orientation: .portrait)
        XCTAssertEqual(mockCLLocationManager.headingOrientation, .portrait)

        mockDevice.simulateUpdate(orientation: .landscapeLeft)
        XCTAssertEqual(mockCLLocationManager.headingOrientation, .landscapeLeft)

        // Device orientation updates should not be propagated when the monitoring is stopped.
        locationManager.stopMonitoringLocation()
        mockDevice.simulateUpdate(orientation: .portrait)
        XCTAssertNotEqual(mockCLLocationManager.headingOrientation, .portrait)
    }
}

/// Test implementation of `WMFLocationManagerDelegate`
private final class TestLocationManagerDelegate: NSObject, WMFLocationManagerDelegate {
    private(set) var heading: CLHeading?
    private(set) var location: CLLocation?
    private(set) var error: Error?
    private(set) var authorized: Bool?

    func locationManager(_ controller: WMFLocationManager, didReceiveError error: Error) {
        self.error = error
    }

    func locationManager(_ controller: WMFLocationManager, didUpdate heading: CLHeading) {
        self.heading = heading
    }

    func locationManager(_ controller: WMFLocationManager, didUpdate location: CLLocation) {
        self.location = location
    }

    func locationManager(_ controller: WMFLocationManager, didChangeEnabledState enabled: Bool) {
        self.authorized = enabled
    }
}
