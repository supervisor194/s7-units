import Testing
@testable import S7Units


@Suite("String Resolution and Parsing Tests")
struct UnitParsingTests {
    
    init() {
        ExpressionUnit.deleteUserUnits()
    }
    
    @Test("Fast Path: Direct alias matches work instantly")
    func testDirectMatches() {
        #expect(StandardUnits.resolve("N") == StandardUnits.newtons)
        #expect(StandardUnits.resolve("kg") == StandardUnits.kilograms)
        #expect(StandardUnits.resolve("m/s²") == StandardUnits.metersPerSecondSquared)
        #expect(StandardUnits.resolve("m/sec^2") == StandardUnits.metersPerSecondSquared) // Works due to normalization
    }
    
    @Test("Algebraic Path: Expressions parse and compute correctly")
    func testAlgebraicParsing() {
        // Parse a standard speed
        let speed = StandardUnits.resolve("m / sec")
        #expect(speed.category == .speed)
        
        // Parse volume (length * length * length)
        let volume = StandardUnits.resolve("m * m * m")
        #expect(volume.category == .volume)
        #expect(volume.symbol == "m³") // Because of algebraic canonical formatting!
    }
    
    @Test("Alias Resolution: Messy algebraic strings snap to clean canonical units")
    func testStringAliasResolution() {
        // 1. Force entered manually -> should snap to Newtons
        let stringForce1 = StandardUnits.resolve("kg·m/sec²")
        #expect(stringForce1 == StandardUnits.newtons)
        #expect(stringForce1.symbol == "N") // It returns the exact alias instance!
        
        // 2. Alternative syntax -> should also snap to Newtons
        let stringForce2 = StandardUnits.resolve("kg * m / sec^2")
        #expect(stringForce2 == StandardUnits.newtons)
        #expect(stringForce2.symbol == "N")
        
        // 3. Bizarre ordering -> should STILL snap to Newtons
        // "m / sec^2 * kg" algebraically equates to Newtons!
        let messyForce = StandardUnits.resolve("m / sec^2 * kg", keep: false)
        #expect(messyForce == StandardUnits.newtons)
        #expect(messyForce.symbol == "N")
    }
    
    
}
