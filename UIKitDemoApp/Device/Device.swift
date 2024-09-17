import Foundation
import UIKit
import CallKit

public class Device: NSObject {
    // MARK: - Initialization Code
    public static var shared: Device = .init()
    public weak var delegate: DeviceValidationsDelegate?
    
    override init() {
        callObserver = CXCallObserver()
        super.init()
        callObserver.setDelegate(self, queue: nil)
    }
    
    // MARK: - Security Capabilities
    /**
     Esta función monitorea capturas de pantalla, grabación de pantalla y llamadas telefónicas mientras se está utilizando tu aplicación.
     
     Esta función habilita el monitoreo de: 
     * __Captura de pantalla:__ Estos pueden ser bloqueados de tal manera que no se pueda tomar un screen shot directamente dentro de la aplicación, puede simplemente monitorear si el usuario ha tomado un screen shot o puede hacer ambas.
     * __Grabación de Pantalla:__ Se notifica si el usuario está grabando o comienza a grabar pantalla mientras utiliza la aplicación.
     * __Llamadas telefónicas:__ Se notifica si el usuario esá en una llamada o comienza una llamada mientras utiliza la aplicación.
     
     - Parameters:
        - window: `UIWindow` que será monitoreada para bloquear los screen shots.
     
     - Warning: Esta función debe ser llamada solo una vez dentro del ciclo de vida de tu aplicación para evitar duplicidad en los observers que se utilizan dentro de la clase.
     */
    public func startMonitoring(window: UIWindow?) {
        startScreenShotMonitoring(for: window)
        startScreenRecordingMonitoring()
        startPhoneCallsMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /**
     Esta función inhabilita el monitore de capturas de pantalla, grabación de pantalla y llamadas telefónicas mientras se está utilizando tu aplicación.
     
     Esta función inhabilita el monitoreo de:
     * __Captura de pantalla__
     * __Grabación de Pantalla__
     * __Llamadas telefónicas__
     
     - Precondition: Para poder llamar esta función debes haber llamado en algún punto del ciclo de vida de tu aplicación la función `startMonitoring`
     */
    public func stopMonitoring() {
        stopScreenShotMonitoring()
        stopScreenShotMonitoring()
        stopPhoneCallsMonitoring()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /// Valida si el usuario está grabando pantalla o si está en una llamada telefónica
    @objc private func didBecomeActiveNotification() {
        checkScreenRecording()
        checkCurrentCalls()
    }
    
    // MARK: - ScreenShot Prevention
    private var secureField: UITextField?
    
    private func startScreenShotMonitoring(for window: UIWindow?) {
        makeWindowSecureForScreenShots(window)
        addScreenShotNotification()
    }
    
    private func stopScreenShotMonitoring() {
        unlockScreenShot()
        removeScreenShotNotification()
    }
    
    // MARK: Dark Screen Shot Feature
    private func makeWindowSecureForScreenShots(_ window: UIWindow?) {
        guard let window = window, secureField == nil else { return }
        secureField = window.makeSecure()
    }
    
    /// Esta función bloquea las capturas de pantalla.
    public func lockScreenShot() {
        secureField?.isSecureTextEntry = true
    }
    
    /// Esta función habilita las capturas de pantalla.
    public func unlockScreenShot() {
        secureField?.isSecureTextEntry = false
    }
    
    // MARK: Notification After Screen Shot
    
    /**
     Agrega la notificación `UIApplication.userDidTakeScreenshotNotification` a la instancia de `Device`.
     
     Esta función habilita al `delegate` de la instancia de `Device` para ser notificado de que el usuario ha tomado un screen shot dentro de la aplicación.
     */
    public func addScreenShotNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    /**
     Remueve la notificación `UIApplication.userDidTakeScreenshotNotification` de la instancia de `Device`.
     
     Esta función inhabilita al `delegate` de la instancia de `Device` para ser notificado de que el usuario ha tomado un screen shot dentro de la aplicación.
     
     - Warning: Si ejecutas esta función dejarás de recibir en el `delegate` de la instancia de `Device` el llamado a la función `didTakeScreenShot`
     */
    public func removeScreenShotNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    @objc private func didTakeScreenshot() {
        delegate?.didTakeScreenShot(at: UIWindow.getTopViewController())
    }
    
    // MARK: - Screen Recording Prevention
    private func startScreenRecordingMonitoring() {
        addScreenRecordingNotification()
    }
    
    private func stopScreenRecordingMonitoring() {
        removeScreenShotNotification()
    }
    
    private func checkScreenRecording() {
        let isCaptured = UIScreen.main.isCaptured
        delegate?.didChangeScreenRecordingStatus(isCaptured: isCaptured, at: UIWindow.getTopViewController())
    }
    
    // MARK: Screen Recording Notification
    public func addScreenRecordingNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    public func removeScreenRecordingNotification() {
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    @objc private func didScreenRecording() {
        delegate?.didChangeScreenRecordingStatus(isCaptured: UIScreen.main.isCaptured, at: UIWindow.getTopViewController())
    }
    
    // MARK: - Phone Calls Prevention
    private var callObserver: CXCallObserver
    private var isOnCall: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .callStateChanged, object: nil, userInfo: ["isOnCall": isOnCall])
        }
    }
    
    private func startPhoneCallsMonitoring() {
        addPhoneCallsNotification()
    }
    
    private func stopPhoneCallsMonitoring() {
        removePhoneCallsNotification()
    }
    
    private func checkCurrentCalls() {
        let calls = callObserver.calls
        isOnCall = !calls.isEmpty && calls.contains(where: { $0.hasConnected && !$0.hasEnded })
    }
    
    // MARK: Phone Calls Notification
    public func addPhoneCallsNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(callStateChanged(_:)), name: .callStateChanged, object: nil)
        checkCurrentCalls()
    }
    
    public func removePhoneCallsNotification() {
        NotificationCenter.default.removeObserver(self, name: .callStateChanged, object: nil)
    }
    
    @objc private func callStateChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let isOnCall = userInfo["isOnCall"] as? Bool else { return }
        delegate?.didChangeCallStatus(isOnCall: isOnCall, at: UIWindow.getTopViewController())
    }
}

// MARK: - CXCallObserverDelegate Management
extension Device: CXCallObserverDelegate {
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        checkCurrentCalls()
    }
}
