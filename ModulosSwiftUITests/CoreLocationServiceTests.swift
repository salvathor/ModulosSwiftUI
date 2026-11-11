import CoreLocation
import Testing
@testable import ModulosSwiftUI

@MainActor
struct CoreLocationServiceTests {
    @Test("Entrega la última ubicación y ejecuta el callback una sola vez")
    func entregaUltimaUbicacionUnaSolaVez() throws {
        let service = CoreLocationService()
        let manager = CLLocationManager()
        let primeraUbicacion = CLLocation(latitude: 19.4326, longitude: -99.1332)
        let ultimaUbicacion = CLLocation(latitude: 20.6597, longitude: -103.3496)
        var resultado: Result<CLLocation, Error>?
        var numeroDeRespuestas = 0

        service.solicitarUbicacion {
            resultado = $0
            numeroDeRespuestas += 1
        }

        // Se simula la respuesta en el mismo turno del actor principal,
        // antes de que el sistema pueda entregar una respuesta asíncrona.
        service.locationManager(
            manager,
            didUpdateLocations: [primeraUbicacion, ultimaUbicacion]
        )

        let respuesta = try #require(resultado)
        let ubicacion = try respuesta.get()
        #expect(ubicacion.coordinate.latitude == ultimaUbicacion.coordinate.latitude)
        #expect(ubicacion.coordinate.longitude == ultimaUbicacion.coordinate.longitude)
        #expect(numeroDeRespuestas == 1)

        service.locationManager(manager, didUpdateLocations: [primeraUbicacion])
        #expect(numeroDeRespuestas == 1)
    }
}
