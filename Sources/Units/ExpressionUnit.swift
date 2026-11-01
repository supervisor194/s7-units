import Foundation
import CryptoKit

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
    public init(explicitSymbol: String? = nil, terms: [String: Int], signature: DimensionalSignature, offsetToSI: Double = 0.0) {
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
    
    public func isCompatible(with other: ExpressionUnit) -> Bool {
        signature.isEquivalent(to: other.signature)
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
    
    /// Robust parsing from string input, evaluating algebraic combinations.
    internal static func resolve(_ s: String, against allUnits: [ExpressionUnit]) -> (unit: ExpressionUnit, isNew: Bool) {
        let cleaned = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return (StandardUnits.none, false) }
        
        // 1. Fast Path: Exact Match (e.g., "N", "kg", "m/sec²")
        if let exact = allUnits.first(where: { $0.symbol == cleaned || $0.explicitSymbol == cleaned }) {
            return (exact, false)
        }
        
        // 2. Algebraic Tokenization
        // Normalize visual characters to standard ASCII for easy parsing
        let normalized = cleaned
            .replacingOccurrences(of: "·", with: "*")
            .replacingOccurrences(of: "²", with: "^2")
            .replacingOccurrences(of: "³", with: "^3")
            .replacingOccurrences(of: "⁴", with: "^4")
            .replacingOccurrences(of: "⁵", with: "^5")
            .replacingOccurrences(of: "⁶", with: "^6")
            .replacingOccurrences(of: "⁷", with: "^7")
            .replacingOccurrences(of: "⁸", with: "^8")
            .replacingOccurrences(of: "⁹", with: "^9")
            .replacingOccurrences(of: " ", with: "")
        
        var result = StandardUnits.none
        var operation: Character = "*" // Start by multiplying the first token into 'none'
        
        // Helper to apply any resolved unit (symbol or parenthetical group) to the running result
        func applyTerm(_ termUnit: ExpressionUnit) {
            if result.isEquivalent(to: StandardUnits.none) {
                result = operation == "/" ? (StandardUnits.none / termUnit) : termUnit
            } else {
                result = operation == "/" ? (result / termUnit) : (result * termUnit)
            }
        }
        
        // Helper to commit a base symbol token (like "sec^2")
        func commitToken(_ token: String) {
            guard !token.isEmpty else { return }
            
            let parts = token.components(separatedBy: "^")
            let symbol = parts[0]
            let power = parts.count > 1 ? (Int(parts[1]) ?? 1) : 1
            
            // Look up base unit matching either standard symbol or explicit symbol/alias
            guard let baseUnit = allUnits.first(where: {
                $0.symbol == symbol ||
                $0.explicitSymbol == symbol
            }) else {
                return
            }
            
            var termUnit = baseUnit
            if power > 1 {
                for _ in 2...power { termUnit = termUnit * baseUnit }
            }
            
            applyTerm(termUnit)
        }
        
        let chars = Array(normalized)
        var i = 0
        
        while i < chars.count {
            let char = chars[i]
            
            if char == "*" || char == "/" {
                operation = char
                i += 1
            } else if char == "(" {
                // Find matching closing parenthesis, tracking nesting depth
                i += 1
                var depth = 1
                var innerChars: [Character] = []
                
                while i < chars.count && depth > 0 {
                    if chars[i] == "(" { depth += 1 }
                    else if chars[i] == ")" { depth -= 1 }
                    
                    if depth > 0 {
                        innerChars.append(chars[i])
                    }
                    i += 1
                }
                
                // Recursively resolve the inner expression
                let innerString = String(innerChars)
                let (subUnit, _) = resolve(innerString, against: allUnits)
                
                // Check if there is an exponent attached to the closing parenthesis (e.g. (m/s)^2)
                var power = 1
                if i < chars.count && chars[i] == "^" {
                    i += 1 // skip '^'
                    var powerChars = ""
                    while i < chars.count && (chars[i].isNumber || chars[i] == "-") {
                        powerChars.append(chars[i])
                        i += 1
                    }
                    if let p = Int(powerChars) {
                        power = p
                    }
                }
                
                var finalSubUnit = subUnit
                if power > 1 {
                    for _ in 2...power { finalSubUnit = finalSubUnit * subUnit }
                }
                
                applyTerm(finalSubUnit)
            } else {
                // Accumulate regular token characters until an operator or parenthesis is reached
                var tokenChars = ""
                while i < chars.count && chars[i] != "*" && chars[i] != "/" && chars[i] != "(" && chars[i] != ")" {
                    tokenChars.append(chars[i])
                    i += 1
                }
                commitToken(tokenChars)
            }
        }
        
        // 3. Canonical Alias Resolution First (Ensures "m/sec^2" resolves to canonical "m/s^2")
        if let canonicalAlias = allUnits.first(where: { $0.isEquivalent(to: result) && $0 != StandardUnits.none }) {
            return (canonicalAlias, false)
        }
        
        // Then fallback to exact symbol match
        if let exactSymbolMatch = allUnits.first(where: {
            ($0.symbol == normalized) ||
            ($0.explicitSymbol == normalized)
        }) {
            return (exactSymbolMatch, false)
        }
        
        return (result, true)
    }

}


extension ExpressionUnit {
    private static let lock = NSLock()
    private static let userDefaultsKey = "com.engage.customUserUnits"
    
    /// A deterministic, cross-device unique key derived from both the symbol and its mathematical definition.
    public var persistentKey: String {
        let sortedTerms = terms.sorted(by: { $0.key < $1.key })
            .map { "\($0.key):\($0.value)" }
            .joined(separator: "_")
        
        let symbolPayload = explicitSymbol?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "none"
        
        // Combine symbol and all physics parameters into the hash input
        let rawSignature = "sym:\(symbolPayload)_m\(signature.mass)_l\(signature.length)_t\(signature.time)_temp\(signature.temperature)_sc\(signature.scaleToSI)_off\(offsetToSI)_\(sortedTerms)"
        
        let inputData = Data(rawSignature.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        
        return String(hashString.prefix(16))
    }
    
    nonisolated(unsafe) private static var cache: [String: ExpressionUnit] = {
        var cache: [String: ExpressionUnit] = [:]
        for unit in StandardUnits.core {
            cache[unit.persistentKey] = unit
        }
        
        for unit in loadFromDisk() {
            cache[unit.persistentKey] = unit
        }
        return cache
    }()
    
    /// Looks up any unit (core or custom) by its deterministic SHA256 persistentKey
    public static func fetch(key: String) -> ExpressionUnit? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }
    
    /// Parses an expression string into an ExpressionUnit. Optionally persists it to disk if keep is true.
    public static func resolve(_ expression: String, keep: Bool = false) -> ExpressionUnit {
        let (unit, isNew) = resolve(expression, against: all)
        if isNew && keep && unit != StandardUnits.none {
            registerUserUnit(unit)
        }
        return unit
    }
    
    public static func registerUserUnit(_ unit: ExpressionUnit) {
        lock.lock()
        defer { lock.unlock() }
        
        let key = unit.persistentKey
        cache[key] = unit
        
        // Collect all user units currently in cache (everything except core)
        let coreKeys = Set(StandardUnits.core.map { $0.persistentKey })
        let userDefinedUnits = cache.values.filter { !coreKeys.contains($0.persistentKey) }
        
        saveToDisk(Array(userDefinedUnits))
    }
    
    /// All active user-defined custom units served instantly from memory cache
    public static var userUnits: [ExpressionUnit] {
        lock.lock()
        defer { lock.unlock() }
        let coreKeys = Set(StandardUnits.core.map { $0.persistentKey })
        return cache.values.filter { !coreKeys.contains($0.persistentKey) }
    }
        
    /// Combined list of all built-in core units and user-defined custom units served from memory cache in a guaranteed deterministic order
    public static var all: [ExpressionUnit] {
        lock.lock()
        defer { lock.unlock() }
        
        // Core units always lead in their exact declaration order
        let coreKeys = Set(StandardUnits.core.map { $0.persistentKey })
        
        // User units are sorted deterministically by persistentKey
        let sortedUserUnits = cache.values
            .filter { !coreKeys.contains($0.persistentKey) }
            .sorted { $0.persistentKey < $1.persistentKey }
        
        return StandardUnits.core + sortedUserUnits
    }
    
    public static func deleteUserUnits() {
        lock.lock()
        defer { lock.unlock() }
        cache = [:]
        for unit in StandardUnits.core {
            cache[unit.persistentKey] = unit
        }
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    // MARK: - Disk I/O Helpers
    
    private static func saveToDisk(_ units: [ExpressionUnit]) {
        guard let data = try? JSONEncoder().encode(units) else { return }
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
