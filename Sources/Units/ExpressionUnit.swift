import Foundation

/// A mathematical unit that can be combined, multiplied, and divided.
public struct ExpressionUnit:  Hashable, Codable, Sendable, CustomStringConvertible {
    
    /// The explicitly assigned symbol (e.g. "N", "m/sec²"). If nil, the symbol is auto-generated.
    public let explicitSymbol: String?
    
    /// The algebraic terms making up this unit, mapping symbol -> exponent (e.g., ["m": 1, "sec": -2])
    public let terms: [String: Int]
    
    public let signature: DimensionalSignature
    public var offsetToSI: Double = 0.0
    
    public var isUnitless: Bool {
        self.signature.isDimensionless
    }
    
    // MARK: - Initializers
    
    /// Internal initializer for combining units algebraically
    private init(explicitSymbol: String? = nil, terms: [String: Int], signature: DimensionalSignature, offsetToSI: Double = 0.0) {
        self.explicitSymbol = explicitSymbol
        self.terms = terms
        self.signature = signature
        self.offsetToSI = offsetToSI
    }
    
    /// Standard Initializer for Base Units (e.g., meters, seconds, kg)
    public init(symbol: String, signature: DimensionalSignature, offsetToSI: Double = 0.0) {
        self.explicitSymbol = symbol
        self.terms = [symbol: 1]
        self.signature = signature
        self.offsetToSI = offsetToSI
    }
    
    /// Alias Initializer: Wraps a mathematically derived unit with a custom explicit symbol (e.g., "N")
    public init(symbol: String, wrapping unit: ExpressionUnit) {
        self.explicitSymbol = symbol
        self.terms = unit.terms
        self.signature = unit.signature
        self.offsetToSI = unit.offsetToSI
    }
    
    // MARK: - Symbol Generation
    
    public var canonicalSymbol: String {
        ExpressionUnit.buildCanonicalSymbol(from: terms)
    }
    
    public var symbol: String {
        if let explicitSymbol { return explicitSymbol }
        return ExpressionUnit.buildCanonicalSymbol(from: terms)
    }
    
    public var description: String { symbol }
    public var scaleToSI: Double { signature.scaleToSI }
    
    // MARK: - Operators (Algebraic Simplification)
    
    public static func * (lhs: ExpressionUnit, rhs: ExpressionUnit) -> ExpressionUnit {
        if lhs.isUnitless {
            return rhs
        }
        if rhs.isUnitless {
            return lhs
        }
        let mergedTerms = mergeTerms(lhs.terms, rhs.terms, operation: +)
        return ExpressionUnit(
            explicitSymbol: nil, // Clears explicit symbol so canonical string takes over
            terms: mergedTerms,
            signature: lhs.signature * rhs.signature
        )
    }
    
    public static func / (lhs: ExpressionUnit, rhs: ExpressionUnit) -> ExpressionUnit {
        if lhs.isEquivalent(to: rhs) { return StandardUnits.none }
        
        let mergedTerms = mergeTerms(lhs.terms, rhs.terms, operation: -)
        return ExpressionUnit(
            explicitSymbol: nil,
            terms: mergedTerms,
            signature: lhs.signature / rhs.signature
        )
    }
    
    // MARK: - Equivalence & Hashing
    
    
    public static func == (lhs: ExpressionUnit, rhs: ExpressionUnit) -> Bool {
        lhs.symbol == rhs.symbol  &&
        lhs.signature == rhs.signature &&
        lhs.offsetToSI == rhs.offsetToSI
    }
    
    /// Two units are equivalent if their physical dimensions and offsets match, regardless of symbol.
    /// (e.g., "N" == "kg·m/sec²")
    public func isEquivalent(to other: ExpressionUnit) -> Bool {
        signature == other.signature &&
        offsetToSI == other.offsetToSI
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
        hasher.combine(signature)
        hasher.combine(offsetToSI)
    }
    
    // MARK: - Private Helpers
    
    private static func mergeTerms(_ lhs: [String: Int], _ rhs: [String: Int], operation: (Int, Int) -> Int) -> [String: Int] {
        var result = lhs
        for (term, power) in rhs {
            let newPower = operation(result[term, default: 0], power)
            if newPower == 0 {
                result.removeValue(forKey: term) // Cancels out completely! (e.g. m / m)
            } else {
                result[term] = newPower
            }
        }
        return result
    }
    
    private static func buildCanonicalSymbol(from terms: [String: Int]) -> String {
        if terms.isEmpty { return "" }
        
        // Sort alphabetically so kg * m is identical to m * kg
        let sortedTerms = terms.sorted { $0.key < $1.key }
        
        var numerators: [String] = []
        var denominators: [String] = []
        
        for (term, power) in sortedTerms {
            let formatted = formatTerm(term, power: abs(power))
            if power > 0 {
                numerators.append(formatted)
            } else {
                denominators.append(formatted)
            }
        }
        
        let numStr = numerators.isEmpty ? "1" : numerators.joined(separator: "·")
        
        if denominators.isEmpty {
            return numStr
        }
        
        let denStr = denominators.joined(separator: "·")
        return denominators.count > 1 ? "\(numStr)/(\(denStr))" : "\(numStr)/\(denStr)"
    }
    
    private static func formatTerm(_ term: String, power: Int) -> String {
        if power == 1 { return term }
        let superscripts: [Character: Character] = [
            "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
            "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹"
        ]
        let powerStr = String(String(power).map { superscripts[$0] ?? $0 })
        return "\(term)\(powerStr)"
    }
}

public enum UnitCategory: String, Codable, Sendable {
    case length, area, volume
    case mass, density
    case time, rate, speed, acceleration
    case force, pressure, energy, power
    case temperature
    case flowRate, efficiency
    case none
}

extension ExpressionUnit {
    public var category: UnitCategory {
        let sig = self.signature
        
        switch (sig.mass, sig.length, sig.time, sig.temperature) {
        case (0, 0, 0, 0): return .none        // Unitless / Scalar
            
            // Geometry
        case (0, 1, 0, 0): return .length      // m
        case (0, 2, 0, 0): return .area        // m²
        case (0, 3, 0, 0): return .volume      // m³
            
            // Mass & Material
        case (1, 0, 0, 0): return .mass        // kg
        case (1, -3, 0, 0): return .density    // kg/m³
            
            // Kinematics (Time/Motion)
        case (0, 0, 1, 0): return .time        // s
        case (0, 0, -1, 0): return .rate       // 1/s (Frequency / Hz / BPM)
        case (0, 1, -1, 0): return .speed      // m/s
        case (0, 1, -2, 0): return .acceleration // m/s²
            
            // Dynamics (Forces & Energy)
        case (1, 1, -2, 0): return .force      // N  (kg·m/s²)
        case (1, -1, -2, 0): return .pressure  // Pa (N/m² -> kg/(m·s²))
        case (1, 2, -2, 0): return .energy     // J  (N·m -> kg·m²/s²)
        case (1, 2, -3, 0): return .power      // W  (J/s -> kg·m²/s³)
            
            // Thermodynamics
        case (0, 0, 0, 1): return .temperature // K
            
            // Specialized
        case (0, 3, -1, 0): return .flowRate   // Volumetric Flow (e.g., gal/min, m³/s)
        case (0, -2, 0, 0): return .efficiency // Fuel Economy (e.g., mpg, km/L)
            
        default: return .none // Complex dynamic compound units fall here
        }
    }
}

extension ExpressionUnit {
    public func convert(_ value: Double, to targetUnit: ExpressionUnit) -> Double? {
        ConversionEngine.convert(value: value, from: self, to: targetUnit)
    }
}


extension ExpressionUnit {
    private static let lock = NSLock()
    private static let userDefaultsKey = "com.engage.customUserUnits"
    
    nonisolated(unsafe) private static var userDefinedUnits: [ExpressionUnit] = {
        loadFromDisk()
    }()
    
    public static func registerUserUnit(_ unit: ExpressionUnit) {
        lock.lock()
        defer { lock.unlock() }
        if !userDefinedUnits.contains(where : { $0 == unit }) {
            userDefinedUnits.append(unit)
            saveToDisk()
        }
    }
    
    public static var userUnits: [ExpressionUnit] {
        lock.lock()
        defer { lock.unlock() }
        return userDefinedUnits
    }
    
    public static func deleteUserUnits() {
        lock.lock()
        defer { lock.unlock() }
        userDefinedUnits.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    private static func saveToDisk() {
        guard let data = try? JSONEncoder().encode(userDefinedUnits) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    private static func loadFromDisk() -> [ExpressionUnit] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let units = try? JSONDecoder().decode([ExpressionUnit].self, from: data) else {
            return []
        }
        return units
    }
    
}
