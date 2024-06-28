import Foundation

struct ListElement {
    var name: String
    var controllerToShow: AnyClass
    /// Solo puedes usar esta propiedad si la propiedad `controllerToShow` es de tipo `ListViewController.self`
    var nextListData: List?
    var contextData: Any?
}
