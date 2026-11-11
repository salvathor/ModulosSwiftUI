//
//  CoreLocationService.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 11/11/26.
//

import Foundation
import CoreLocation

@MainActor
protocol LocationService {
    func solicitarUbicacion(completion: @escaping (Result<CLLocation, Error>) -> Void)
}

@MainActor
final class CoreLocationService: NSObject, LocationService{
    
    private let manager = CLLocationManager()
    
    private var completion: ((Result<CLLocation,Error>)->Void)?
    
    override init(){
        super.init()
        manager.delegate = self
    }
    
    
    func solicitarUbicacion(completion: @escaping (Result<CLLocation, any Error>) -> Void) {
        self.completion = completion
        
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
}

extension CoreLocationService:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard var ubicacion = locations.last else {
            return
        }
        
        completion?(.success(ubicacion))
        completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        completion?(.failure(error))
        completion = nil
    }
    
}
