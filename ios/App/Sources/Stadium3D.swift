import SwiftUI
import SceneKit
import WorldCupCore

// MARK: - Stadionul 3D din meniu
// Un stadion generic, noaptea: terenul din meci (cu cei 22 de jucători care joacă un meci demonstrativ în buclă),
// tribune în trepte pline de spectatori, acoperișuri pe laturile lungi și patru stâlpi de nocturnă în colțuri.
// Camera se rotește încet în jurul stadionului (oprită dacă „Reducere mișcare” e activ).

struct Stadium3DView: UIViewRepresentable {
    var rotate = true

    func makeCoordinator() -> StadiumScene { StadiumScene(rotate: rotate) }

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = context.coordinator.scene
        v.pointOfView = context.coordinator.camera
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

final class StadiumScene {
    let pitch: PitchScene
    var scene: SCNScene { pitch.scene }
    let camera = SCNNode()
    private let pivot = SCNNode()

    /// meciul demonstrativ: 90 de minute în 75 de secunde, cu cinci goluri
    private static let demoGoals: [TrackGoal] = {
        let json = #"[{"m":"18","t":1,"n":""},{"m":"37","t":2,"n":""},{"m":"66","t":1,"n":""},{"m":"71","t":1,"n":""},{"m":"86","t":1,"n":""}]"#
        return (try? JSONDecoder().decode([TrackGoal].self, from: Data(json.utf8))) ?? []
    }()
    private static let loopSeconds = 75.0

    init(rotate: Bool) {
        pitch = PitchScene(home: "BRA", away: "ITA")
        nightLighting()
        buildStands()
        buildRoofs()
        buildFloodlights()
        buildSurroundings()
        buildCamera(rotate: rotate)
        startMatch()
    }

    // MARK: Materiale

    private func material(_ c: UIColor, roughness: CGFloat = 0.85) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = c
        m.lightingModel = .physicallyBased
        m.roughness.contents = roughness
        return m
    }

    /// spectatorii: capete și tricouri colorate pe fond întunecat, repetate de-a lungul treptei
    private static let crowdImage: UIImage = {
        let size = CGSize(width: 256, height: 32)
        var rng = SystemRandomNumberGenerator()
        let palette: [UIColor] = [
            UIColor(red: 0.98, green: 0.84, blue: 0.1, alpha: 1), UIColor(red: 0.1, green: 0.55, blue: 0.25, alpha: 1),
            UIColor(red: 0.15, green: 0.3, blue: 0.75, alpha: 1), UIColor(white: 0.92, alpha: 1),
            UIColor(red: 0.8, green: 0.15, blue: 0.15, alpha: 1), UIColor(white: 0.25, alpha: 1),
            UIColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1),
        ]
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            for row in 0..<2 {
                var x: CGFloat = CGFloat(row) * 3
                while x < size.width {
                    let y = CGFloat(row) * 16 + 2
                    palette[Int.random(in: 0..<palette.count, using: &rng)].setFill()
                    ctx.fill(CGRect(x: x, y: y + 5, width: 5, height: 8))
                    UIColor(red: 0.85, green: 0.68, blue: 0.55, alpha: 1).setFill()
                    ctx.cgContext.fillEllipse(in: CGRect(x: x + 0.5, y: y, width: 4, height: 4))
                    x += CGFloat(Int.random(in: 6...8, using: &rng))
                }
            }
        }
    }()

    private func crowdMaterial(length: Float) -> SCNMaterial {
        let m = material(.white, roughness: 1)
        m.diffuse.contents = Self.crowdImage
        m.diffuse.wrapS = .repeat
        m.diffuse.wrapT = .repeat
        m.diffuse.contentsTransform = SCNMatrix4MakeScale(max(1, length / 1.6), 1, 1)
        return m
    }

    // MARK: Construcția

    private func nightLighting() {
        let root = scene.rootNode
        root.childNode(withName: "ambient", recursively: false)?.light?.intensity = 220
        if let sun = root.childNode(withName: "sun", recursively: false)?.light {
            sun.intensity = 380
            sun.color = UIColor(red: 0.75, green: 0.82, blue: 1, alpha: 1)
        }
    }

    // stadionul: tribunele încep la 0,9 unități de marginea gazonului
    private let innerX: Float = 6.5, innerZ: Float = 4.7
    private let rows = 9
    private let depth: Float = 0.34, rise: Float = 0.23

    private func buildStands() {
        let concrete = material(UIColor(white: 0.32, alpha: 1))
        for r in 0..<rows {
            let h = rise * Float(r + 1)
            let off = depth * Float(r) + depth / 2
            // laturile lungi (± z) și peluzele (± x); colțurile rămân libere pentru stâlpii de nocturnă
            for s: Float in [-1, 1] {
                let lenLong = innerX * 2 - 0.6 + Float(r) * 0.22
                let long = SCNBox(width: CGFloat(lenLong), height: CGFloat(h), length: CGFloat(depth), chamferRadius: 0)
                let crowdL = crowdMaterial(length: lenLong)
                // ordinea fețelor SCNBox: față (+z), dreapta (+x), spate (-z), stânga (-x), sus, jos
                long.materials = s > 0 ? [concrete, concrete, crowdL, concrete, crowdL, concrete]
                                       : [crowdL, concrete, concrete, concrete, crowdL, concrete]
                let nl = SCNNode(geometry: long)
                nl.position = SCNVector3(0, h / 2, s * (innerZ + off))
                scene.rootNode.addChildNode(nl)

                let lenEnd = innerZ * 2 - 0.8 + Float(r) * 0.22
                let end = SCNBox(width: CGFloat(depth), height: CGFloat(h * 0.85), length: CGFloat(lenEnd), chamferRadius: 0)
                let crowdE = crowdMaterial(length: lenEnd)
                end.materials = s > 0 ? [concrete, concrete, concrete, crowdE, crowdE, concrete]
                                      : [concrete, crowdE, concrete, concrete, crowdE, concrete]
                let ne = SCNNode(geometry: end)
                ne.position = SCNVector3(s * (innerX + off), h * 0.85 / 2, 0)
                scene.rootNode.addChildNode(ne)
            }
        }
        // panourile publicitare din jurul terenului: o bandă luminoasă, fără mărci
        let board = material(UIColor(red: 0.05, green: 0.1, blue: 0.25, alpha: 1))
        board.emission.contents = UIColor(red: 0.1, green: 0.35, blue: 0.75, alpha: 1)
        for s: Float in [-1, 1] {
            let a = SCNBox(width: 10.4, height: 0.09, length: 0.03, chamferRadius: 0)
            a.materials = [board]
            let na = SCNNode(geometry: a)
            na.position = SCNVector3(0, 0.045, s * (innerZ - 0.35))
            scene.rootNode.addChildNode(na)
        }
    }

    private func buildRoofs() {
        let top = rise * Float(rows)
        let roofMat = material(UIColor(white: 0.85, alpha: 1), roughness: 0.5)
        let strip = material(.white)
        strip.emission.contents = UIColor(white: 0.9, alpha: 1)
        let column = material(UIColor(white: 0.5, alpha: 1))
        let span = depth * Float(rows)
        for s: Float in [-1, 1] {
            let roof = SCNBox(width: CGFloat(innerX * 2 + 1.2), height: 0.06, length: CGFloat(span * 0.75), chamferRadius: 0.02)
            roof.materials = [roofMat]
            let n = SCNNode(geometry: roof)
            n.position = SCNVector3(0, top + 0.95, s * (innerZ + span * 0.62))
            n.eulerAngles = SCNVector3(s * 0.08, 0, 0)
            scene.rootNode.addChildNode(n)
            // marginea acoperișului, luminată
            let edge = SCNBox(width: CGFloat(innerX * 2 + 1.2), height: 0.04, length: 0.04, chamferRadius: 0)
            edge.materials = [strip]
            let e = SCNNode(geometry: edge)
            e.position = SCNVector3(0, top + 0.89, s * (innerZ + span * 0.25))
            scene.rootNode.addChildNode(e)
            for x in stride(from: -innerX, through: innerX, by: innerX / 2) {
                let c = SCNCylinder(radius: 0.04, height: CGFloat(top + 0.95))
                c.materials = [column]
                let cn = SCNNode(geometry: c)
                cn.position = SCNVector3(x, (top + 0.95) / 2, s * (innerZ + span))
                scene.rootNode.addChildNode(cn)
            }
        }
    }

    private func buildFloodlights() {
        let pole = material(UIColor(white: 0.45, alpha: 1), roughness: 0.4)
        let lamp = material(.white)
        lamp.emission.contents = UIColor(red: 1, green: 0.97, blue: 0.88, alpha: 1)
        let target = SCNNode()
        scene.rootNode.addChildNode(target)
        let height: Float = 5.4
        for (sx, sz) in [(Float(-1), Float(-1)), (1, -1), (-1, 1), (1, 1)] {
            let base = SCNVector3(sx * (innerX + 1.3), 0, sz * (innerZ + 1.3))
            let p = SCNCylinder(radius: 0.07, height: CGFloat(height))
            p.materials = [pole]
            let pn = SCNNode(geometry: p)
            pn.position = SCNVector3(base.x, height / 2, base.z)
            scene.rootNode.addChildNode(pn)

            // capul stâlpului: un panou de lămpi îndreptat spre centrul terenului
            let head = SCNNode()
            head.position = SCNVector3(base.x, height + 0.25, base.z)
            head.constraints = [SCNLookAtConstraint(target: target)]
            scene.rootNode.addChildNode(head)
            let panel = SCNBox(width: 1.1, height: 0.6, length: 0.08, chamferRadius: 0.02)
            panel.materials = [pole, pole, lamp, pole, pole, pole]
            head.addChildNode(SCNNode(geometry: panel))
            // lumina propriu-zisă (fără umbre, ca să nu încarce telefonul)
            let spot = SCNLight()
            spot.type = .spot
            spot.intensity = 520
            spot.spotInnerAngle = 30
            spot.spotOuterAngle = 70
            spot.attenuationStartDistance = 8
            spot.attenuationEndDistance = 30
            spot.color = UIColor(red: 1, green: 0.97, blue: 0.9, alpha: 1)
            head.light = spot
        }
    }

    private func buildSurroundings() {
        // terenul din jurul stadionului, aproape negru, ca să se piardă în fundalul meniului
        let ground = SCNCylinder(radius: 30, height: 0.02)
        ground.materials = [material(UIColor(red: 0.04, green: 0.05, blue: 0.08, alpha: 1))]
        let g = SCNNode(geometry: ground)
        g.position = SCNVector3(0, -0.03, 0)
        scene.rootNode.addChildNode(g)
    }

    private func buildCamera(rotate: Bool) {
        let cam = SCNCamera()
        cam.fieldOfView = 36
        cam.zNear = 0.5
        cam.zFar = 80
        cam.wantsHDR = true
        cam.bloomIntensity = 0.7
        cam.bloomThreshold = 0.75
        cam.bloomBlurRadius = 6
        camera.camera = cam
        camera.position = SCNVector3(0, 7.2, 14.5)
        let target = SCNNode()
        target.position = SCNVector3(0, 0.6, 0)
        scene.rootNode.addChildNode(target)
        camera.constraints = [SCNLookAtConstraint(target: target)]
        pivot.addChildNode(camera)
        // o ușoară înclinare, ca stadionul să nu fie văzut perfect din lateral
        pivot.eulerAngles = SCNVector3(0, -0.35, 0)
        scene.rootNode.addChildNode(pivot)
        if rotate {
            pivot.runAction(.repeatForever(.rotateBy(x: 0, y: -2 * .pi, z: 0, duration: 120)))
        }
    }

    private func startMatch() {
        let goals = Self.demoGoals
        let seconds = Self.loopSeconds
        let driver = SCNNode()
        scene.rootNode.addChildNode(driver)
        let loop = SCNAction.customAction(duration: seconds) { [weak p = pitch] _, elapsed in
            let minute = Double(elapsed) / seconds * 92
            p?.update(minute: min(90, minute), goals: goals, shootout: false, animated: true)
        }
        driver.runAction(.repeatForever(loop))
    }
}
