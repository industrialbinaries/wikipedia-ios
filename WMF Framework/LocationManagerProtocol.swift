import CoreLocation

@objc public protocol LocationManagerProtocol {
    /// Last know location
    var location: CLLocation? { get }
    /// Last know heading
    var heading: CLHeading? { get }
    /// Return `true` in case when monitoring location, in other case return `false`
    var isUpdating: Bool { get }
    /// Delegate for update location manager
    var delegate: LocationManagerDelegate? { get set }
    /// Get current locationManager permission state
    var autorizationStatus: CLAuthorizationStatus { get }
    /// Return `true` if user is aurthorized or authorized always
    var isAuthorized: Bool { get }

    /// Start monitoring location and heading updates.
    func startMonitoringLocation()
    /// Stop monitoring location and heading updates.
    func stopMonitoringLocation()
}

// MARK: - LocationManagerDelegate

@objc public protocol LocationManagerDelegate: class {
    @objc(locationManager:didUpdateLocation:) optional
    func locationManager(_ locationManager: LocationManagerProtocol, didUpdate location: CLLocation)
    @objc(locationManager:didUpdateHeading:) optional
    func locationManager(_ locationManager: LocationManagerProtocol, didUpdate heading: CLHeading)
    @objc(locationManager:didReceiveError:) optional
    func locationManager(_ locationManager: LocationManagerProtocol, didReceive error: Error)
    @objc(locationManager:didUpdateAuthorizedState:) optional
    func locationManager(_ locationManager: LocationManagerProtocol, didUpdateAuthorized authorized: Bool)
}
