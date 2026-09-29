import Foundation

/// Limba aplicației: română pe telefoanele setate în română, engleză în rest.
/// Aplicația o fixează la pornire (din `Bundle.main.preferredLocalizations`),
/// înainte de primul acces la `GameData.shared`. Implicit „ro” — testele de
/// paritate compară etichetele cu prototipul web, care e în română.
public enum AppLanguage {
    public static var code = "ro"
    public static var isRomanian: Bool { code == "ro" }

    /// „ro” dacă prima limbă rezolvată pentru aplicație e româna, altfel „en”.
    public static func resolve(_ preferred: [String]) -> String {
        preferred.first.map { $0.lowercased().hasPrefix("ro") } == true ? "ro" : "en"
    }
}

/// Textul în limba aplicației.
public func tr(_ ro: String, _ en: String) -> String { AppLanguage.isRomanian ? ro : en }

/// Notele meciurilor reale (RealFixtures.json e comun ambelor limbi) — traduse la afișare.
public func localizedNote(_ note: String) -> String {
    if AppLanguage.isRomanian { return note }
    let fixed: [String: String] = [
        "prelungiri": "extra time",
        "meci rejucat": "replay",
        "baraj de grupă": "group play-off",
        "gol de aur": "golden goal",
        "grupă finală round-robin, mapată ca eliminatorii": "final group (round robin)",
        "\"Maracanazo\" — meciul decisiv al grupei finale": "\"Maracanazo\" — the deciding match of the final group",
        "\"Miracolul de la Berna\"": "\"The Miracle of Bern\"",
        "\"Mâna lui Dumnezeu\" + \"Golul Secolului\"": "\"The Hand of God\" + \"The Goal of the Century\"",
    ]
    if let f = fixed[note] { return f }
    var s = note
    s = s.replacingOccurrences(of: "— una dintre cele mai mari finale din istorie", with: "— one of the greatest finals ever")
    s = s.replacingOccurrences(of: "după prelungiri", with: "after extra time")
    s = s.replacingOccurrences(of: "penalty-uri", with: "penalties")
    return s
}
