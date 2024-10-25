import Foundation
import UIKit
import CallKit

public enum DeviceCallStatus {
    case unowned
    case none
    case ringing
    case onCall
}

public final class Device: NSObject {
    // MARK: - Initialization Code
    
    /**
     Singletón de tipo `Device` que se utiliza para monitorear y gestionar acciones dentro de la aplicación.
     
     Singleton para:
     * Monitoreo y Bloquedo de capturas de pantalla dentro de la aplicación.
     * Monitoreo y Bloqueo de grabación de pantalla dentro de la aplicación.
     * Monitoreo de llamadas mientras se usa la aplicación.
     */
    public static var shared: Device = .init()
    
    /**
     Delegado en el cual se notifica la actividad del usuario dentro de la aplicación.
     */
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
     
     - Warning: Esta función debe ser llamada solo una vez dentro del ciclo de vida de tu aplicación.
     */
    public func startMonitoring(window: UIWindow?) {
        startScreenShotMonitoring(for: window)
        startScreenRecordingMonitoring()
        startPhoneCallsMonitoring()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /**
     Esta función reanuda el monitoreo de capturas de pantalla, grabación de pantalla y llamadas telefónicas mientras se está usando tu aplicación.
     
     Una vez que llamaste la función `stopMonitoring()` para inhabilitar/pausar el monitoreo, puedes usar esta función para retomarlo.
     
     - Important: A diferencia de `startMonitoring(window: UIWindow?)`, esta función puede ser llamada más de una vez pero sería buena práctica que la llames solo después de haber llamado a la función `stopMonitoring()`.
     */
    public func continueMonitoring() {
        lockScreenShot()
        addScreenShotNotification()
        startScreenRecordingMonitoring()
        startPhoneCallsMonitoring()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /**
     Esta función **inhabilita/pausa** el monitore de capturas de pantalla, grabación de pantalla y llamadas telefónicas mientras se está utilizando tu aplicación.
     
     Esta función **inhabilita/pausa** el monitoreo de:
     * __Captura de pantalla__
     * __Grabación de Pantalla__
     * __Llamadas telefónicas__
     
     - Precondition: Para poder llamar esta función debes haber llamado en algún punto del ciclo de vida de tu aplicación la función `startMonitoring`
     */
    public func stopMonitoring() {
        stopScreenShotMonitoring()
        stopScreenRecordingMonitoring()
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
    
    private func makeWindowSecureForScreenShots(_ window: UIWindow?) {
        guard let window = window, secureField == nil else { return }
        secureField = window.makeSecure()
    }
    
    private func stopScreenShotMonitoring() {
        unlockScreenShot()
        removeScreenShotNotification()
    }
    
    // MARK: Dark Screen Shot Feature
    
    /**
     Esta función bloquea las capturas de pantalla.
     
     Esta función bloquea las capturas de pantalla, en caso de que ya esten bloqueadas no tendrá ningún efecto adicional.
     
     - Important: Puedes volver a **habilitar** las capturas de pantalla llamando a la función `unlockScreenShot()`.
     */
    public func lockScreenShot() {
        secureField?.isSecureTextEntry = true
    }
    
    /**
     Esta función habilita las capturas de pantalla.
     
     Esta función habilita las capturas de pantalla, en caso de que ya estén habilitadas no tendrá ningún efecto adicional.
     
     - Important: Puedes volver a **bloquear** las capturas de pantalla llamand a la función `lockScreenShot()`
     */
    public func unlockScreenShot() {
        secureField?.isSecureTextEntry = false
    }
    
    public func isActiveScreenShotLock() -> Bool? {
        return secureField?.isSecureTextEntry
    }
    
    // MARK: Notification After Screen Shot
    
    /**
     Agrega la notificación `UIApplication.userDidTakeScreenshotNotification` a la instancia de `Device`.
     
     Esta función habilita al `delegate` de la instancia de `Device` para ser notificado de que el usuario ha tomado un screen shot dentro de la aplicación mediante la función `didTakeScreenShot(at controller: UIViewController?)` del  protocolo `DeviceValidationsDelegate`.
     
     - Important: Esta notificación cae justo después de que el usuario ha tomado el screen shot y está pensada para que hagas algo una vez que el usuario ha tomado una captura de pantalla, si lo que necesitas es impedir que el usuario tome capturas de pantalla lo que debes hacer es llamar la función `lockScreenShot()`.
     */
    public func addScreenShotNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    /**
     Remueve la notificación `UIApplication.userDidTakeScreenshotNotification` de la instancia de `Device`.
     
     Esta función inhabilita al `delegate` de la instancia de `Device` para ser notificado de que el usuario ha tomado un screen shot dentro de la aplicación.
     
     - Warning: Si ejecutas esta función dejarás de recibir en el `delegate` de la instancia de `Device` el llamado a la función `didTakeScreenShot(at controller: UIViewController?)`
     */
    public func removeScreenShotNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    @objc private func didTakeScreenshot() {
        delegate?.didTakeScreenShot(at: UIWindow.getTopViewController(), canUserTakeScreenShots: !(isActiveScreenShotLock() ?? false))
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
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
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
    private var callStatus: DeviceCallStatus = .unowned
    
    private func startPhoneCallsMonitoring() {
        addPhoneCallsNotification()
    }
    
    private func stopPhoneCallsMonitoring() {
        removePhoneCallsNotification()
    }
    
    private func checkCurrentCalls() {
        let calls = callObserver.calls
        callStatus = .unowned
        if calls.count == 0 {
            callStatus = .none
        } else if calls.first(where: { $0.hasConnected &&  !$0.hasEnded }) != nil {
            callStatus = .onCall
        } else if calls.first(where: { !$0.hasConnected || $0.isOutgoing }) != nil {
            callStatus = .ringing
        }
        callStateChanged(callStatus)
    }
    
    // MARK: Phone Calls Notification
    public func addPhoneCallsNotification() {
        checkCurrentCalls()
    }
    
    public func removePhoneCallsNotification() {
        NotificationCenter.default.removeObserver(self, name: .callStateChanged, object: nil)
    }
    
    private func callStateChanged(_ callStatus: DeviceCallStatus) {
        let topController = UIWindow.getTopViewController()
        delegate?.didChangeCallStatus(callStatus: callStatus, at: topController)
        switch callStatus {
        case .unowned, .none:
            return
        case .ringing:
            delegate?.didReceiveACall(at: topController)
        case .onCall:
            delegate?.didAnswerACall(at: topController)
        }
    }
}

// MARK: - CXCallObserverDelegate Management
extension Device: CXCallObserverDelegate {
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        checkCurrentCalls()
    }
}
