# ModulosSwiftUI

Aplicación de ejemplo para iOS desarrollada con SwiftUI que muestra cómo organizar una app por funcionalidades utilizando MVVM, inyección de dependencias y fábricas de vistas. Permite consultar usuarios, revisar sus datos y visualizar su ubicación en un mapa, además de obtener la posición del dispositivo y calcular una ruta en automóvil hacia el usuario seleccionado.

## Objetivo

Ilustrar la separación de responsabilidades entre interfaz, lógica de presentación, acceso a datos y servicios del dispositivo. Los módulos son agrupaciones lógicas dentro del mismo target de la aplicación, no paquetes independientes.

## Funcionalidades

- Listado de usuarios ordenado por nombre.
- Pantalla de detalle con imagen remota, nombre, correo y teléfono.
- Mapa con la coordenada almacenada del usuario seleccionado.
- Solicitud de permiso de ubicación y obtención puntual de la posición del dispositivo.
- Cálculo de distancia geográfica entre el dispositivo y el destino.
- Cálculo y visualización de una ruta en automóvil, con distancia por carretera y tiempo estimado.
- Indicadores de carga y mensajes de error para la solicitud de ubicación.

El flujo de navegación es **Usuarios → Detalle del usuario → Ubicación**.

## Arquitectura

El proyecto utiliza **MVVM (Model–View–ViewModel)**:

- **Model:** `Usuario` contiene la identidad, los datos de contacto, la URL de imagen y las coordenadas.
- **View:** las vistas SwiftUI presentan el estado y envían las acciones al ViewModel.
- **ViewModel:** consulta los datos y coordina las operaciones de ubicación y rutas.

`UsuarioRepository` define el contrato de consulta de usuarios y `MockUsuarioRepository` lo implementa con datos fijos en memoria. `LocationService` abstrae la solicitud de ubicación y `CoreLocationService` la implementa mediante `CLLocationManager` y su delegado.

`DIContainer` conserva el repositorio y el servicio de ubicación compartidos. Cada `Factory` construye su pantalla con las dependencias necesarias. `ModulosSwiftUIApp` conecta estas fábricas y establece el listado como pantalla inicial.

Actualmente, los ViewModels comunican cambios mediante `ObservableObject` y `@Published`, y las vistas los conservan con `@StateObject`. El servicio de ubicación entrega resultados mediante callbacks; el cálculo de rutas utiliza `async/await`.

## Organización del código

| Carpeta o archivo | Responsabilidad |
| --- | --- |
| `ModulosSwiftUI/App/` | Punto de entrada y contenedor de dependencias. |
| `ModulosSwiftUI/Usuarios/` | Vista, ViewModel y fábrica del listado. |
| `ModulosSwiftUI/Detalle_Usuarios/` | Vista, ViewModel y fábrica del detalle. |
| `ModulosSwiftUI/Ubicacion_Usuario/` | Vista, ViewModel y fábrica del mapa, distancias y rutas. |
| `ModulosSwiftUI/Repositories/Usuario.swift` | Modelo, protocolo del repositorio y datos de ejemplo. |
| `ModulosSwiftUI/Services/CoreLocationService.swift` | Permisos y solicitud de ubicación. |
| `ModulosSwiftUI/Assets.xcassets` | Recursos gráficos de la aplicación. |
| `ModulosSwiftUITests/` | Pruebas unitarias. |
| `ModulosSwiftUIUITests/` | Pruebas de interfaz. |

`ContentView.swift` conserva la vista inicial de plantilla; el flujo activo se construye desde `ModulosSwiftUIApp` mediante las fábricas.

## Tecnologías

| Tecnología | Uso en el proyecto |
| --- | --- |
| Swift | Lenguaje de implementación. |
| SwiftUI | Interfaz y navegación con `NavigationStack`. |
| Combine | Publicación y observación del estado de los ViewModels. |
| Core Location | Permisos, posición del dispositivo y distancia geográfica. |
| MapKit | Mapas, marcadores, trazado de rutas y estimación del recorrido. |
| Kingfisher | Presentación de imágenes remotas mediante `KFImage`. |
| Swift Testing | Prueba unitaria del servicio de ubicación. |

## Ejecución

1. Abre el proyecto en Xcode con una versión compatible con su configuración de compilación.
2. Espera a que Xcode resuelva la dependencia Kingfisher.
3. Selecciona el esquema `ModulosSwiftUI` y un simulador o dispositivo compatible con el deployment target configurado.
4. Si utilizas un dispositivo físico, configura el equipo de firma correspondiente.
5. Ejecuta la aplicación con **⌘R**.
6. Selecciona un usuario y abre su ubicación.
7. Pulsa **Obtener mi ubicacion** y concede el permiso para obtener la posición del dispositivo.
8. Pulsa **Calcular Ruta** para solicitar el recorrido hasta el destino.

La solicitud de permiso requiere la clave `NSLocationWhenInUseUsageDescription` en la configuración de la aplicación. Para probar la ubicación en el simulador, configura una posición simulada. Las imágenes remotas y la consulta de rutas necesitan conectividad.

## Datos y alcance

El repositorio incluye tres usuarios de ejemplo: Ana, Carlos y María. Sus coordenadas son datos fijos del registro; no representan posiciones obtenidas en tiempo real de otras personas.

La ubicación del dispositivo se obtiene bajo demanda, sin seguimiento continuo. La distancia geográfica se calcula entre dos coordenadas y es diferente de la distancia por carretera devuelta por MapKit. La disponibilidad de una ruta depende de los puntos elegidos y del servicio de rutas; algunos destinos de ejemplo pueden no tener conexión por carretera desde la posición del dispositivo.

La implementación actual utiliza datos en memoria y no incluye un backend, persistencia de usuarios ni operaciones para crear, editar o eliminar registros.

## Pruebas

El proyecto incluye los targets `ModulosSwiftUITests` y `ModulosSwiftUIUITests`. La prueba de `CoreLocationServiceTests` simula la recepción de ubicaciones y comprueba que se entregue la última medición y que el callback se ejecute una sola vez.

Para ejecutar las pruebas desde Xcode, utiliza **Product → Test** o **⌘U**.
