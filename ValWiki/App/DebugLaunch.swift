import SwiftUI

/// Launch-argument hooks used by the simulator screenshot run, e.g.
/// `xcrun simctl launch booted com.valowiki.app -vwScreen agent -vwScroll bottom`.
/// Ignored in normal use (no arguments, nothing changes).
enum DebugLaunch {
    static let screen: String? = UserDefaults.standard.string(forKey: "vwScreen")
    static let query: String? = UserDefaults.standard.string(forKey: "vwQuery")
    static let agent: String = UserDefaults.standard.string(forKey: "vwAgent") ?? "Jett"
    static let weapon: String = UserDefaults.standard.string(forKey: "vwWeapon") ?? "Vandal"
    static let map: String = UserDefaults.standard.string(forKey: "vwMap") ?? "Ascent"
    /// "center" or "bottom": where a scroll view opens.
    static let scroll: String? = UserDefaults.standard.string(forKey: "vwScroll")
    static var isActive: Bool { screen != nil }
}

extension View {
    /// Lets a screenshot run open a scroll view at its end.
    func debugScrollAnchor() -> some View {
        defaultScrollAnchor(DebugLaunch.scroll == "bottom" ? .bottom : (DebugLaunch.scroll == "center" ? .center : nil))
    }
}
