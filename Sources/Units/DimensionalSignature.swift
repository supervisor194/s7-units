import Foundation

/// Represents the fundamental physics dimensions of any value.
public struct DimensionalSignature: Hashable, Equatable, Codable, Sendable {
    public var mass: Int = 0
    public var length: Int = 0
    public var time: Int = 0
    public var temperature: Int = 0
    
    /// Multiplier to convert a value in this unit to pure SI base units.
    public var scaleToSI: Double = 1.0
    
    public var isDimensionless: Bool {
        mass == 0 && length == 0 && time == 0 && temperature == 0
    }
    
    /// True if two units measure the exact same physical property (e.g., miles and meters)
    public func isEquivalent(to other: DimensionalSignature) -> Bool {
        mass == other.mass && length == other.length &&
        time == other.time && temperature == other.temperature
    }
    
    // Multiply dimensions (e.g., length * length = area)
    public static func * (lhs: DimensionalSignature, rhs: DimensionalSignature) -> DimensionalSignature {
        DimensionalSignature(
            mass: lhs.mass + rhs.mass,
            length: lhs.length + rhs.length,
            time: lhs.time + rhs.time,
            temperature: lhs.temperature + rhs.temperature,
            scaleToSI: lhs.scaleToSI * rhs.scaleToSI
        )
    }
    
    // Divide dimensions (e.g., length / time = speed)
    public static func / (lhs: DimensionalSignature, rhs: DimensionalSignature) -> DimensionalSignature {
        DimensionalSignature(
            mass: lhs.mass - rhs.mass,
            length: lhs.length - rhs.length,
            time: lhs.time - rhs.time,
            temperature: lhs.temperature - rhs.temperature,
            scaleToSI: lhs.scaleToSI / rhs.scaleToSI
        )
    }
}
