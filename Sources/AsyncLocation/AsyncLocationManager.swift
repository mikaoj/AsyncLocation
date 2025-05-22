// MIT License
//
// Copyright (c) 2025 Joakim Gyllström <joakim@backslashed.se>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
@preconcurrency import CoreLocation

/// An asynchronous wrapper around `CLLocationManager` for modern Swift concurrency.
/// Handles location updates and authorization status using `async/await`.
@MainActor
public final class AsyncLocationManager: NSObject {
    private let locationManager: CLLocationManager
    
    // Continuations
    private var locationContinuations: [CheckedContinuation<[CLLocation], Never>] = []
    private var authorizationContinuations: [CheckedContinuation<CLAuthorizationStatus, Never>] = []
    
    // MARK: Init
    
    /// Creates an instance of `AsyncLocationManager`.
    /// - Parameters:
    ///   - activityType: The type of user activity associated with the location updates.
    ///   - desiredAccuracy: The desired accuracy of the location data.
    public init(
        activityType: CLActivityType = .other,
        desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    ) {
        self.locationManager = CLLocationManager()
        self.locationManager.activityType = activityType
        self.locationManager.desiredAccuracy = desiredAccuracy
        super.init()
        self.locationManager.delegate = self
    }
}

// MARK: Public API
extension AsyncLocationManager {
    /// The current authorization status of the app for location services.
    public var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    /// Requests a one-time location update using `requestLocation()`.
    /// This is generally slower than starting updates but may be more accurate.
    ///
    /// - Returns: An array of `CLLocation` objects returned by the location manager.
    public func requestLocation() async -> [CLLocation] {
        return await withCheckedContinuation { continuation in
            locationContinuations.append(continuation)
            locationManager.requestLocation()
        }
    }
    
    /// Starts continuous location updates and returns the first result received.
    /// This method may return results faster than `requestLocation()` but with less filtering.
    ///
    /// - Returns: An array of `CLLocation` objects.
    public func startUpdatingLocation() async -> [CLLocation] {
        return await withCheckedContinuation { continuation in
            locationContinuations.append(continuation)
            locationManager.startUpdatingLocation()
        }
    }
    
    /// Requests "Always" authorization for location access.
    /// Will only prompt the user if the status is `.notDetermined`.
    ///
    /// - Returns: The `CLAuthorizationStatus`.
    public func requestAlwaysAuthorization() async -> CLAuthorizationStatus {
        guard locationManager.authorizationStatus == .notDetermined else {
            return locationManager.authorizationStatus
        }
        
        return await withCheckedContinuation { continuation in
            authorizationContinuations.append(continuation)
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    /// Requests "When In Use" authorization for location access.
    /// Will only prompt the user if the status is `.notDetermined`.
    ///
    /// - Returns: The `CLAuthorizationStatus`.
    public func requestWhenInUseAuthorization() async -> CLAuthorizationStatus {
        guard locationManager.authorizationStatus == .notDetermined else {
            return locationManager.authorizationStatus
        }
        
        return await withCheckedContinuation { continuation in
            authorizationContinuations.append(continuation)
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: Private helpers
extension AsyncLocationManager {
    private func notifyLocationContinuations(_ locations: [CLLocation]) {
        locationContinuations.forEach { $0.resume(returning: locations) }
        locationContinuations.removeAll()
    }
    
    private func notifyAuthorizationContinuations(_ status: CLAuthorizationStatus) {
        authorizationContinuations.forEach { $0.resume(returning: status) }
        authorizationContinuations.removeAll()
    }
}

// MARK: CLLocationManagerDelegate
extension AsyncLocationManager: @preconcurrency CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        notifyLocationContinuations(locations)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        manager.stopUpdatingLocation()
        
        // Return the last known location if available
        notifyLocationContinuations([manager.location].compactMap { $0 })
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        notifyAuthorizationContinuations(manager.authorizationStatus)
    }
}
