import Foundation

public enum ConversionEngine {
    
    /// Converts a value from one unit to another. Returns nil if the physical dimensions don't match.
    public static func convert(value: Double, from sourceUnit: ExpressionUnit, to targetUnit: ExpressionUnit) -> Double? {
        
        // 1. If units are identical, return exact value
        if sourceUnit == targetUnit || sourceUnit.isEquivalent(to: targetUnit) {
            return value
        }
        
        // 2. Ensure they measure the same physical property (e.g. Length to Length)
        guard sourceUnit.signature.isEquivalent(to: targetUnit.signature) else {
            return nil // Cannot convert Mass to Speed, for example
        }
        
        // 3. Convert Source -> Pure SI Base Unit
        let valueInSI = (value + sourceUnit.offsetToSI) * sourceUnit.signature.scaleToSI
        
        // 4. Convert Pure SI -> Target Unit
        let targetValue = (valueInSI / targetUnit.signature.scaleToSI) - targetUnit.offsetToSI
        
        return targetValue
    }
}
