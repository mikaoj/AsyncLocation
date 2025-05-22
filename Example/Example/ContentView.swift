//
//  ContentView.swift
//  Example
//
//  Created by Joakim Gyllström on 2025-05-22.
//

import SwiftUI
import CoreLocation
import AsyncLocation

struct ContentView: View {
    @State private var authorization = AsyncLocationManager.shared.authorizationStatus
    @State private var requestLocation: CLLocation?
    @State private var updateLocation: CLLocation?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button("Request authorization") {
                Task {
                    authorization = await AsyncLocationManager.shared.requestWhenInUseAuthorization()
                }
            }
            Button("Request location") {
                Task {
                    requestLocation = await AsyncLocationManager.shared.requestLocation().first
                }
            }
            Button("Update location") {
                Task {
                    updateLocation = await AsyncLocationManager.shared.startUpdatingLocation().first
                }
            }
            
            Text("Authorization: \(String(describing: authorization))")
            Text("Request: \(String(describing: requestLocation?.coordinate))")
            Text("Update: \(String(describing: updateLocation?.coordinate))")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

extension AsyncLocationManager {
    static let shared = AsyncLocationManager()
}

extension CLAuthorizationStatus: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}
