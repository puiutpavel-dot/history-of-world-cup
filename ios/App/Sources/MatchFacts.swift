import SwiftUI
import WorldCupCore

// MARK: - „Știai că?” — o informație interesantă după fiecare meci real.
// Prioritate: faptele scrise de mână pentru meciurile celebre, apoi cele calculate din date
// (record de goluri, hat-trick, întoarcere de scor, gol decisiv târziu, premiere ale echipei,
// meciuri cu multe goluri) și, la final, istoria întâlnirilor dintre cele două echipe.

struct MatchFact: Hashable {
    let emoji: String
    let text: String
}

final class MatchFacts {
    private let data: GameData
    /// traseele fiecărei echipe (cod), sortate după an; codurile comune (ex. TCH) apar o singură dată
    private var byCode: [String: [TrackEntry]] = [:]
    /// golurile fiecărui jucător la Mondialele de dinaintea anului dat
    private var goalsBefore: [Int: [String: Int]] = [:]
    /// recordul all-time de goluri la Mondiale înainte de anul dat (număr, deținător)
    private var recordBefore: [Int: (Int, String)] = [:]

    init(data: GameData) {
        self.data = data
        var seen = Set<String>()
        var all: [TrackEntry] = []
        for c in data.countries {
            for e in c.entries where seen.insert("\(e.year)|\(e.code)").inserted {
                all.append(e)
                byCode[e.code, default: []].append(e)
            }
        }
        for k in byCode.keys { byCode[k]?.sort { $0.year < $1.year } }

        var totals: [String: Int] = [:]
        for year in Set(all.map(\.year)).sorted() {
            goalsBefore[year] = totals
            let best = totals.max { $0.value < $1.value }
            recordBefore[year] = (best?.value ?? 0, best?.key ?? "")
            for e in all where e.year == year {
                for m in e.matches {
                    for g in m.goals ?? [] where g.t == 1 && g.k != "og" { totals[g.n, default: 0] += 1 }
                }
            }
        }
    }

    func facts(team: String, year: Int, index: Int, limit: Int = 2) -> [MatchFact] {
        guard let entries = byCode[team], let entry = entries.first(where: { $0.year == year }),
              entry.matches.indices.contains(index) else { return [] }
        let m = entry.matches[index]
        var out: [MatchFact] = []
        func add(_ f: MatchFact?) { if let f, out.count < limit, !out.contains(f) { out.append(f) } }

        let story = curated(year: year, team: team, m: m)
        add(story)
        // nu repetăm un jucător deja pomenit în povestea meciului
        let told = story?.text ?? ""
        add(record(year: year, team: team, index: index, m: m, skip: told))
        add(hatTrick(m, skip: told))
        add(comeback(team: team, m: m))
        add(lateDecider(m, skip: told))
        add(milestone(team: team, entries: entries, entry: entry, index: index, m: m))
        add(fastGoal(m))
        add(goalFest(m))
        add(headToHead(team: team, entries: entries, entry: entry, index: index, m: m))
        return out
    }

    // MARK: faptele calculate

    private func name(_ code: String) -> String { data.meta(code).name }
    private func scorers(_ m: TrackMatch) -> [TrackGoal] { (m.goals ?? []).filter { $0.k != "og" } }
    /// jucătorul apare deja în text (după numele de familie)
    private func mentioned(_ player: String, in text: String) -> Bool {
        guard !text.isEmpty, let last = player.split(separator: " ").last else { return false }
        return text.contains(last)
    }

    /// golurile marcate de fiecare jucător al echipei `code` în meciurile ediției dinaintea meciului `before`
    private func tournamentGoals(_ code: String, _ year: Int, before: Int) -> [String: Int] {
        guard let e = byCode[code]?.first(where: { $0.year == year }) else { return [:] }
        var out: [String: Int] = [:]
        for m in e.matches.prefix(max(0, before)) {
            for g in m.goals ?? [] where g.t == 1 && g.k != "og" { out[g.n, default: 0] += 1 }
        }
        return out
    }

    /// indexul aceluiași meci în traseul adversarului
    private func oppIndex(team: String, year: Int, m: TrackMatch) -> Int? {
        byCode[m.opp]?.first(where: { $0.year == year })?.matches
            .firstIndex { $0.opp == team && $0.gf == m.ga && $0.ga == m.gf }
    }

    private func record(year: Int, team: String, index: Int, m: TrackMatch, skip: String) -> MatchFact? {
        guard year > 1930, let recInfo = recordBefore[year], let base = goalsBefore[year] else { return nil }
        let (rec, holder) = recInfo
        let mine = tournamentGoals(team, year, before: index)
        let theirs = oppIndex(team: team, year: year, m: m).map { tournamentGoals(m.opp, year, before: $0) } ?? [:]
        var inMatch: [String: Int] = [:]
        for g in scorers(m) { inMatch[g.n, default: 0] += 1 }
        for (player, n) in inMatch.sorted(by: { $0.key < $1.key }) {
            let before = (base[player] ?? 0) + (mine[player] ?? 0) + (theirs[player] ?? 0)
            let after = before + n
            guard after >= 5, !mentioned(player, in: skip) else { continue }
            if before <= rec && after > rec {
                return MatchFact(emoji: "🏅", text: tr(
                    "\(player) a ajuns la \(after) goluri la Mondiale — cel mai bun marcator din istoria competiției de până atunci.",
                    "\(player) reached \(after) World Cup goals — the competition's all-time top scorer at that point."))
            }
            if after == rec && before < rec && player != holder {
                return MatchFact(emoji: "🏅", text: tr(
                    "\(player) a ajuns la \(after) goluri la Mondiale și a egalat recordul all-time al lui \(holder).",
                    "\(player) reached \(after) World Cup goals, equalling \(holder)'s all-time record."))
            }
        }
        return nil
    }

    private func hatTrick(_ m: TrackMatch, skip: String) -> MatchFact? {
        var count: [String: Int] = [:]
        for g in scorers(m) { count[g.n, default: 0] += 1 }
        guard let top = count.max(by: { $0.value < $1.value }), top.value >= 3, !mentioned(top.key, in: skip) else { return nil }
        let (player, n) = (top.key, top.value)
        if n == 3 {
            return MatchFact(emoji: "🎩", text: tr("Hat-trick pentru \(player).", "A hat-trick for \(player)."))
        }
        return MatchFact(emoji: "🎩", text: tr("\(player) a marcat de \(n) ori într-un singur meci.",
                                              "\(player) scored \(n) times in a single match."))
    }

    private func comeback(team: String, m: TrackMatch) -> MatchFact? {
        guard let goals = m.goals, !goals.isEmpty else { return nil }
        var a = 0, b = 0
        var worst = (0, 0), best = (0, 0)
        for g in goals {
            if g.t == 1 { a += 1 } else { b += 1 }
            if a - b < worst.0 - worst.1 { worst = (a, b) }
            if a - b > best.0 - best.1 { best = (a, b) }
        }
        let t = name(team)
        let lowDiff = worst.0 - worst.1, highDiff = best.0 - best.1
        if m.gf > m.ga && lowDiff < 0 {
            return MatchFact(emoji: "🔄", text: tr("\(t) a întors scorul: a fost condusă cu \(worst.0)–\(worst.1).",
                                                  "\(t) turned it around after trailing \(worst.0)–\(worst.1)."))
        }
        if m.gf < m.ga && highDiff > 0 {
            return MatchFact(emoji: "🔄", text: tr("\(t) a condus cu \(best.0)–\(best.1), dar a pierdut.",
                                                  "\(t) led \(best.0)–\(best.1) but lost."))
        }
        if m.gf == m.ga && lowDiff <= -2 {
            return MatchFact(emoji: "🔄", text: tr("\(t) a revenit de la \(worst.0)–\(worst.1).",
                                                  "\(t) came back from \(worst.0)–\(worst.1) down."))
        }
        if m.gf == m.ga && highDiff >= 2 {
            return MatchFact(emoji: "🔄", text: tr("\(t) a condus cu \(best.0)–\(best.1), dar nu a câștigat.",
                                                  "\(t) led \(best.0)–\(best.1) but could not win."))
        }
        return nil
    }

    private func lateDecider(_ m: TrackMatch, skip: String) -> MatchFact? {
        guard let goals = m.goals, let last = goals.last, last.base >= 85, !mentioned(last.n, in: skip) else { return nil }
        let after = m.gf - m.ga
        let before = after - (last.t == 1 ? 1 : -1)
        guard after.signum() != before.signum() else { return nil }
        if after == 0 {
            return MatchFact(emoji: "⏱️", text: tr("Egalarea a venit târziu, în minutul \(last.m): \(last.n).",
                                                  "A late equaliser, in minute \(last.m): \(last.n)."))
        }
        if last.base > 90 {
            return MatchFact(emoji: "⏱️", text: tr("Golul decisiv a venit în prelungiri, în minutul \(last.m): \(last.n).",
                                                  "The decisive goal came in extra time, in minute \(last.m): \(last.n)."))
        }
        return MatchFact(emoji: "⏱️", text: tr("Golul decisiv a venit în minutul \(last.m): \(last.n).",
                                              "The decisive goal came in minute \(last.m): \(last.n)."))
    }

    private func milestone(team: String, entries: [TrackEntry], entry: TrackEntry, index: Int, m: TrackMatch) -> MatchFact? {
        let t = name(team)
        let previous = entries.filter { $0.year < entry.year }.flatMap(\.matches) + entry.matches.prefix(index)
        if previous.isEmpty {
            return MatchFact(emoji: "🌱", text: tr("Primul meci din istoria echipei \(t) la un Mondial.",
                                                  "\(t)'s first ever World Cup match."))
        }
        if m.gf > m.ga && !previous.contains(where: { $0.gf > $0.ga }) {
            return MatchFact(emoji: "🌱", text: tr("Prima victorie din istoria echipei \(t) la un Mondial.",
                                                  "\(t)'s first ever World Cup win."))
        }
        if m.gf > 0 && !previous.contains(where: { $0.gf > 0 }),
           let first = (m.goals ?? []).first(where: { $0.t == 1 }) {
            return MatchFact(emoji: "🌱", text: tr("Primul gol din istoria echipei \(t) la Mondiale: \(first.n).",
                                                  "\(t)'s first ever World Cup goal: \(first.n)."))
        }
        let margin = m.gf - m.ga
        if margin >= 3 && margin > (previous.map { $0.gf - $0.ga }.max() ?? 0) {
            return MatchFact(emoji: "📈", text: tr("Cea mai mare victorie a echipei \(t) la Mondiale de până atunci.",
                                                  "\(t)'s biggest World Cup win up to that point."))
        }
        return nil
    }

    private func fastGoal(_ m: TrackMatch) -> MatchFact? {
        guard let first = m.goals?.first, first.base <= 2 else { return nil }
        return MatchFact(emoji: "⚡", text: tr("Gol rapid: \(first.n) a marcat în minutul \(first.m).",
                                              "A quick start: \(first.n) scored in minute \(first.m)."))
    }

    private func goalFest(_ m: TrackMatch) -> MatchFact? {
        let n = m.gf + m.ga
        guard n >= 7 else { return nil }
        return MatchFact(emoji: "🎆", text: tr("\(n) goluri într-un singur meci.", "\(n) goals in a single match."))
    }

    private func headToHead(team: String, entries: [TrackEntry], entry: TrackEntry, index: Int, m: TrackMatch) -> MatchFact? {
        let a = name(team), b = name(m.opp)
        var prior: [(Int, TrackMatch)] = []
        for e in entries where e.year < entry.year {
            for x in e.matches where x.opp == m.opp { prior.append((e.year, x)) }
        }
        for x in entry.matches.prefix(index) where x.opp == m.opp { prior.append((entry.year, x)) }
        guard let last = prior.last else {
            return MatchFact(emoji: "🤝", text: tr("Prima întâlnire dintre \(a) și \(b) la un Mondial.",
                                                  "The first World Cup meeting between \(a) and \(b)."))
        }
        let w = prior.filter { $0.1.gf > $0.1.ga }.count
        let d = prior.filter { $0.1.gf == $0.1.ga }.count
        let l = prior.count - w - d
        return MatchFact(emoji: "🤝", text: tr(
            "A \(prior.count + 1)-a întâlnire la Mondiale între \(a) și \(b). Precedenta: \(String(last.0)), \(last.1.gf)–\(last.1.ga). Bilanț anterior: \(w)V \(d)E \(l)Î.",
            "World Cup meeting no. \(prior.count + 1) between \(a) and \(b). The previous one: \(String(last.0)), \(last.1.gf)–\(last.1.ga). Record before: \(w)W \(d)D \(l)L."))
    }

    // MARK: meciurile celebre (scrise de mână)

    private func curated(year: Int, team: String, m: TrackMatch) -> MatchFact? {
        for c in Self.famous where c.year == year {
            if (c.a == team && c.b == m.opp && c.sa == m.gf && c.sb == m.ga)
                || (c.b == team && c.a == m.opp && c.sb == m.gf && c.sa == m.ga) {
                return MatchFact(emoji: "📜", text: tr(c.ro, c.en))
            }
        }
        return nil
    }

    private struct Famous {
        let year: Int, a: String, b: String, sa: Int, sb: Int, ro: String, en: String
    }

    private static let famous: [Famous] = [
        Famous(year: 1930, a: "FRA", b: "MEX", sa: 4, sb: 1,
               ro: "Lucien Laurent a marcat în minutul 19 primul gol din istoria Campionatului Mondial.",
               en: "Lucien Laurent scored the first goal in World Cup history, in minute 19."),
        Famous(year: 1930, a: "URU", b: "ARG", sa: 4, sb: 2,
               ro: "Prima finală din istorie. Echipele nu s-au înțeles asupra mingii, așa că în prima repriză s-a jucat cu mingea Argentinei, iar în a doua cu a Uruguayului.",
               en: "The first ever final. The teams could not agree on a ball, so Argentina's was used in the first half and Uruguay's in the second."),
        Famous(year: 1934, a: "ITA", b: "TCH", sa: 2, sb: 1,
               ro: "Prima finală decisă în prelungiri: Angelo Schiavio a dat golul titlului în minutul 95.",
               en: "The first final decided in extra time: Angelo Schiavio scored the winner in minute 95."),
        Famous(year: 1938, a: "BRA", b: "POL", sa: 6, sb: 5,
               ro: "Ernst Wilimowski a marcat 4 goluri pentru Polonia și tot a pierdut — Leônidas a răspuns cu 3.",
               en: "Ernst Wilimowski scored 4 for Poland and still lost — Leônidas replied with 3."),
        Famous(year: 1938, a: "ITA", b: "HUN", sa: 4, sb: 2,
               ro: "Italia devine prima echipă care își apără titlul. Vittorio Pozzo rămâne singurul antrenor cu două titluri mondiale.",
               en: "Italy became the first team to retain the title. Vittorio Pozzo is still the only coach to win two World Cups."),
        Famous(year: 1950, a: "USA", b: "ENG", sa: 1, sb: 0,
               ro: "Una dintre cele mai mari surprize din istorie: echipa amatoare a SUA a învins Anglia, la primul ei Mondial.",
               en: "One of the biggest upsets ever: the part-timers of the USA beat England at England's first World Cup."),
        Famous(year: 1950, a: "URU", b: "BRA", sa: 2, sb: 1,
               ro: "„Maracanazo”: în fața a aproape 200.000 de spectatori pe Maracanã, Uruguay a câștigat titlul. Brazilia avea nevoie doar de un egal.",
               en: "The \"Maracanazo\": in front of almost 200,000 fans at the Maracanã, Uruguay won the title. Brazil only needed a draw."),
        Famous(year: 1954, a: "HUN", b: "GER", sa: 8, sb: 3,
               ro: "Germania a trimis în teren o echipă cu multe rezerve. În acest meci, Puskás s-a accidentat la gleznă.",
               en: "West Germany fielded a side full of reserves. Puskás injured his ankle in this match."),
        Famous(year: 1954, a: "GER", b: "HUN", sa: 3, sb: 2,
               ro: "„Miracolul de la Berna”: Ungaria era neînvinsă de aproape patru ani și conducea cu 2–0 după 8 minute.",
               en: "The \"Miracle of Bern\": Hungary had been unbeaten for almost four years and led 2–0 after 8 minutes."),
        Famous(year: 1954, a: "AUT", b: "SUI", sa: 7, sb: 5,
               ro: "Cel mai spectaculos meci din istoria Mondialelor: 12 goluri, jucat pe o căldură sufocantă la Lausanne.",
               en: "The highest-scoring match in World Cup history: 12 goals, played in scorching heat in Lausanne."),
        Famous(year: 1958, a: "FRA", b: "GER", sa: 6, sb: 3,
               ro: "Just Fontaine a marcat de 4 ori și a ajuns la 13 goluri într-o singură ediție — record neegalat nici astăzi.",
               en: "Just Fontaine scored 4 and reached 13 goals at a single World Cup — a record that still stands."),
        Famous(year: 1958, a: "BRA", b: "SWE", sa: 5, sb: 2,
               ro: "Pelé, la doar 17 ani, a marcat de două ori în finală. Primul titlu mondial al Braziliei.",
               en: "Pelé, only 17, scored twice in the final. Brazil's first world title."),
        Famous(year: 1962, a: "CHI", b: "ITA", sa: 2, sb: 0,
               ro: "Rămas în istorie drept „Bătălia de la Santiago”, unul dintre cele mai violente meciuri jucate vreodată.",
               en: "Remembered as the \"Battle of Santiago\", one of the most violent matches ever played."),
        Famous(year: 1966, a: "PRK", b: "ITA", sa: 1, sb: 0,
               ro: "Golul lui Pak Doo-ik a eliminat Italia — una dintre cele mai mari surprize din istoria turneului.",
               en: "Pak Doo-ik's goal knocked Italy out — one of the tournament's greatest upsets."),
        Famous(year: 1966, a: "POR", b: "PRK", sa: 5, sb: 3,
               ro: "Coreea de Nord conducea cu 3–0 după 25 de minute. Eusébio a marcat de 4 ori și a întors meciul.",
               en: "North Korea led 3–0 after 25 minutes. Eusébio scored 4 and turned the match around."),
        Famous(year: 1966, a: "ENG", b: "ARG", sa: 1, sb: 0,
               ro: "Eliminarea lui Antonio Rattín l-a inspirat pe arbitrul Ken Aston să inventeze cartonașele galbene și roșii, folosite din 1970.",
               en: "Antonio Rattín's sending-off inspired referee Ken Aston to invent yellow and red cards, used from 1970."),
        Famous(year: 1966, a: "ENG", b: "GER", sa: 4, sb: 2,
               ro: "Geoff Hurst a reușit primul hat-trick dintr-o finală. Al treilea său gol, după ce mingea a lovit bara, se discută și astăzi.",
               en: "Geoff Hurst scored the first hat-trick in a final. His third goal, off the crossbar, is still debated today."),
        Famous(year: 1970, a: "ITA", b: "GER", sa: 4, sb: 3,
               ro: "„Meciul secolului”: 5 goluri în prelungiri, iar Beckenbauer a jucat cu umărul luxat și brațul legat de corp.",
               en: "The \"Game of the Century\": 5 goals in extra time, with Beckenbauer playing on with a dislocated shoulder in a sling."),
        Famous(year: 1970, a: "BRA", b: "ITA", sa: 4, sb: 1,
               ro: "Al treilea titlu al Braziliei, care a primit definitiv trofeul Jules Rimet. Golul lui Carlos Alberto e considerat unul dintre cele mai frumoase goluri de echipă.",
               en: "Brazil's third title, which let them keep the Jules Rimet trophy for good. Carlos Alberto's goal is hailed as one of the finest team goals ever."),
        Famous(year: 1974, a: "GDR", b: "GER", sa: 1, sb: 0,
               ro: "Singurul meci oficial dintre cele două Germanii. Jürgen Sparwasser a dat golul victoriei pentru RDG.",
               en: "The only official match between the two German states. Jürgen Sparwasser scored the winner for East Germany."),
        Famous(year: 1974, a: "GER", b: "NED", sa: 2, sb: 1,
               ro: "Olandezii au marcat din penalty în minutul 2, înainte ca vreun german să atingă mingea — și tot au pierdut finala.",
               en: "The Dutch scored a penalty in minute 2, before any German had touched the ball — and still lost the final."),
        Famous(year: 1978, a: "ARG", b: "PER", sa: 6, sb: 0,
               ro: "Argentina avea nevoie de o victorie la cel puțin 4 goluri diferență ca să ajungă în finală.",
               en: "Argentina needed to win by at least four goals to reach the final."),
        Famous(year: 1978, a: "ARG", b: "NED", sa: 3, sb: 1,
               ro: "Primul titlu al Argentinei. În minutul 90, Rob Rensenbrink a lovit bara pentru Olanda.",
               en: "Argentina's first title. In the 90th minute, Rob Rensenbrink hit the post for the Netherlands."),
        Famous(year: 1982, a: "ALG", b: "GER", sa: 2, sb: 1,
               ro: "Algeria a învins Germania, dar a fost eliminată după „rușinea de la Gijón”. De atunci, ultimele meciuri din grupă se joacă simultan.",
               en: "Algeria beat West Germany but went out after the \"Disgrace of Gijón\". Since then, final group games kick off at the same time."),
        Famous(year: 1982, a: "HUN", b: "SLV", sa: 10, sb: 1,
               ro: "Singurul meci din istoria Mondialelor în care o echipă a marcat 10 goluri.",
               en: "The only World Cup match in which a team scored 10 goals."),
        Famous(year: 1982, a: "ITA", b: "BRA", sa: 3, sb: 2,
               ro: "Paolo Rossi a marcat de trei ori și a eliminat Brazilia lui Zico și Sócrates. A terminat turneul campion și golgheter.",
               en: "Paolo Rossi scored three times to knock out the Brazil of Zico and Sócrates. He ended the tournament as champion and top scorer."),
        Famous(year: 1982, a: "GER", b: "FRA", sa: 3, sb: 3,
               ro: "Primele lovituri de departajare din istoria Mondialelor. Franța conducea cu 3–1 în prelungiri.",
               en: "The first penalty shoot-out in World Cup history. France had led 3–1 in extra time."),
        Famous(year: 1986, a: "ARG", b: "ENG", sa: 2, sb: 1,
               ro: "În 4 minute, Maradona a marcat „Mâna lui Dumnezeu” și apoi „Golul secolului”, după o cursă din propria jumătate.",
               en: "Within four minutes, Maradona scored the \"Hand of God\" and then the \"Goal of the Century\", after a run from his own half."),
        Famous(year: 1986, a: "ARG", b: "GER", sa: 3, sb: 2,
               ro: "Germania a revenit de la 0–2, dar Burruchaga a dat golul titlului în minutul 84, după o pasă a lui Maradona.",
               en: "West Germany came back from 0–2, but Burruchaga scored the winner in minute 84 from a Maradona pass."),
        Famous(year: 1990, a: "CMR", b: "ARG", sa: 1, sb: 0,
               ro: "În meciul de deschidere, Camerunul a învins campioana en-titre, terminând meciul cu doar 9 jucători.",
               en: "In the opening match, Cameroon beat the reigning champions while finishing with only nine men."),
        Famous(year: 1990, a: "GER", b: "ARG", sa: 1, sb: 0,
               ro: "Prima finală cu un jucător eliminat: Pedro Monzón. Andreas Brehme a decis titlul din penalty în minutul 85.",
               en: "The first final with a player sent off: Pedro Monzón. Andreas Brehme won it with a penalty in minute 85."),
        Famous(year: 1994, a: "ROU", b: "COL", sa: 3, sb: 1,
               ro: "Golul lui Hagi din minutul 34 a venit dintr-un lob de la aproximativ 40 de metri, de lângă linia laterală. Columbia era considerată una dintre favorite.",
               en: "Hagi's goal in minute 34 was a lob from around 40 metres, out near the touchline. Colombia were seen as one of the favourites."),
        Famous(year: 1994, a: "ROU", b: "ARG", sa: 3, sb: 2,
               ro: "Unul dintre cele mai mari meciuri ale României: Dumitrescu a marcat de două ori, iar România a ajuns pentru prima dată în sferturi.",
               en: "One of Romania's greatest matches: Dumitrescu scored twice and Romania reached the quarter-finals for the first time."),
        Famous(year: 1994, a: "ROU", b: "SWE", sa: 2, sb: 2,
               ro: "Răducioiu a dus România în avantaj în prelungiri, dar Suedia a egalat în minutul 115. La penalty-uri, Ravelli a apărat loviturile lui Petrescu și Belodedici.",
               en: "Răducioiu put Romania ahead in extra time, but Sweden equalised in minute 115. In the shoot-out, Ravelli saved from Petrescu and Belodedici."),
        Famous(year: 1994, a: "RUS", b: "CMR", sa: 6, sb: 1,
               ro: "Oleg Salenko a marcat 5 goluri — record pentru un singur meci. Roger Milla, la 42 de ani, a devenit cel mai vârstnic marcator.",
               en: "Oleg Salenko scored 5 goals — the record for a single match. Roger Milla, aged 42, became the oldest scorer."),
        Famous(year: 1994, a: "BRA", b: "ITA", sa: 0, sb: 0,
               ro: "Prima finală decisă la penalty-uri. Roberto Baggio a trimis ultima lovitură peste poartă.",
               en: "The first final decided on penalties. Roberto Baggio sent the last kick over the bar."),
        Famous(year: 1998, a: "ROU", b: "TUN", sa: 1, sb: 1,
               ro: "Înaintea acestui meci, jucătorii României și-au vopsit părul blond, după o promisiune făcută la calificarea din grupă.",
               en: "Before this match, Romania's players dyed their hair blond, keeping a promise made once they qualified from the group."),
        Famous(year: 1998, a: "FRA", b: "CRO", sa: 2, sb: 1,
               ro: "Lilian Thuram a marcat ambele goluri — singurele goluri din cele 142 de meciuri jucate pentru naționala Franței.",
               en: "Lilian Thuram scored both goals — his only goals in 142 matches for France."),
        Famous(year: 1998, a: "FRA", b: "BRA", sa: 3, sb: 0,
               ro: "Zidane a marcat de două ori cu capul, iar Franța a câștigat primul său titlu mondial, pe teren propriu.",
               en: "Zidane scored two headers and France won their first world title, on home soil."),
        Famous(year: 2002, a: "SEN", b: "FRA", sa: 1, sb: 0,
               ro: "La primul său Mondial, Senegalul a învins campioana en-titre în meciul de deschidere.",
               en: "At their first World Cup, Senegal beat the reigning champions in the opening match."),
        Famous(year: 2002, a: "KOR", b: "ITA", sa: 2, sb: 1,
               ro: "Ahn Jung-hwan a calificat Coreea de Sud cu un „gol de aur” în prelungiri.",
               en: "Ahn Jung-hwan sent South Korea through with a \"golden goal\" in extra time."),
        Famous(year: 2002, a: "BRA", b: "GER", sa: 2, sb: 0,
               ro: "Ronaldo a marcat de două ori și a ajuns la 8 goluri în turneu. Al cincilea titlu al Braziliei — record.",
               en: "Ronaldo scored twice to reach 8 goals at the tournament. Brazil's fifth title — a record."),
        Famous(year: 2006, a: "ITA", b: "FRA", sa: 1, sb: 1,
               ro: "În ultimul meci al carierei, Zidane a fost eliminat după o lovitură cu capul în pieptul lui Materazzi.",
               en: "In the last match of his career, Zidane was sent off for headbutting Materazzi."),
        Famous(year: 2010, a: "URU", b: "GHA", sa: 1, sb: 1,
               ro: "În ultimul minut al prelungirilor, Suárez a oprit cu mâna un gol sigur. Gyan a ratat penalty-ul, iar Uruguay a trecut la loviturile de departajare.",
               en: "In the last minute of extra time, Suárez stopped a certain goal with his hand. Gyan missed the penalty and Uruguay won the shoot-out."),
        Famous(year: 2010, a: "ESP", b: "NED", sa: 1, sb: 0,
               ro: "Iniesta a marcat în minutul 116 și a adus primul titlu mondial al Spaniei.",
               en: "Iniesta scored in minute 116 to give Spain their first world title."),
        Famous(year: 2014, a: "NED", b: "ESP", sa: 5, sb: 1,
               ro: "Revanșa finalei din 2010, cu golul lui Robin van Persie, dintr-un plonjon cu capul de la marginea careului.",
               en: "A rematch of the 2010 final, featuring Robin van Persie's flying header from the edge of the box."),
        Famous(year: 2014, a: "GER", b: "BRA", sa: 7, sb: 1,
               ro: "Germania a marcat 5 goluri în primele 29 de minute. Klose a ajuns la 16 goluri — recordul all-time.",
               en: "Germany scored 5 goals in the first 29 minutes. Klose reached 16 goals — the all-time record."),
        Famous(year: 2014, a: "GER", b: "ARG", sa: 1, sb: 0,
               ro: "Mario Götze, intrat de pe bancă, a marcat în minutul 113. Primul titlu al unei echipe europene câștigat în America.",
               en: "Substitute Mario Götze scored in minute 113. The first title won by a European team in the Americas."),
        Famous(year: 2018, a: "KOR", b: "GER", sa: 2, sb: 0,
               ro: "Campioana en-titre a fost eliminată în grupe — prima dată pentru Germania din 1938 încoace.",
               en: "The reigning champions went out in the group stage — a first for Germany since 1938."),
        Famous(year: 2018, a: "FRA", b: "CRO", sa: 4, sb: 2,
               ro: "Primul autogol dintr-o finală (Mandžukić) și primul penalty acordat în finală cu ajutorul VAR.",
               en: "The first own goal in a final (Mandžukić) and the first penalty awarded in a final with the help of VAR."),
        Famous(year: 2022, a: "KSA", b: "ARG", sa: 2, sb: 1,
               ro: "Singura înfrângere a viitoarei campioane la acest turneu.",
               en: "The only defeat of the eventual champions at this tournament."),
        Famous(year: 2022, a: "MAR", b: "POR", sa: 1, sb: 0,
               ro: "Marocul a devenit prima echipă africană care ajunge în semifinalele unui Mondial.",
               en: "Morocco became the first African team to reach a World Cup semi-final."),
        Famous(year: 2022, a: "ARG", b: "FRA", sa: 3, sb: 3,
               ro: "Mbappé a reușit al doilea hat-trick dintr-o finală, după Hurst în 1966. Messi a marcat de două ori și a câștigat, în sfârșit, titlul mondial.",
               en: "Mbappé scored the second hat-trick in a final, after Hurst in 1966. Messi scored twice and finally won the World Cup."),
    ]
}

/// Panoul „Știai că?” de sub cardul meciului, după fluierul final.
struct MatchFactsPanel: View {
    let facts: [MatchFact]

    var body: some View {
        if !facts.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(tr("💡 Știai că?", "💡 Did you know?"))
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.hwcGold)
                ForEach(facts, id: \.self) { f in
                    HStack(alignment: .top, spacing: 8) {
                        Text(f.emoji).font(.system(size: 15))
                        Text(f.text).font(.system(size: 15)).foregroundStyle(Color.hwcText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
        }
    }
}
