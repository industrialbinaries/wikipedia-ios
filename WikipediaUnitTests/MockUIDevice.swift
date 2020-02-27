import UIKit

/// A UIDevice subclass allowing mocking in tests.
final class MockUIDevice: UIDevice {

    private var _orientation: UIDeviceOrientation
    override var orientation: UIDeviceOrientation {
        return _orientation
    }

    var deviceOrientationObserversCount: Int = 0
    override func beginGeneratingDeviceOrientationNotifications() {
        super.beginGeneratingDeviceOrientationNotifications()
        deviceOrientationObserversCount += 1
    }

    override func endGeneratingDeviceOrientationNotifications() {
        super.endGeneratingDeviceOrientationNotifications()
        deviceOrientationObserversCount -= 1
    }

    init(orientation: UIDeviceOrientation) {
        _orientation = orientation
    }

    /// Simulate change device orientation, update `orientation` property and post `UIDevice.orientationDidChangeNotificaion`.
    /// - Parameter orientation: New orientation value.
    func simulateUpdate(orientation: UIDeviceOrientation) {
        _orientation = orientation

        NotificationCenter.default.post(
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
}
