//
//  CoreLocationService.swift
//  ModulosSwiftUI
//
//  Created by Salvador Lopez on 11/11/26.
//

import Foundation
import CoreLocation

// CoreLocation es el framework; CLLocation representa una medición (coordenada,
// precisión y fecha), y CLLocationManager administra permisos y solicitudes.
// LocalizedError permite mostrar una descripción mediante localizedDescription.
// Algunos casos declarados aquí todavía no se utilizan en este servicio.
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

/// Contrato que aísla a los consumidores de los detalles de Core Location.
/// El resultado llega después: @escaping permite conservar el closure hasta
/// recibir una ubicación o un error mediante el delegado.
@MainActor
protocol LocationService {
    func solicitarUbicacion(completion: @escaping (Result<CLLocation, Error>) -> Void)
}

// NSObject permite participar en el protocolo de delegado de Core Location.
// MainActor mantiene este servicio en el actor de la interfaz; el manager se
// crea en el hilo principal y entrega sus callbacks usando su run loop.
@MainActor
final class CoreLocationService: NSObject, LocationService{
    
    private let manager = CLLocationManager()
    
    // Único callback pendiente. Una nueva petición reemplaza el anterior;
    // esta implementación no mantiene una cola de solicitudes simultáneas.
    private var completion: ((Result<CLLocation,Error>)->Void)?
    
    override init(){
        super.init()
        // El delegado recibe eventos asíncronos de permisos, ubicación y errores.
        manager.delegate = self
    }
    
    
    func solicitarUbicacion(completion: @escaping (Result<CLLocation, any Error>) -> Void) {
        self.completion = completion
        
        //manager.requestWhenInUseAuthorization()
        //manager.requestLocation()
        
        // El permiso y la obtención de coordenadas son pasos distintos.
        // requestWhenInUseAuthorization requiere la descripción de uso
        // NSLocationWhenInUseUsageDescription en la configuración de la app.
        // Si aún no hay permiso, el flujo continúa en el callback de autorización.
        // requestLocation pide una medición puntual; no inicia seguimiento continuo.
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
        
        // El arreglo está ordenado cronológicamente: last es la medición más reciente.
        guard let ubicacion = locations.last else {
            return
        }
        
        // Result transporta éxito o error al ViewModel. Liberar el callback después
        // de responder evita conservarlo para futuras notificaciones del manager.
        completion?(.success(ubicacion))
        completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        completion?(.failure(error))
        completion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Este evento también puede llegar al crear el manager. Solo solicitamos
        // una posición si hay una acción del usuario esperando respuesta.
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
