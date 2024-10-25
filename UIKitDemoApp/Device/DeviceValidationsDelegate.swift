import Foundation
import UIKit
import CallKit

public protocol DeviceValidationsDelegate: AnyObject {
    /**
     Esta función se llama justo después de que el usuario ha tomado un screen shot dentro de tu aplicación.
     
     - Parameters:
        - controller: `UIViewController` en el que se hizo el screen shot.
        - canUserTakeScreenShots: `Bool` que indica si estaba activo el bloqueo de screen shots al momento de la captura.
     */
    func didTakeScreenShot(at controller: UIViewController?, canUserTakeScreenShots: Bool)
    /**
     Esta función se llama al iniciar el monitoreo y cuando la aplicación pasa de estar inactiva a estar activa para notificarte si el usuario está grabando pantalla al abrir la app o comienza a grabar pantalla con la aplicación abierta.
     
     - Parameters:
        - isCaptured: `Bool` que indica si se está grabando la pantalla.
        - controller: `UIViewController` donde se comenzó a grabar pantalla o se ha dejado de grabar pantalla.
     */
    func didChangeScreenRecordingStatus(isCaptured: Bool, at controller: UIViewController?)
    /// Esta función se llama al iniciar el monitoreo y cuando la aplicación pasa de estar inactiva a estar activa para notificarte si el usuario está en una llamada al abrir la app o comienza una llamada con la aplicación abierta.
    func didChangeCallStatus(callStatus: DeviceCallStatus, at: UIViewController?)
    /// Esta función se llama cuando el usuario recibió una llamada y esta se encuentra sonando
    func didReceiveACall(at controller: UIViewController?)
    /// Esta función se llama cuando el usuario recibió una llamada y esta ha sido contestada
    func didAnswerACall(at controller: UIViewController?)
}

public extension DeviceValidationsDelegate {
    func didTakeScreenShot(at controller: UIViewController?) {}
    func didChangeScreenRecordingStatus(isCaptured: Bool, at controller: UIViewController?) {}
    func didChangeCallStatus(callStatus: DeviceCallStatus, at: UIViewController?) {}
    func didReceiveACall(at controller: UIViewController?) {}
    func didAnswerACall(at controller: UIViewController?) {}
    
}
