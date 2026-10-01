import Foundation

/// Limba aplicației = limba telefonului, dacă e una dintre cele suportate (română, engleză, spaniolă,
/// portugheză, germană, franceză, italiană); altfel engleză. Aplicația o fixează la pornire
/// (din `Bundle.main.preferredLocalizations`), înainte de primul acces la `GameData.shared`.
/// Implicit „ro” — testele de paritate compară etichetele cu prototipul web, care e în română.
/// Română și engleză sunt scrise direct în cod (`tr("ro", "en")`); celelalte limbi traduc textul englez
/// prin dicționarul UI_<limbă>.json (generat de tools/i18n/build.py din tools/i18n/<limbă>.json).
public enum AppLanguage {
    public static var code = "ro"
    public static let supported = ["en", "ro", "es", "pt", "de", "fr", "it"]
    public static var isRomanian: Bool { code == "ro" }

    /// prima limbă a telefonului, dacă o știm; altfel „en”
    public static func resolve(_ preferred: [String]) -> String {
        guard let first = preferred.first?.lowercased() else { return "en" }
        let base = String(first.prefix(2))
        return supported.contains(base) ? base : "en"
    }

    /// fișierul cu datele în limba aplicației: Data.json (română), Data_en.json, Data_es.json…
    public static var dataFile: String { code == "ro" ? "Data" : "Data_" + code }

    /// formatul datelor calendaristice și al numerelor
    public static var localeIdentifier: String {
        ["ro": "ro_RO", "en": "en_US", "es": "es_ES", "pt": "pt_BR", "de": "de_DE", "fr": "fr_FR", "it": "it_IT"][code] ?? "en_US"
    }
}

/// Textul în limba aplicației.
public func tr(_ ro: String, _ en: String) -> String {
    switch AppLanguage.code {
    case "ro": return ro
    case "en": return en
    default: return translated(en)
    }
}

/// Traducerea unui text englez în limba aplicației (identic dacă nu există traducere).
/// Șabloanele cu {0}, {1}… potrivesc textele cu valori deja inserate („Group {0}” → „Grupo {0}”).
public func translated(_ en: String) -> String { UITable.shared.translate(en) }

final class UITable {
    static let shared = UITable()
    private let lock = NSLock()
    private var lang = ""
    private var exact: [String: String] = [:]
    private var patterns: [(re: NSRegularExpression, order: [Int], target: String)] = []
    private var cache: [String: String] = [:]

    func translate(_ en: String) -> String {
        lock.lock(); defer { lock.unlock() }
        if lang != AppLanguage.code { load(AppLanguage.code) }
        if let t = exact[en] { return t }
        if let c = cache[en] { return c }
        var out = en
        let ns = en as NSString
        for p in patterns {
            guard let m = p.re.firstMatch(in: en, range: NSRange(location: 0, length: ns.length)) else { continue }
            var r = p.target
            for (k, idx) in p.order.enumerated() {
                r = r.replacingOccurrences(of: "{\(idx)}", with: ns.substring(with: m.range(at: k + 1)))
            }
            out = r
            break
        }
        cache[en] = out
        return out
    }

    private func load(_ code: String) {
        lang = code
        exact = [:]
        patterns = []
        cache = [:]
        guard code != "ro", code != "en",
              let url = Bundle.module.url(forResource: "UI_" + code, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: String].self, from: data),
              let ph = try? NSRegularExpression(pattern: "\\{(\\d+)\\}") else { return }
        var pats: [(re: NSRegularExpression, order: [Int], target: String, weight: Int)] = []
        for (key, value) in dict {
            let k = key as NSString
            let ms = ph.matches(in: key, range: NSRange(location: 0, length: k.length))
            if ms.isEmpty { exact[key] = value; continue }
            var pattern = "^", last = 0, order: [Int] = [], literal = 0
            for m in ms {
                let part = k.substring(with: NSRange(location: last, length: m.range.location - last))
                literal += part.count
                pattern += NSRegularExpression.escapedPattern(for: part) + "(.+?)"
                order.append(Int(k.substring(with: m.range(at: 1))) ?? 0)
                last = m.range.location + m.range.length
            }
            let tail = k.substring(from: last)
            literal += tail.count
            pattern += NSRegularExpression.escapedPattern(for: tail) + "$"
            if let re = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
                pats.append((re, order, value, literal))
            }
        }
        // cel mai specific șablon întâi („Group {0} (second round)” înaintea lui „Group {0}”)
        patterns = pats.sorted { $0.weight > $1.weight }.map { ($0.re, $0.order, $0.target) }
    }
}

/// Cuvintele din notele meciurilor (prelungiri / penalty-uri), în toate limbile — notele vin din date traduse.
public enum NoteWords {
    /// „penalties” în limba aplicației („penaltis”, „Elfmeterschießen”…)
    static var penaltyWord: String {
        translated("penalties {0}-{1}").replacingOccurrences(of: "{0}-{1}", with: "").trimmingCharacters(in: .whitespaces)
    }

    /// nota spune că meciul s-a decis la penalty-uri
    public static func isPenalty(_ note: String) -> Bool {
        let w = penaltyWord
        return note.contains("penalt") || (!w.isEmpty && note.contains(w))
    }

    /// nota spune că meciul a avut prelungiri (sau penalty-uri)
    public static func hadExtraTime(_ note: String) -> Bool {
        if isPenalty(note) { return true }
        return (["prelungiri", "extra time", translated("extra time"), translated("after extra time")]).contains {
            !$0.isEmpty && note.contains($0)
        }
    }
}

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
    // celelalte limbi: textul englez, tradus prin dicționar („after extra time”, „penalties 4-3”…)
    func out(_ en: String) -> String { AppLanguage.code == "en" ? en : translated(en) }
    if let f = fixed[note] { return out(f) }
    var s = note
    s = s.replacingOccurrences(of: "— una dintre cele mai mari finale din istorie", with: "— one of the greatest finals ever")
    s = s.replacingOccurrences(of: "după prelungiri", with: "after extra time")
    s = s.replacingOccurrences(of: "penalty-uri", with: "penalties")
    return out(s)
}
