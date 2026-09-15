import Foundation

extension DimensionalSignature {
    public static let error =  DimensionalSignature(mass: .min, length: .min, time: .min, temperature: .min, scaleToSI: .nan)
    
    public var isError: Bool {
        mass == .min && length == .min && time == .min && temperature == .min
    }
}

extension ExpressionUnit {
    public static let error = ExpressionUnit(symbol: "error", signature: .error)
    public var isError: Bool {
        self.signature.isError || self.explicitSymbol == "error"
    }
}

public enum StandardUnits: Sendable {
    public static let none = ExpressionUnit(symbol: "", signature: DimensionalSignature())
    
    // Base Units
    public static let meters      = ExpressionUnit(symbol: "m",  signature: DimensionalSignature(length: 1, scaleToSI: 1.0))
    public static let kilograms   = ExpressionUnit(symbol: "kg",  signature: DimensionalSignature(mass: 1, scaleToSI: 1.0))
    public static let seconds     = ExpressionUnit(symbol: "s", signature: DimensionalSignature(time: 1, scaleToSI: 1.0))
    public static let kelvin     = ExpressionUnit(symbol: "K",  signature: DimensionalSignature(temperature: 1, scaleToSI: 1.0))
    
    public static let sec     = ExpressionUnit(symbol: "sec", wrapping: seconds)
    
    
    // Length (Base SI: m)
    public static let centimeters = ExpressionUnit(symbol: "cm", signature: DimensionalSignature(length: 1, scaleToSI: 0.01))
    public static let kilometers  = ExpressionUnit(symbol: "km", signature: DimensionalSignature(length: 1, scaleToSI: 1000.0))
    public static let inches      = ExpressionUnit(symbol: "in", signature: DimensionalSignature(length: 1, scaleToSI: 0.0254))
    public static let feet        = ExpressionUnit(symbol: "ft", signature: DimensionalSignature(length: 1, scaleToSI: 0.3048))
    public static let miles       = ExpressionUnit(symbol: "mi", signature: DimensionalSignature(length: 1, scaleToSI: 1609.344))
    // "nmi" and "nm" are also common, though "nm" can conflict with nanometers
    public static let nauticalMiles = ExpressionUnit(symbol: "NM", signature: DimensionalSignature(length: 1, scaleToSI: 1852.0))
    
    // Mass/Weight (Base SI: kg)
    public static let grams       = ExpressionUnit(symbol: "g",   signature: DimensionalSignature(mass: 1, scaleToSI: 0.001))
    public static let pounds      = ExpressionUnit(symbol: "lbs", signature: DimensionalSignature(mass: 1, scaleToSI: 0.45359237))
    public static let ounces      = ExpressionUnit(symbol: "oz",  signature: DimensionalSignature(mass: 1, scaleToSI: 0.02834952))
    
    
    // Time (Base SI: s)
    public static let minutes     = ExpressionUnit(symbol: "min", signature: DimensionalSignature(time: 1, scaleToSI: 60.0))
    public static let hours       = ExpressionUnit(symbol: "hr",  signature: DimensionalSignature(time: 1, scaleToSI: 3600.0))
    public static let days        = ExpressionUnit(symbol: "d",   signature: DimensionalSignature(time: 1, scaleToSI: 86400.0))
    public static let weeks       = ExpressionUnit(symbol: "wk", signature: DimensionalSignature(time: 1, scaleToSI: 604_800.0))
    public static let months      = ExpressionUnit(symbol: "mo", signature: DimensionalSignature(time: 1, scaleToSI: 2_592_000.0))
    public static let quarters    = ExpressionUnit(symbol: "qr", signature: DimensionalSignature(time: 1, scaleToSI: 7_776_000.0))
    public static let years       = ExpressionUnit(symbol: "yr", signature: DimensionalSignature(time: 1, scaleToSI: 31_536_000.0))
    
    
    // Temperature (Base SI: Kelvin)
    // Offset logic: (Celsius + 273.15) * 1.0 = Kelvin
    public static let celsius    = ExpressionUnit(symbol: "°C", signature: DimensionalSignature(temperature: 1, scaleToSI: 1.0), offsetToSI: 273.15)
    // Offset logic: (Fahrenheit + 459.67) * (5/9) = Kelvin
    public static let fahrenheit = ExpressionUnit(symbol: "°F", signature: DimensionalSignature(temperature: 1, scaleToSI: 5.0/9.0), offsetToSI: 459.67)
    
    //  Volume (Length^3)
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
    public static let barrels     = ExpressionUnit(symbol: "bbl", signature: DimensionalSignature(length: 3, scaleToSI: 0.158987294928))
    
    
    // Acceleration & Force
    // 1 g = 9.80665 m/s²
    public static let standardGravity = ExpressionUnit(symbol: "G", signature: DimensionalSignature(length: 1, time: -2, scaleToSI: 9.80665))
    public static let standardGravity2 = ExpressionUnit(symbol: "g-force", wrapping: standardGravity)
    // 1 lbf = 1 lb_mass * 1 g
    public static let poundsForce = ExpressionUnit(symbol: "lbf", wrapping: pounds * standardGravity)
    // Mathematically derived (kg * m / sec²), but aliased to "N"
    public static let newtons = ExpressionUnit(symbol: "N", wrapping: kilograms * metersPerSecondSquared)
    
    // Standard Acceleration
    public static let metersPerSecondSquared = ExpressionUnit(symbol: "m/s²", wrapping: meters / (seconds * seconds))
    public static let metersPerSecSquared = ExpressionUnit(symbol: "m/sec²", wrapping: meters / (seconds * seconds))
    public static let feetPerSecondSquared = ExpressionUnit(symbol: "ft/s²", wrapping: feet / (seconds * seconds))
    
    // Speed
    // Standard Velocity
    public static let metersPerSecond = ExpressionUnit(symbol: "m/s", wrapping: meters / seconds)
    public static let feetPerSecond = ExpressionUnit(symbol: "ft/s", wrapping: feet / seconds) // Or "fps" depending on your preference
    public static let knots = ExpressionUnit(symbol: "kn", wrapping: nauticalMiles / hours)
    public static let milesPerHour = ExpressionUnit(symbol: "mph", wrapping: miles / hours)
    public static let kilometersPerHour = ExpressionUnit(symbol: "km/h", wrapping: kilometers / hours)
    
    
    
    // Rates
    // Biometrics
    public static let beatsPerMinute = ExpressionUnit(symbol: "bpm", wrapping: StandardUnits.none / minutes) // Dimensionally identical to rpm!
    public static let breathsPerMinute = ExpressionUnit(symbol: "brpm", wrapping: StandardUnits.none / minutes)
    
    // Rate & Flow (Common in engineering/automotive)
    public static let revolutionsPerMinute = ExpressionUnit(symbol: "rpm", wrapping: StandardUnits.none / minutes) // 1/min
    public static let cubicFeetPerMinute = ExpressionUnit(symbol: "cfm", wrapping: (feet * feet * feet) / minutes)
    public static let gallonsPerMinute = ExpressionUnit(symbol: "gpm", wrapping: gallons / minutes)
    public static let milesPerGallon = ExpressionUnit(symbol: "mpg", wrapping: miles / gallons)
    public static let litersPerMinute      = ExpressionUnit(symbol: "l/min", wrapping: liters / minutes)
    public static let cubicMetersPerSecond = ExpressionUnit(symbol: "m³/s", wrapping: (meters * meters * meters) / seconds)
    public static let gallonsPerHour       = ExpressionUnit(symbol: "gph", wrapping: gallons / hours)
    public static let barrelsPerDay        = ExpressionUnit(symbol: "bbl/d", wrapping: barrels / days)
    
    
    // Pressure
    public static let pascals = ExpressionUnit(symbol: "Pa", wrapping: newtons / (meters * meters))
    public static let poundsPerSquareInch = ExpressionUnit(symbol: "psi", wrapping: poundsForce / (inches * inches))
    
    // Volume
    public static let cubicCentimeters = ExpressionUnit(symbol: "cc", wrapping: centimeters * centimeters * centimeters)
    
    // Area
    // A user typing "ft * ft" or "ft²" will automatically snap to "sq ft" if you prefer this visual output!
    public static let squareFeet = ExpressionUnit(symbol: "sq ft", wrapping: feet * feet)
    public static let squareFeet2 = ExpressionUnit(symbol: "ft²", wrapping: feet * feet)
    public static let squareMeters = ExpressionUnit(symbol: "sq m", wrapping: meters * meters)
    public static let squareMeters2 = ExpressionUnit(symbol: "m²", wrapping: meters * meters)
    
    // Energy & Power
    public static let joules = ExpressionUnit(symbol: "J", wrapping: newtons * meters)
    public static let kilojoules = ExpressionUnit(symbol: "kJ", signature: DimensionalSignature(mass: 1, length: 2, time: -2, scaleToSI: 1000.0))
    public static let calories = ExpressionUnit(symbol: "cal", signature: DimensionalSignature(mass: 1, length: 2, time: -2, scaleToSI: 4.184))
    public static let kilocalories = ExpressionUnit(symbol: "kcal", signature: DimensionalSignature(mass: 1, length: 2, time: -2, scaleToSI: 4184.0))
    public static let dietaryCalories = ExpressionUnit(symbol: "Cal", signature: DimensionalSignature(mass: 1, length: 2, time: -2, scaleToSI: 4184.0))
    
    // MARK: - Power
    public static let watts = ExpressionUnit(symbol: "W", wrapping: joules / seconds)
    public static let kilowatts = ExpressionUnit(symbol: "kW", signature: DimensionalSignature(mass: 1, length: 2, time: -3, scaleToSI: 1000.0))
    public static let wattHours = ExpressionUnit(symbol: "Wh", wrapping: watts * hours)
    public static let kilowattHours = ExpressionUnit(symbol: "kWh", wrapping: kilowatts * hours)
    
    
    public static let core: [ExpressionUnit] = [
        meters, kilograms, seconds, kelvin, sec,
        centimeters, kilometers, inches, feet, miles, nauticalMiles,
        grams, pounds, ounces,
        minutes, hours, days, weeks, months, quarters, years,
        celsius, fahrenheit,
        milliliters, liters, metricCups, fluidOunces, teaspoons, tablespoons, cups, pints, quarts, gallons, barrels,
        standardGravity, poundsForce, feetPerSecondSquared, metersPerSecondSquared, metersPerSecSquared, newtons,
        metersPerSecond, feetPerSecond, knots, milesPerHour, kilometersPerHour,
        beatsPerMinute, breathsPerMinute, revolutionsPerMinute, cubicFeetPerMinute, gallonsPerMinute, milesPerGallon, litersPerMinute, cubicMetersPerSecond, gallonsPerHour, barrelsPerDay,
        pascals, poundsPerSquareInch,
        cubicCentimeters, squareFeet, squareFeet2, squareMeters, squareMeters2,
        joules, kilojoules, calories, kilocalories, dietaryCalories,
        watts, kilowatts, wattHours, kilowattHours
    ]
    
    public static var all: [ExpressionUnit] {
        core + ExpressionUnit.userUnits
    }
    
}

extension StandardUnits {
    /// Robust parsing from string input, evaluating algebraic combinations.
    public static func resolve(_ s: String, keep: Bool=true) -> ExpressionUnit {
        let cleaned = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return StandardUnits.none }
        
        let lowercased = cleaned.lowercased()
        
        let allUnits = all
        
        // 1. Fast Path: Exact Match (e.g., "N", "kg", "m/sec²")
        if let exact = allUnits.first(where: { $0.symbol.lowercased() == lowercased || $0.explicitSymbol?.lowercased() == lowercased }) {
            return exact
        }
        
        // 2. Algebraic Tokenization
        // Normalize visual characters to standard ASCII for easy parsing
        let normalized = cleaned
            .replacingOccurrences(of: "·", with: "*")
            .replacingOccurrences(of: "²", with: "^2")
            .replacingOccurrences(of: "³", with: "^3")
            .replacingOccurrences(of: " ", with: "")
        
        var result = StandardUnits.none
        var currentToken = ""
        var operation: Character = "*" // Start by multiplying the first token into 'none'
        
        // Helper to commit a parsed token (like "sec^2") into the running result
        func commitTerm() {
            guard !currentToken.isEmpty else { return }
            
            // Split out the exponent (e.g. "sec^2" -> "sec", "2")
            let parts = currentToken.components(separatedBy: "^")
            let symbol = parts[0]
            let power = parts.count > 1 ? (Int(parts[1]) ?? 1) : 1
            
            // Look up the base token
            guard let baseUnit = allUnits.first(where: { $0.symbol.lowercased() == symbol.lowercased() }) else {
                currentToken = ""
                return // You could throw an error here for unknown tokens if desired
            }
            
            // Expand the exponent (sec^2 -> sec * sec)
            var termUnit = baseUnit
            if power > 1 {
                for _ in 2...power { termUnit = termUnit * baseUnit }
            }
            
            // Apply to the running mathematical result
            if result.isEquivalent(to: StandardUnits.none) {
                result = operation == "/" ? (StandardUnits.none / termUnit) : termUnit
            } else {
                result = operation == "/" ? (result / termUnit) : (result * termUnit)
            }
            
            currentToken = ""
        }
        
        // Scan characters left to right
        for char in normalized {
            if char == "*" || char == "/" {
                commitTerm()
                operation = char
            } else {
                currentToken.append(char)
            }
        }
        commitTerm() // Flush the final token
        
        // 3. The Magic: Alias Resolution
        // If the parsed string algebraically equates to a known unit, return the canonical version.
        // e.g. "kg*m/sec^2" == newtons (because signatures match!).
        if let canonicalAlias = allUnits.first(where: { $0.isEquivalent(to: result) }) {
            return canonicalAlias
        }
        
        if keep {
            ExpressionUnit.registerUserUnit(result)
        }
        
        return result
    }
}
