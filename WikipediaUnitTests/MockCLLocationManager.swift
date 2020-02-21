import Foundation
import CoreLocation

/// A CLLocationManager subclass allowing mocking in tests.
final class MockCLLocationManager: CLLocationManager {

    private var _heading: CLHeading?
    override var heading: CLHeading? { _heading }

    private var _location: CLLocation?
    override var location: CLLocation? { _location }

    override class func locationServicesEnabled() -> Bool { true }

    private static var _authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return _authorizationStatus
    }

    override func startUpdatingLocation() {
        isUpdatingLocation = true
    }

    override func stopUpdatingLocation() {
        isUpdatingLocation = false
    }

    override func startUpdatingHeading() {
        isUpdatingHeading = true
    }

    override func stopUpdatingHeading() {
        isUpdatingHeading = false
    }

    // Override methods which can required user interaction - f.e. permission

    override func requestAlwaysAuthorization() { }

    override func requestWhenInUseAuthorization() {
        isRequestedForAuthorization = true
    }

    override func startMonitoringSignificantLocationChanges() { }

    override func stopMonitoringSignificantLocationChanges() { }

    // MARK: - Test properties

    var isUpdatingLocation: Bool = false
    var isUpdatingHeading: Bool = false
    var isRequestedForAuthorization: Bool?

    /// Simulate receive new location, update location property and location delegate
    /// - Parameter location: New location
    func simulateUpdate(location: CLLocation) {
        _location = location
        delegate?.locationManager?(self, didUpdateLocations: [location])
    }

    /// Simulate receive new heading, update heading property and  heading delegate
    /// - Parameter heading: New heading
    func simulateUpdate(heading: CLHeading) {
        _heading = heading
        delegate?.locationManager?(self, didUpdateHeading: heading)
    }

    /// Simulate receive location error
    /// - Parameter error: New error
    func simulate(error: Error) {
        delegate?.locationManager?(self, didFailWithError: error)
    }

    /// Update authorization status to new value, this value will be rewrite in all `CLLocationManagerMock`
    /// - Parameter authorizationStatus: New authorization status
    func simulate(authorizationStatus: CLAuthorizationStatus) {
        MockCLLocationManager._authorizationStatus = authorizationStatus
        delegate?.locationManager?(self, didChangeAuthorization: authorizationStatus)
    }   
}
