import Foundation

public enum StandardUnits {
    public static let none = ExpressionUnit(symbol: "", signature: DimensionalSignature())
    
    // MARK: - Length (Base SI: m)
    public static let meters      = ExpressionUnit(symbol: "m",  signature: DimensionalSignature(length: 1, scaleToSI: 1.0))
    public static let centimeters = ExpressionUnit(symbol: "cm", signature: DimensionalSignature(length: 1, scaleToSI: 0.01))
    public static let kilometers  = ExpressionUnit(symbol: "km", signature: DimensionalSignature(length: 1, scaleToSI: 1000.0))
    public static let inches      = ExpressionUnit(symbol: "in", signature: DimensionalSignature(length: 1, scaleToSI: 0.0254))
    public static let feet        = ExpressionUnit(symbol: "ft", signature: DimensionalSignature(length: 1, scaleToSI: 0.3048))
    public static let miles       = ExpressionUnit(symbol: "mi", signature: DimensionalSignature(length: 1, scaleToSI: 1609.344))
    
    // MARK: - Mass/Weight (Base SI: kg)
    public static let kilograms   = ExpressionUnit(symbol: "kg",  signature: DimensionalSignature(mass: 1, scaleToSI: 1.0))
    public static let grams       = ExpressionUnit(symbol: "g",   signature: DimensionalSignature(mass: 1, scaleToSI: 0.001))
    public static let pounds      = ExpressionUnit(symbol: "lbs", signature: DimensionalSignature(mass: 1, scaleToSI: 0.45359237))
    public static let ounces      = ExpressionUnit(symbol: "oz",  signature: DimensionalSignature(mass: 1, scaleToSI: 0.02834952))
    
    // MARK: - Time (Base SI: s)
    public static let seconds     = ExpressionUnit(symbol: "sec", signature: DimensionalSignature(time: 1, scaleToSI: 1.0))
    public static let minutes     = ExpressionUnit(symbol: "min", signature: DimensionalSignature(time: 1, scaleToSI: 60.0))
    public static let hours       = ExpressionUnit(symbol: "hr",  signature: DimensionalSignature(time: 1, scaleToSI: 3600.0))
    public static let days        = ExpressionUnit(symbol: "d",   signature: DimensionalSignature(time: 1, scaleToSI: 86400.0))
    public static let weeks       = ExpressionUnit(symbol: "wk", signature: DimensionalSignature(time: 1, scaleToSI: 604_800.0))
    public static let months      = ExpressionUnit(symbol: "mo", signature: DimensionalSignature(time: 1, scaleToSI: 2_592_000.0))
    public static let quarters    = ExpressionUnit(symbol: "qr", signature: DimensionalSignature(time: 1, scaleToSI: 7_776_000.0))
    public static let years       = ExpressionUnit(symbol: "yr", signature: DimensionalSignature(time: 1, scaleToSI: 31_536_000.0))
    
    // MARK: - Temperature (Base SI: Kelvin)
    public static let kelvin     = ExpressionUnit(symbol: "K",  signature: DimensionalSignature(temperature: 1, scaleToSI: 1.0))
    // Offset logic: (Celsius + 273.15) * 1.0 = Kelvin
    public static let celsius    = ExpressionUnit(symbol: "°C", signature: DimensionalSignature(temperature: 1, scaleToSI: 1.0), offsetToSI: 273.15)
    // Offset logic: (Fahrenheit + 459.67) * (5/9) = Kelvin
    public static let fahrenheit = ExpressionUnit(symbol: "°F", signature: DimensionalSignature(temperature: 1, scaleToSI: 5.0/9.0), offsetToSI: 459.67)
    
    // MARK: - Volume (Length^3)
    public static let milliliters = ExpressionUnit(symbol: "ml",    signature: DimensionalSignature(length: 3, scaleToSI: 1e-6))
    public static let liters      = ExpressionUnit(symbol: "l",   signature: DimensionalSignature(length: 3, scaleToSI: 0.001))
    public static let metricCups  = ExpressionUnit(symbol: "mc",    signature: DimensionalSignature(length: 3, scaleToSI: 0.00025)) // 250 ml standard
    
    public static let fluidOunces = ExpressionUnit(symbol: "fl oz", signature: DimensionalSignature(length: 3, scaleToSI: 0.0000295735))
    public static let teaspoons   = ExpressionUnit(symbol: "tsp",   signature: DimensionalSignature(length: 3, scaleToSI: 4.92892159375e-6))
    public static let tablespoons = ExpressionUnit(symbol: "tbsp",  signature: DimensionalSignature(length: 3, scaleToSI: 1.478676478125e-5))
    public static let cups        = ExpressionUnit(symbol: "c",     signature: DimensionalSignature(length: 3, scaleToSI: 0.0002365882365)) // US Customary
    
    public static let pints       = ExpressionUnit(symbol: "pt",    signature: DimensionalSignature(length: 3, scaleToSI: 0.000473176473))
    public static let quarts      = ExpressionUnit(symbol: "qt",    signature: DimensionalSignature(length: 3, scaleToSI: 0.000946352946))
    public static let gallons     = ExpressionUnit(symbol: "gal",   signature: DimensionalSignature(length: 3, scaleToSI: 0.003785411784))
    
    // MARK: - COMPOUND UNITS (Generated dynamically by math!)
    
    public static let metersPerSecond   = meters / seconds
    public static let kilometersPerHour = kilometers / hours
    public static let feetPerSecond     = feet / seconds
    public static let milesPerHour      = miles / hours
    
    public static let metersPerSecondSquared = meters / (seconds * seconds)
    
    // MARK: - Parsing / Resolving
    
    public static let all: [ExpressionUnit] = [
        none, meters, centimeters, kilometers, inches, feet, miles,
        kilograms, grams, pounds, ounces, seconds, minutes, hours, days, weeks, months, quarters, years,
        kelvin, celsius, fahrenheit,
        milliliters, liters, teaspoons, tablespoons, fluidOunces, cups, metricCups, pints, quarts, gallons,
        metersPerSecond, kilometersPerHour, feetPerSecond, milesPerHour,
        metersPerSecondSquared
    ]
    
    /// Robust parsing from string input
    public static func resolve(_ s: String) -> ExpressionUnit {
        let cleaned = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return all.first { $0.symbol.lowercased() == cleaned } ?? StandardUnits.none
    }
}
