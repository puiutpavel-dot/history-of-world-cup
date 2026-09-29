import Foundation

/// PRNG determinist — port bit-cu-bit al `mulberry32` din engine.js.
/// E `Codable`, deci o carieră salvată continuă exact de unde a rămas.
public struct Mulberry32: Codable, Hashable, Sendable {
    public private(set) var state: UInt32

    public init(seed: UInt32) {
        state = seed
    }

    /// Echivalentul apelului `rng()` din JS: un Double în [0, 1).
    public mutating func next() -> Double {
        state = state &+ 0x6D2B_79F5
        var t = (state ^ (state >> 15)) &* (1 | state)
        t = (t &+ ((t ^ (t >> 7)) &* (61 | t))) ^ t
        return Double(t ^ (t >> 14)) / 4_294_967_296.0
    }

    /// `randInt(rng, min, max)` din JS (ambele capete incluse).
    public mutating func int(_ min: Int, _ max: Int) -> Int {
        Int((next() * Double(max - min + 1)).rounded(.down)) + min
    }

    /// `choice(rng, arr)` din JS. Consumă mereu o valoare, chiar și pentru
    /// un array gol (ca în JS), ca secvența să rămână sincronizată.
    public mutating func choice<T>(_ array: [T]) -> T? {
        let r = next()
        if array.isEmpty { return nil }
        return array[Int((r * Double(array.count)).rounded(.down))]
    }
}

/// `seedFor(str)` din app.js — FNV-1a pe unități UTF-16 (ca `charCodeAt`).
public func seedFor(_ string: String) -> UInt32 {
    var h: UInt32 = 2_166_136_261
    for unit in string.utf16 {
        h ^= UInt32(unit)
        h = h &* 16_777_619
    }
    return h
}

/// `Math.round` din JavaScript (jumătățile se rotunjesc spre +∞).
public func jsRound(_ x: Double) -> Int {
    let f = x.rounded(.down)
    return Int(x - f >= 0.5 ? f + 1 : f)
}
