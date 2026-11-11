//
//  CoreLocationService.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 11/11/26.
//

import Foundation
import CoreLocation

enum LocationError: LocalizedError{
    case serviciosDesactivados
    case permisoDenegado
    case solicitudEnCurso
    case estadoDesconocido
    case sistema(Error)
    
    var errorDescription: String? {
        switch self {
        case .serviciosDesactivados: return "Los servicios de ubicación estan desactivados."
        case .permisoDenegado: return "No hay permisos para obtener la ubicación."
        case .solicitudEnCurso: return "Ya existe una solicitud de ubicación en curso."
        case .estadoDesconocido: return "Estado de autorización desconocido."
        case .sistema(let error): return error.localizedDescription
        }
    }
}

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
        
        //manager.requestWhenInUseAuthorization()
        //manager.requestLocation()
        
        // Validar permisos del usuario
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization() // Preguntar localizacion
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation() // Solicitar localizacion
        case .denied, .restricted:
            completion(.failure(LocationError.permisoDenegado))
            self.completion = nil
        @unknown default:
            completion(.failure(LocationError.estadoDesconocido))
            self.completion = nil
        }
        
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard completion != nil else {
            return
        }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            completion?(.failure(LocationError.permisoDenegado))
            completion = nil
        default:
            break
        }
    }
    
}
