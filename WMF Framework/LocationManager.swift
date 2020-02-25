import UIKit
import CoreLocation

public struct LocationManagerAccuracy {
    let accuracy: CLLocationAccuracy
    let filter: CLLocationDistance
}

extension LocationManagerAccuracy {
    /// Location manager with filter `1` accuracy `best`
    public static let fine = LocationManagerAccuracy(accuracy: kCLLocationAccuracyBest, filter: 1)
    /// Location manager with filter `1000` accuracy `kilometer`
    public static let coarse = LocationManagerAccuracy(accuracy: kCLLocationAccuracyKilometer, filter: 1000)
}

final public class LocationManager: NSObject, LocationManagerProtocol {

    /// Last know location
    public var location: CLLocation? { fatalError() }
    /// Last know heading
    public var heading: CLHeading? { fatalError() }
    /// Return `true` in case when monitoring location, in other case return `false`
    public private(set) var isUpdating = false
    /// Delegate for update location manager
    public var delegate: LocationManagerDelegate?
    /// Get current locationManager permission state
    public var autorizationStatus: CLAuthorizationStatus { fatalError() }
    // TODO: Temporary helper for support ObjC codebase, leter can call directly `autorizationStatus.authorized`
    /// Return `true` if user is aurthorized or authorized always
    public var isAuthorized: Bool { fatalError() }

    /// Start monitoring location and heading updates.
    public func startMonitoringLocation() { }

    /// Stop monitoring location and heading updates.
    public func stopMonitoringLocation() { }

    /// Create  new istance of locationManager with `LocationManagerAccuracy`
    /// - Parameter type: Accuracy for new instance of LocationManager
    public init(
        locationManager: CLLocationManager = .init(),
        device: UIDevice = .current,
        type: LocationManagerAccuracy = .fine
    ) { }
}
