import Foundation


/// A mathematical unit that can be combined, multiplied, and divided.
public struct ExpressionUnit: Hashable, Equatable, Codable, Sendable, CustomStringConvertible {
    public let symbol: String
    public let signature: DimensionalSignature
    
    /// Used ONLY for units that don't start at absolute zero (Celsius and Fahrenheit).
    /// Value is added BEFORE scaling to SI.
    public var offsetToSI: Double = 0.0
    
    public var description: String { symbol }
    
    public var scaleToSI: Double {
        signature.scaleToSI
    }
    
    public init(symbol: String, signature: DimensionalSignature, offsetToSI: Double = 0.0) {
        self.symbol = symbol
        self.signature = signature
        self.offsetToSI = offsetToSI
    }
    
    public static func * (lhs: ExpressionUnit, rhs: ExpressionUnit) -> ExpressionUnit {
        ExpressionUnit(
            symbol: "\(lhs.symbol)·\(rhs.symbol)",
            signature: lhs.signature * rhs.signature
        )
    }
    
    public static func / (lhs: ExpressionUnit, rhs: ExpressionUnit) -> ExpressionUnit {
        if lhs == rhs { return StandardUnits.none }
        return ExpressionUnit(
            symbol: "\(lhs.symbol)/\(rhs.symbol)",
            signature: lhs.signature / rhs.signature
        )
    }
}

public enum UnitCategory: String, Codable, Sendable {
    case length, mass, time, rate, volume, speed, temperature, energy, power, acceleration, none
}

extension ExpressionUnit {
    public var category: UnitCategory {
        let sig = self.signature
        
        switch (sig.mass, sig.length, sig.time, sig.temperature) {
        case (0, 1, 0, 0): return .length
        case (1, 0, 0, 0): return .mass
        case (0, 0, 1, 0): return .time
        case (0, 0, -1, 0): return .rate
        case (0, 3, 0, 0): return .volume
        case (0, 1, -1, 0): return .speed
        case (0, 0, 0, 1): return .temperature
        case (1, 2, -2, 0): return .energy
        case (1, 2, -3, 0): return .power
        case (0, 1, -2, 0): return .acceleration
        case (0, 0, 0, 0): return .none
        default: return .none // Complex dynamic compound units fall here
        }
    }
}

extension ExpressionUnit {
    public func convert(_ value: Double, to targetUnit: ExpressionUnit) -> Double? {
        ConversionEngine.convert(value: value, from: self, to: targetUnit)
    }
}
