import Foundation
import UIKit

public protocol DeviceValidationsDelegate: AnyObject {
    /// Esta función se llama justo después de que el usuario ha tomado un screen shot dentro de tu aplicación.
    func didTakeScreenShot(at: UIViewController?)
    /// Esta función se llama al iniciar el monitoreo y cuando la aplicación pasa de estar inactiva a estar activa para notificarte si el usuario está grabando pantalla al abrir la app o comienza a grabar pantalla con la aplicación abierta.
    func didChangeScreenRecordingStatus(isCaptured: Bool, at: UIViewController?)
    /// Esta función se llama al iniciar el monitoreo y cuando la aplicación pasa de estar inactiva a estar activa para notificarte si el usuario está en una llamada al abrir la app o comienza una llamada con la aplicación abierta.
    func didChangeCallStatus(isOnCall: Bool, at: UIViewController?)
}
