import UIKit
import CoreLocation

public struct LocationManagerConfiguration {
    let accuracy: CLLocationAccuracy
    let filter: CLLocationDistance
    var activityType: CLActivityType = .fitness
}

extension LocationManagerConfiguration {
    /// Location manager with filter `1` accuracy `best` and  `fitness` activity type
    public static let fine = LocationManagerConfiguration(accuracy: kCLLocationAccuracyBest, filter: 1)
    /// Location manager with filter `1000` accuracy `kilometer` and  `fitness` activity type
    public static let coarse = LocationManagerConfiguration(accuracy: kCLLocationAccuracyKilometer, filter: 1000)
}

final public class LocationManager: NSObject, LocationManagerProtocol {

    /// Last know location
    public private(set) lazy var location: CLLocation? = self.locationManager.location
    /// Last know heading
    public private(set) lazy var heading: CLHeading? = self.locationManager.heading
    /// Return `true` in case when monitoring location, in other case return `false`
    public private(set) var isUpdating = false
    /// Delegate for update location manager
    public var delegate: LocationManagerDelegate?
    /// Get current locationManager permission state
    public var autorizationStatus: CLAuthorizationStatus { type(of: locationManager).authorizationStatus() }
    // TODO: Temporary helper for support ObjC codebase, leter can call directly `autorizationStatus.authorized`
    /// Return `true` if user is aurthorized or authorized always
    public var isAuthorized: Bool { autorizationStatus.isAuthorized }

    /// Start monitoring location and heading updates.
    public func startMonitoringLocation() {
        guard isAuthorized else {
            if autorizationStatus == .notDetermined {
                authorize(succcess: startMonitoringLocation)
            }
            return
        }

        locationManager.startUpdatingLocation()
        startUpdatingHeading()
        isUpdating = true
    }

    /// Stop monitoring location and heading updates.
    public func stopMonitoringLocation() {
        locationManager.stopUpdatingLocation()
        stopUpdatingHeading()
        isUpdating = false
    }

    /// Create  new istance of locationManager with `LocationManagerAccuracy`
    /// - Parameter type: Accuracy for new instance of LocationManager
    public init(
        locationManager: CLLocationManager = .init(),
        device: UIDevice = .current,
        type: LocationManagerConfiguration = .fine
    ) {
        locationManager.distanceFilter = type.filter
        locationManager.desiredAccuracy = type.accuracy
        locationManager.activityType = type.activityType
        self.locationManager = locationManager
        self.device = device
        super.init()
        locationManager.delegate = self
    }

    deinit {
        stopMonitoringLocation()
    }

    // MARK: - Private

    private let locationManager: CLLocationManager
    private let device: UIDevice

    // MARK: - Authorization

    /// Success authorized completion block, call when `authorizationStatus` change to `authorizedAlways` or `authorizedWhenInUse`
    private var authrizedCompletion: (() -> Void)?

    private func authorize(succcess: (() -> Void)? = nil) {
        locationManager.requestWhenInUseAuthorization()
        authrizedCompletion = succcess
    }

    // MARK: - Heading

    /// Token for update device orientation notification `UIDevice.orientationDidChangeNotification`
    private var orientationObserver: NSObjectProtocol?

    private func startUpdatingHeading() {
        guard !isUpdating else { return }
        device.beginGeneratingDeviceOrientationNotifications()
        locationManager.headingOrientation = device.orientation.clOrientation
        locationManager.startUpdatingHeading()

        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.locationManager.headingOrientation = self.device.orientation.clOrientation
        }
    }

    private func stopUpdatingHeading() {
        guard isUpdating else { return }
        device.endGeneratingDeviceOrientationNotifications()
        locationManager.stopUpdatingHeading()

        guard let observer = orientationObserver else { return }
        NotificationCenter.default.removeObserver(observer)
    }

}

// MARK: - LocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isUpdating, let location = locations.last else { return }

        self.location = location
        delegate?.locationManager?(self, didUpdate: location)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard isUpdating else { return }

        self.heading = newHeading
        delegate?.locationManager?(self, didUpdate: newHeading)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard isUpdating else { return }

        delegate?.locationManager?(self, didReceive: error)
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager?(self, didUpdateAuthorized: status.isAuthorized)

        guard status.isAuthorized else {
            return
        }

        authrizedCompletion?()
        authrizedCompletion = nil
    }
}

private extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        self == .authorizedAlways || self == .authorizedWhenInUse
    }
}

private extension UIDeviceOrientation {
    var clOrientation: CLDeviceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .faceUp:
            return .faceUp
        case .faceDown:
            return .faceDown
        default:
            return .unknown
        }
    }
}
