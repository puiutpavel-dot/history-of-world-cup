import SwiftUI
import SceneKit
import WorldCupCore

// MARK: - Terenul 3D al meciului
// Un teren văzut din tribună, cu 22 de jucători generici (fără fețe sau nume reale) în culorile echipelor.
// Totul e calculat din minutul curent: mingea circulă, echipele se mișcă după minge, iar la fiecare gol real
// mingea pleacă spre poarta corectă și intră în plasă la minutul golului. Echipa 1 (gazdele cardului) atacă spre dreapta.

/// Culorile echipamentelor (principală, secundară) — aproximative, doar ca să se distingă echipele.
enum KitColors {
    static let table: [String: (UInt32, UInt32)] = [
        "BRA": (0xFFDC02, 0x0047AB), "ARG": (0x75AADB, 0xFFFFFF), "GER": (0xF4F4F4, 0x111111), "ITA": (0x1F4FB0, 0xFFFFFF),
        "URU": (0x5CBFEB, 0x111111), "ENG": (0xF4F4F4, 0x1D2B5C), "FRA": (0x1D2B5C, 0xFFFFFF), "NED": (0xFF6C0C, 0xFFFFFF),
        "HUN": (0xD7141A, 0xFFFFFF), "ESP": (0xC60B1E, 0xFFC400), "POR": (0xB5121B, 0x006600), "SWE": (0xFECC00, 0x005B99),
        "BEL": (0xD00027, 0x111111), "CRO": (0xE21A23, 0xFFFFFF), "POL": (0xF4F4F4, 0xDC143C), "TCH": (0xD7141A, 0xFFFFFF),
        "MEX": (0x006847, 0xFFFFFF), "USA": (0xF4F4F4, 0x1D2B5C), "JPN": (0x1B2E7C, 0xFFFFFF), "MAR": (0xC1272D, 0x006233),
        "KOR": (0xE30613, 0xFFFFFF), "TUR": (0xE30A17, 0xFFFFFF), "AUT": (0xF4F4F4, 0xED2939), "PER": (0xF4F4F4, 0xD91023),
        "ROU": (0xFCD116, 0x002B7F), "YUG": (0x1E3A8A, 0xFFFFFF), "BUL": (0xF4F4F4, 0x00966E), "UAE": (0xF4F4F4, 0x00732F),
        "COL": (0xFCD116, 0x003893), "RSA": (0xFFB612, 0x007A4D), "KSA": (0xF4F4F4, 0x006C35), "DEN": (0xC8102E, 0xFFFFFF),
        "PAR": (0xD52B1E, 0xFFFFFF), "CHN": (0xDE2910, 0xFFDE00), "CRC": (0xCE1126, 0x002B7F), "GHA": (0xF4F4F4, 0x111111),
        "ALG": (0xF4F4F4, 0x006233), "AUS": (0xFFCD00, 0x00843D), "RUS": (0xF4F4F4, 0xD52B1E), "TUN": (0xE70013, 0xFFFFFF),
        "SUI": (0xD52B1E, 0xFFFFFF), "CHI": (0xD52B1E, 0x0039A6), "ANG": (0xCC092F, 0x111111), "BIH": (0x002395, 0xFECB00),
        "BOL": (0x007934, 0xFFFFFF), "CAN": (0xD80621, 0xFFFFFF), "CIV": (0xF77F00, 0x009E60), "CMR": (0x007A5E, 0xCE1126),
        "CUB": (0x002A8F, 0xCF142B), "CZE": (0xD7141A, 0x11457E), "DEI": (0xFF4F00, 0xFFFFFF), "ECU": (0xFFDD00, 0x034EA2),
        "EGY": (0xCE1126, 0xFFFFFF), "GDR": (0x1E3A8A, 0xFFFFFF), "GRE": (0x0D5EAF, 0xFFFFFF), "HAI": (0x00209F, 0xD21034),
        "HON": (0xF4F4F4, 0x0073CF), "IRL": (0x169B62, 0xFFFFFF), "IRN": (0xF4F4F4, 0xDA0000), "IRQ": (0xF4F4F4, 0x007A3D),
        "ISL": (0x02529C, 0xFFFFFF), "ISR": (0x0038B8, 0xFFFFFF), "JAM": (0xFED100, 0x009B3A), "KUW": (0x007A3D, 0xFFFFFF),
        "NGA": (0x008751, 0xFFFFFF), "NIR": (0x00843D, 0xFFFFFF), "NOR": (0xBA0C2F, 0xFFFFFF), "NZL": (0xF4F4F4, 0x111111),
        "PAN": (0xD21034, 0xFFFFFF), "PRK": (0xD21034, 0xFFFFFF), "QAT": (0x8A1538, 0xFFFFFF), "SCG": (0x1E3A8A, 0xFFFFFF),
        "SCO": (0x1D2B5C, 0xFFFFFF), "SEN": (0xF4F4F4, 0x00853F), "SLV": (0x0F47AF, 0xFFFFFF), "SRB": (0xC6363C, 0xFFFFFF),
        "SVK": (0x0B4EA2, 0xFFFFFF), "SVN": (0xF4F4F4, 0x005DA4), "TOG": (0xFFCE00, 0x006A4E), "TRI": (0xDA1A35, 0x111111),
        "UKR": (0xFFD500, 0x005BBB), "URS": (0xD52B1E, 0xFFFFFF), "WAL": (0xC8102E, 0xFFFFFF), "ZAI": (0x007A3D, 0xFCD116),
        "COD": (0x007FFF, 0xF7D618), "CPV": (0x003893, 0xFFFFFF), "CUW": (0x002B7F, 0xF9E814), "JOR": (0xF4F4F4, 0xCE1126),
        "UZB": (0xF4F4F4, 0x1EB53A),
    ]

    static func color(_ hex: UInt32) -> UIColor {
        UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }

    private static func distance(_ a: UInt32, _ b: UInt32) -> Double {
        func c(_ h: UInt32, _ s: UInt32) -> Double { Double((h >> s) & 0xFF) }
        let dr = c(a, 16) - c(b, 16), dg = c(a, 8) - c(b, 8), db = c(a, 0) - c(b, 0)
        return (dr * dr + dg * dg + db * db).squareRoot()
    }

    /// culorile celor două echipe; oaspeții trec pe echipamentul secundar dacă seamănă prea mult
    static func pair(home: String, away: String) -> (UIColor, UIColor) {
        let h = table[home] ?? (0xF4F4F4, 0x222222)
        var a = table[away] ?? (0x222222, 0xF4F4F4)
        if distance(h.0, a.0) < 120 { a = (a.1, a.0) }
        if distance(h.0, a.0) < 120 { a = (distance(h.0, 0xF4F4F4) > 200 ? 0xF4F4F4 : 0x222222, a.1) }
        return (color(h.0), color(a.0))
    }
}

struct Pitch3DView: UIViewRepresentable {
    /// minutul de pe cronometru (0 … 90 sau 120)
    let minute: Double
    let goals: [TrackGoal]
    let home: String
    let away: String
    /// loviturile de departajare: mingea stă la punctul de la 11 metri
    var shootout = false

    func makeCoordinator() -> PitchScene { PitchScene(home: home, away: away) }

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = context.coordinator.scene
        v.backgroundColor = .clear
        v.antialiasingMode = .multisampling4X
        v.allowsCameraControl = false
        v.isUserInteractionEnabled = false
        v.rendersContinuously = true
        v.isPlaying = true
        context.coordinator.update(minute: minute, goals: goals, shootout: shootout, animated: false)
        return v
    }

    func updateUIView(_ v: SCNView, context: Context) {
        context.coordinator.update(minute: minute, goals: goals, shootout: shootout, animated: true)
    }
}

final class PitchScene {
    let scene = SCNScene()
    private var players: [SCNNode] = []   // 0…10 echipa 1, 11…21 echipa 2
    private let ball = SCNNode()
    private var nets: [SCNNode] = []      // [poarta din stânga, poarta din dreapta]
    private var celebrated = Set<Double>()
    private let seed: Double

    // terenul: 10,5 × 6,8 unități (1 unitate = 10 m)
    static let hx: Float = 5.25, hz: Float = 3.4

    /// așezarea 4-4-2 a echipei care atacă spre dreapta (x de la -1 = poarta proprie la +1)
    private static let shape: [(Float, Float)] = [
        (-0.95, 0),
        (-0.6, -0.62), (-0.66, -0.21), (-0.66, 0.21), (-0.6, 0.62),
        (-0.22, -0.66), (-0.27, -0.2), (-0.27, 0.2), (-0.22, 0.66),
        (0.12, -0.24), (0.12, 0.24),
    ]

    init(home: String, away: String) {
        // aceeași „mișcare” la fiecare redare a meciului
        seed = Double((home + away).unicodeScalars.reduce(0) { ($0 * 31 + Int($1.value)) % 997 }) / 100
        build(colors: KitColors.pair(home: home, away: away))
    }

    private func material(_ c: UIColor, emission: UIColor? = nil) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = c
        m.lightingModel = .physicallyBased
        m.roughness.contents = 0.8
        if let emission { m.emission.contents = emission }
        return m
    }

    private func add(_ g: SCNGeometry, _ c: UIColor, at p: SCNVector3, to parent: SCNNode? = nil) -> SCNNode {
        g.materials = [material(c)]
        let n = SCNNode(geometry: g)
        n.position = p
        (parent ?? scene.rootNode).addChildNode(n)
        return n
    }

    private func build(colors: (UIColor, UIColor)) {
        let hx = Self.hx, hz = Self.hz
        let root = scene.rootNode

        // gazonul cu dungi, puțin mai mare decât terenul
        let stripes = 12
        for i in 0..<stripes {
            let w = (hx * 2 + 1.2) / Float(stripes)
            let x = -hx - 0.6 + w * (Float(i) + 0.5)
            let c = i % 2 == 0 ? UIColor(red: 0.13, green: 0.47, blue: 0.2, alpha: 1) : UIColor(red: 0.16, green: 0.53, blue: 0.23, alpha: 1)
            _ = add(SCNBox(width: CGFloat(w), height: 0.02, length: CGFloat(hz * 2 + 1.2), chamferRadius: 0), c, at: SCNVector3(x, -0.01, 0))
        }

        // liniile terenului
        let white = UIColor(white: 0.95, alpha: 1)
        func line(_ x: Float, _ z: Float, _ w: Float, _ l: Float) {
            _ = add(SCNBox(width: CGFloat(w), height: 0.005, length: CGFloat(l), chamferRadius: 0), white, at: SCNVector3(x, 0.003, z))
        }
        let t: Float = 0.035
        line(0, -hz, hx * 2, t); line(0, hz, hx * 2, t)
        line(-hx, 0, t, hz * 2); line(hx, 0, t, hz * 2)
        line(0, 0, t, hz * 2)
        let circle = SCNTorus(ringRadius: 0.915, pipeRadius: 0.018)
        let c = add(circle, white, at: SCNVector3(0, 0.003, 0))
        c.scale = SCNVector3(1, 0.2, 1)
        for s: Float in [-1, 1] {
            // careul mare (16,5 m) și careul mic (5,5 m)
            line(s * (hx - 1.65), 0, t, 4.03); line(s * (hx - 0.825), -2.015, 1.65, t); line(s * (hx - 0.825), 2.015, 1.65, t)
            line(s * (hx - 0.55), 0, t, 1.83); line(s * (hx - 0.275), -0.915, 0.55, t); line(s * (hx - 0.275), 0.915, 0.55, t)
            _ = add(SCNCylinder(radius: 0.03, height: 0.005), white, at: SCNVector3(s * (hx - 1.1), 0.003, 0))

            // poarta: bare, transversală și plasa
            let post = UIColor.white
            for z: Float in [-0.366, 0.366] {
                _ = add(SCNCylinder(radius: 0.02, height: 0.244), post, at: SCNVector3(s * hx, 0.122, z))
            }
            let bar = add(SCNCylinder(radius: 0.02, height: 0.732), post, at: SCNVector3(s * hx, 0.244, 0))
            bar.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
            let netGeo = SCNBox(width: 0.2, height: 0.244, length: 0.732, chamferRadius: 0)
            let netMat = material(UIColor(white: 1, alpha: 0.28))
            netMat.isDoubleSided = true
            netMat.transparency = 0.35
            netGeo.materials = [netMat]
            let net = SCNNode(geometry: netGeo)
            net.position = SCNVector3(s * (hx + 0.1), 0.122, 0)
            root.addChildNode(net)
            nets.append(net)
        }

        // jucătorii: capsulă + cap, în culorile echipei (portarii în verde / negru)
        for team in 0..<2 {
            for i in 0..<11 {
                let kit = i == 0 ? (team == 0 ? UIColor(red: 0.1, green: 0.6, blue: 0.35, alpha: 1) : UIColor(white: 0.12, alpha: 1)) : (team == 0 ? colors.0 : colors.1)
                let body = SCNCapsule(capRadius: 0.075, height: 0.32)
                body.materials = [material(kit)]
                let n = SCNNode(geometry: body)
                let head = SCNSphere(radius: 0.055)
                head.materials = [material(UIColor(red: 0.85, green: 0.7, blue: 0.58, alpha: 1))]
                let h = SCNNode(geometry: head)
                h.position = SCNVector3(0, 0.21, 0)
                n.addChildNode(h)
                n.castsShadow = true
                root.addChildNode(n)
                players.append(n)
            }
        }

        // mingea
        let b = SCNSphere(radius: 0.055)
        b.materials = [material(.white)]
        ball.geometry = b
        ball.castsShadow = true
        root.addChildNode(ball)

        // lumina și camera (din tribună, în spatele liniei de margine)
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light!.type = .ambient
        ambient.light!.intensity = 450
        ambient.name = "ambient"
        root.addChildNode(ambient)
        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light!.type = .directional
        sun.light!.intensity = 900
        sun.light!.castsShadow = true
        sun.light!.shadowRadius = 4
        sun.light!.shadowColor = UIColor(white: 0, alpha: 0.45)
        sun.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 6, 0)
        sun.name = "sun"
        root.addChildNode(sun)

        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.camera!.fieldOfView = 40
        cam.position = SCNVector3(0, 6.6, 7.4)
        cam.name = "pitchCamera"
        let target = SCNNode()
        target.position = SCNVector3(0, 0, 0.25)
        root.addChildNode(target)
        cam.constraints = [SCNLookAtConstraint(target: target)]
        root.addChildNode(cam)
    }

    // MARK: Mișcarea, din minutul curent

    private static func ease(_ f: Double) -> Double { f * f * (3 - 2 * f) }

    /// poziția mingii (x, înălțime, z) la minutul dat
    private func ballAt(_ m: Double, goals: [TrackGoal]) -> (Double, Double, Double) {
        let hx = Double(Self.hx)
        let shot = 3.0, inNet = 2.0
        for g in goals {
            let c = g.clock, side: Double = g.t == 1 ? 1 : -1
            if m > c - shot && m <= c {
                let f = Self.ease((m - (c - shot)) / shot)
                let z0 = sin(c * 1.3 + seed) * 1.6, z1 = sin(c * 2.1) * 0.25
                let x = side * (hx - 2.2 + f * 2.35)
                return (x, 0.06 + sin(f * .pi) * 0.35, z0 + (z1 - z0) * f)
            }
            if m > c && m <= c + inNet {
                return (side * (hx + 0.12), 0.06, sin(c * 2.1) * 0.25)
            }
        }
        // după fiecare gol (și la început) mingea pleacă de la centru
        let kickoff = goals.map { $0.clock + inNet }.filter { $0 <= m }.max() ?? 0
        let w = min(1, (m - kickoff) / 2.5)
        let x = 3.7 * sin(m * 0.21 + seed) * cos(m * 0.067 + seed * 0.5)
        let z = 2.5 * sin(m * 0.17 + seed * 1.7)
        return (x * w, 0.06, z * w)
    }

    func update(minute: Double, goals: [TrackGoal], shootout: Bool, animated: Bool) {
        let hx = Double(Self.hx), hz = Double(Self.hz)
        var b = ballAt(minute, goals: goals)
        if shootout { b = (hx - 1.1, 0.06, 0) }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animated ? 0.09 : 0
        ball.position = SCNVector3(Float(b.0), Float(b.1), Float(b.2))

        for team in 0..<2 {
            let dir: Double = team == 0 ? 1 : -1
            // cel mai apropiat jucător de câmp merge spre minge
            var nearest = 1, best = Double.greatestFiniteMagnitude
            var spots: [(Double, Double)] = []
            for (i, s) in Self.shape.enumerated() {
                var x = Double(s.0) * dir * hx * 0.9
                var z = Double(s.1) * hz * 0.85
                if i == 0 {
                    z = max(-0.3, min(0.3, b.2 * 0.12))
                } else {
                    x += b.0 * 0.38
                    z += b.2 * 0.15 + sin(minute * 0.9 + Double(i) * 1.7 + seed + Double(team)) * 0.12
                    let d = (x - b.0) * (x - b.0) + (z - b.2) * (z - b.2)
                    if d < best { best = d; nearest = i }
                }
                spots.append((x, z))
            }
            if !shootout {
                spots[nearest].0 += (b.0 - spots[nearest].0) * 0.75
                spots[nearest].1 += (b.2 - spots[nearest].1) * 0.75
            }
            for (i, p) in spots.enumerated() {
                players[team * 11 + i].position = SCNVector3(Float(p.0), 0.235, Float(p.1))
            }
        }
        SCNTransaction.commit()

        // golul: plasa se luminează și apar scântei aurii, o singură dată pentru fiecare gol
        for g in goals where minute >= g.clock && minute < g.clock + 1.5 && !celebrated.contains(g.clock) && animated {
            celebrated.insert(g.clock)
            celebrate(net: nets[g.t == 1 ? 1 : 0])
        }
        if minute < 0.5 { celebrated.removeAll() }
    }

    private func celebrate(net: SCNNode) {
        let flash = SCNAction.sequence([
            SCNAction.customAction(duration: 0.01) { n, _ in n.geometry?.firstMaterial?.emission.contents = UIColor(red: 1, green: 0.8, blue: 0.3, alpha: 1) },
            SCNAction.scale(to: 1.25, duration: 0.15),
            SCNAction.scale(to: 1, duration: 0.25),
            SCNAction.wait(duration: 0.5),
            SCNAction.customAction(duration: 0.01) { n, _ in n.geometry?.firstMaterial?.emission.contents = UIColor.black },
        ])
        net.runAction(flash)

        let ps = SCNParticleSystem()
        ps.birthRate = 400
        ps.emissionDuration = 0.25
        ps.loops = false
        ps.particleLifeSpan = 0.9
        ps.particleVelocity = 2.2
        ps.particleVelocityVariation = 1
        ps.spreadingAngle = 70
        ps.particleSize = 0.035
        ps.particleColor = UIColor(red: 1, green: 0.82, blue: 0.3, alpha: 1)
        ps.particleColorVariation = SCNVector4(0.08, 0.2, 0.2, 0)
        ps.acceleration = SCNVector3(0, -2.5, 0)
        ps.isAffectedByGravity = false
        ps.blendMode = .additive
        let emitter = SCNNode()
        emitter.position = SCNVector3(net.position.x, 0.3, net.position.z)
        emitter.addParticleSystem(ps)
        scene.rootNode.addChildNode(emitter)
        emitter.runAction(SCNAction.sequence([SCNAction.wait(duration: 1.5), SCNAction.removeFromParentNode()]))
    }
}
