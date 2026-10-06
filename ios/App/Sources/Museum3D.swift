import SwiftUI
import SceneKit
import simd

// MARK: - Vitrina 3D din Muzeu
// Pentru ediția deschisă: o minge stilizată după epoca ei (piele cu cusături, panouri negre, modele decorative,
// benzi colorate) și un tricou generic în culorile campioanei, fiecare pe câte un piedestal care se rotește încet.
// Nu sunt replici ale mingilor sau tricourilor oficiale (fără sigle, mărci sau desene originale) — doar stilul epocii.

struct Museum3DView: UIViewRepresentable {
    let year: Int
    let champion: String
    var rotate = true

    func makeCoordinator() -> MuseumScene { MuseumScene(year: year, champion: champion, rotate: rotate) }

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = context.coordinator.scene
        v.backgroundColor = .clear
        v.antialiasingMode = .multisampling4X
        v.allowsCameraControl = false
        v.isUserInteractionEnabled = false
        v.preferredFramesPerSecond = 30
        v.rendersContinuously = true
        v.isPlaying = true
        return v
    }

    func updateUIView(_ v: SCNView, context: Context) {}
}

final class MuseumScene {
    let scene = SCNScene()

    init(year: Int, champion: String, rotate: Bool) {
        let ball = Self.ball(year: year)
        ball.position = SCNVector3(-0.95, 0.98, 0)
        scene.rootNode.addChildNode(ball)

        let kit = KitColors.table[champion] ?? (0xF4F4F4, 0x222222)
        let shirt = Self.shirt(primary: KitColors.color(kit.0), secondary: KitColors.color(kit.1), year: year)
        shirt.position = SCNVector3(0.95, 1.05, 0)
        scene.rootNode.addChildNode(shirt)

        for x: Float in [-0.95, 0.95] { pedestal(x: x) }
        lights()
        camera()

        if rotate {
            ball.runAction(.repeatForever(.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 12)))
            shirt.runAction(.repeatForever(.rotateBy(x: 0, y: -2 * .pi, z: 0, duration: 16)))
        } else {
            shirt.eulerAngles = SCNVector3(0, -0.35, 0)
        }
    }

    // MARK: Materiale

    private static func material(_ c: UIColor, roughness: CGFloat = 0.6, metalness: CGFloat = 0) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = c
        m.lightingModel = .physicallyBased
        m.roughness.contents = roughness
        m.metalness.contents = metalness
        return m
    }

    private static func node(_ g: SCNGeometry, _ m: SCNMaterial, _ p: SCNVector3 = SCNVector3(0, 0, 0)) -> SCNNode {
        g.materials = [m]
        let n = SCNNode(geometry: g)
        n.position = p
        return n
    }

    // MARK: Mingea, după epocă

    static let radius: Float = 0.42

    /// cele 12 direcții ale unui icosaedru (centrele pentagoanelor unei mingi clasice)
    private static let icosa: [SIMD3<Float>] = {
        let p: Float = (1 + Float(5).squareRoot()) / 2
        var v: [SIMD3<Float>] = []
        for a: Float in [-1, 1] {
            for b: Float in [-p, p] {
                v.append(SIMD3(0, a, b)); v.append(SIMD3(a, b, 0)); v.append(SIMD3(b, 0, a))
            }
        }
        return v.map { simd_normalize($0) }
    }()

    /// un petic lipit pe suprafața mingii, orientat spre exterior
    private static func patch(_ g: SCNGeometry, _ m: SCNMaterial, dir: SIMD3<Float>, lift: Float = 0.002) -> SCNNode {
        let n = node(g, m)
        n.simdPosition = dir * (radius + lift)
        n.simdOrientation = simd_quatf(from: SIMD3(0, 1, 0), to: dir)
        return n
    }

    /// o cusătură sau o bandă: un inel pe un cerc mare al mingii, înclinat cu unghiurile date
    private static func band(_ m: SCNMaterial, tilt: (Float, Float), pipe: CGFloat, scale: Float = 1.004) -> SCNNode {
        let t = SCNTorus(ringRadius: CGFloat(radius * scale), pipeRadius: pipe)
        t.ringSegmentCount = 72
        let n = node(t, m)
        n.eulerAngles = SCNVector3(tilt.0, 0, tilt.1)
        return n
    }

    private static func hex(_ h: UInt32) -> UIColor { KitColors.color(h) }

    static func ball(year: Int) -> SCNNode {
        let root = SCNNode()
        let sphere = SCNSphere(radius: CGFloat(radius))
        sphere.segmentCount = 64

        switch year {
        case ...1938:
            // piele maro, panouri cusute și șiretul
            root.addChildNode(node(sphere, material(hex(0x8A5A2E), roughness: 0.85)))
            let seam = material(hex(0x4A2E14), roughness: 0.9)
            let seams: [(Float, Float)] = [(0, 0), (.pi / 2, 0), (0, .pi / 2), (.pi / 4, .pi / 4)]
            for t in seams {
                root.addChildNode(band(seam, tilt: t, pipe: 0.006))
            }
            let lace = material(hex(0xE8D8B8), roughness: 0.9)
            for i in -2...2 {
                let l = SCNBox(width: 0.012, height: 0.01, length: 0.07, chamferRadius: 0.004)
                let d = simd_normalize(SIMD3<Float>(Float(i) * 0.06, 1, 0))
                root.addChildNode(patch(l, lace, dir: d, lift: 0.004))
            }
        case ...1966:
            // piele mai deschisă, mai multe panouri, fără șiret
            root.addChildNode(node(sphere, material(hex(0xC08850), roughness: 0.75)))
            let seam = material(hex(0x6B4320), roughness: 0.9)
            for i in 0..<6 {
                let a = Float(i) * .pi / 6
                root.addChildNode(band(seam, tilt: (a, a * 0.5), pipe: 0.005))
            }
        case ...1974:
            // albă, cu pentagoane negre
            root.addChildNode(node(sphere, material(.white, roughness: 0.45)))
            let black = material(hex(0x111111), roughness: 0.5)
            for d in icosa {
                let p = SCNCylinder(radius: CGFloat(radius * 0.33), height: 0.006)
                p.radialSegmentCount = 5
                root.addChildNode(patch(p, black, dir: d))
            }
        case ...2002:
            // albă, cu motive decorative rotunde în culorile epocii
            let palette: [Int: (UInt32, UInt32)] = [
                1978: (0x111111, 0x111111), 1982: (0x111111, 0x444444), 1986: (0x1F5F3A, 0xB0262E),
                1990: (0x1A1A1A, 0x6B6B6B), 1994: (0x1E40AF, 0x0E7490), 1998: (0x1E3A8A, 0xC81E2C), 2002: (0xC9A227, 0xB91C1C),
            ]
            let (c1, c2) = palette[year] ?? (0x111111, 0x444444)
            root.addChildNode(node(sphere, material(.white, roughness: 0.4)))
            let m1 = material(hex(c1), roughness: 0.5), m2 = material(hex(c2), roughness: 0.5)
            for (i, d) in icosa.enumerated() {
                let ring = SCNTorus(ringRadius: CGFloat(radius * 0.27), pipeRadius: 0.012)
                root.addChildNode(patch(ring, i % 2 == 0 ? m1 : m2, dir: d, lift: -0.004))
                let dot = SCNCylinder(radius: CGFloat(radius * 0.1), height: 0.006)
                root.addChildNode(patch(dot, i % 2 == 0 ? m2 : m1, dir: d))
            }
        default:
            // minge modernă: albă, cu benzi colorate care o înconjoară
            let palette: [Int: [UInt32]] = [
                2006: [0x111111, 0xC9A227], 2010: [0x1D4ED8, 0xDC2626, 0x16A34A], 2014: [0x1E3A8A, 0xF97316, 0x16A34A],
                2018: [0x111111, 0x6B6B6B], 2022: [0xC9A227, 0x1E40AF, 0xB91C1C], 2026: [0xDC2626, 0x16A34A, 0x2563EB],
            ]
            let colors = palette[year] ?? [0x111111, 0xC9A227]
            root.addChildNode(node(sphere, material(.white, roughness: 0.35)))
            let tilts: [(Float, Float)] = [(0.5, 0.2), (-0.6, 1.1), (1.3, -0.7)]
            for (i, c) in colors.enumerated() {
                root.addChildNode(band(material(hex(c), roughness: 0.45), tilt: tilts[i % tilts.count], pipe: 0.03, scale: 0.985))
            }
        }
        root.childNodes.forEach { $0.castsShadow = true }
        return root
    }

    // MARK: Tricoul campioanei

    static func shirt(primary: UIColor, secondary: UIColor, year: Int) -> SCNNode {
        let root = SCNNode()
        let main = material(primary, roughness: 0.8)
        let trim = material(secondary, roughness: 0.7)

        root.addChildNode(node(SCNBox(width: 0.78, height: 0.88, length: 0.22, chamferRadius: 0.07), main))
        for s: Float in [-1, 1] {
            let sleeve = node(SCNBox(width: 0.38, height: 0.26, length: 0.2, chamferRadius: 0.06), main, SCNVector3(s * 0.5, 0.26, 0))
            sleeve.eulerAngles = SCNVector3(0, 0, s * -0.55)
            root.addChildNode(sleeve)
            let cuff = node(SCNBox(width: 0.05, height: 0.27, length: 0.21, chamferRadius: 0.02), trim, SCNVector3(s * 0.66, 0.15, 0))
            cuff.eulerAngles = SCNVector3(0, 0, s * -0.55)
            root.addChildNode(cuff)
        }
        let collar = SCNTorus(ringRadius: 0.13, pipeRadius: 0.028)
        let c = node(collar, trim, SCNVector3(0, 0.43, 0))
        c.scale = SCNVector3(1, 1, 0.75)
        root.addChildNode(c)

        // pe spate numărul 10, în față anul ediției — fără embleme
        func label(_ s: String, size: CGFloat, y: Float, back: Bool) {
            let t = SCNText(string: s, extrusionDepth: 0.6)
            t.font = UIFont.systemFont(ofSize: size, weight: .black)
            t.flatness = 0.2
            t.materials = [trim]
            let n = SCNNode(geometry: t)
            let (lo, hi) = n.boundingBox
            n.pivot = SCNMatrix4MakeTranslation((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, 0)
            n.scale = SCNVector3(0.02, 0.02, 0.02)
            n.position = SCNVector3(0, y, back ? -0.115 : 0.112)
            if back { n.eulerAngles = SCNVector3(0, Float.pi, 0) }
            root.addChildNode(n)
        }
        label("10", size: 22, y: 0.02, back: true)
        label(String(year), size: 6, y: 0.22, back: false)
        root.childNodes.forEach { $0.castsShadow = true }
        return root
    }

    // MARK: Piedestale, lumini, camera

    private func pedestal(x: Float) {
        let base = Self.node(SCNCylinder(radius: 0.5, height: 0.5), Self.material(UIColor(red: 0.11, green: 0.12, blue: 0.15, alpha: 1), roughness: 0.4),
                             SCNVector3(x, 0.25, 0))
        scene.rootNode.addChildNode(base)
        let rim = Self.node(SCNTorus(ringRadius: 0.5, pipeRadius: 0.018), Self.material(UIColor(red: 0.85, green: 0.68, blue: 0.3, alpha: 1), roughness: 0.25, metalness: 1),
                            SCNVector3(x, 0.5, 0))
        scene.rootNode.addChildNode(rim)
    }

    private func lights() {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light!.type = .ambient
        ambient.light!.intensity = 380
        scene.rootNode.addChildNode(ambient)

        // câte un reflector cald deasupra fiecărui exponat
        for x: Float in [-0.95, 0.95] {
            let target = SCNNode()
            target.position = SCNVector3(x, 0.9, 0)
            scene.rootNode.addChildNode(target)
            let spot = SCNNode()
            spot.light = SCNLight()
            spot.light!.type = .spot
            spot.light!.intensity = 1300
            spot.light!.spotInnerAngle = 25
            spot.light!.spotOuterAngle = 55
            spot.light!.color = UIColor(red: 1, green: 0.93, blue: 0.8, alpha: 1)
            spot.light!.castsShadow = true
            spot.light!.shadowRadius = 6
            spot.light!.shadowColor = UIColor(white: 0, alpha: 0.5)
            spot.position = SCNVector3(x * 0.6, 3.2, 1.8)
            spot.constraints = [SCNLookAtConstraint(target: target)]
            scene.rootNode.addChildNode(spot)
        }
        // o lumină rece din spate, pentru contur
        let back = SCNNode()
        back.light = SCNLight()
        back.light!.type = .directional
        back.light!.intensity = 350
        back.light!.color = UIColor(red: 0.7, green: 0.8, blue: 1, alpha: 1)
        back.eulerAngles = SCNVector3(-0.4, Float.pi, 0)
        scene.rootNode.addChildNode(back)
    }

    private func camera() {
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.camera!.fieldOfView = 34
        cam.position = SCNVector3(0, 1.55, 4.3)
        let target = SCNNode()
        target.position = SCNVector3(0, 0.78, 0)
        scene.rootNode.addChildNode(target)
        cam.constraints = [SCNLookAtConstraint(target: target)]
        scene.rootNode.addChildNode(cam)
    }
}
