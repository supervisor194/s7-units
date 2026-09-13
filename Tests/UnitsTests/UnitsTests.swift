import Testing
@testable import S7Units

@Suite("Unit Engine Physics & Conversion Tests")
struct UnitEngineTests {
    
    // Base units for testing
    let meters = StandardUnits.meters
    let seconds = StandardUnits.seconds
    let kilograms = StandardUnits.kilograms
    
    // MARK: - 1. Signature & Math Tests
    
    @Test("test unitless")
    func testUnitless() {
        let finalUnits = StandardUnits.none * StandardUnits.none
        
        #expect(finalUnits.symbol == "")
        #expect(finalUnits.signature.length == 0)
    }
    
    @Test("Unit Multiplication creates correct dimensional signatures")
    func testUnitMultiplication() {
        let area = StandardUnits.meters * StandardUnits.meters
        
        #expect(area.symbol == "m²")
        #expect(area.signature.length == 2)
        #expect(area.signature.mass == 0)
        #expect(area.category == .area) // Compound unit fallback
    }
    
    @Test("Unit Division cancels out identical units")
    func testUnitDivisionCancellation() {
        let canceled = StandardUnits.meters / StandardUnits.meters
        
        #expect(canceled == StandardUnits.none)
        #expect(canceled.signature.isDimensionless == true)
    }
    
    @Test("Hardcoded compound units match dynamic mathematical creation")
    func testCompoundUnitEquivalence() {
        // Dynamically creating miles per hour
        let dynamicMPH = StandardUnits.miles / StandardUnits.hours
        
        // Comparing to the one we defined in StandardUnits
        #expect(dynamicMPH.signature.isEquivalent(to: StandardUnits.milesPerHour.signature))
        #expect(dynamicMPH.signature.length == 1)
        #expect(dynamicMPH.signature.time == -1)
    }
    
    // MARK: - 2. Basic Conversions
    
    @Test("Convert Length: Miles to Kilometers")
    func testMilesToKilometers() throws {
        let result = ConversionEngine.convert(
            value: 5.0,
            from: StandardUnits.miles,
            to: StandardUnits.kilometers
        )
        
        let unwrapped = try #require(result)
        // 5 miles * 1.60934 = 8.04672 km
        #expect(abs(unwrapped - 8.04672) < 0.0001)
    }
    
    @Test("Convert Mass: Pounds to Kilograms")
    func testPoundsToKilograms() throws {
        let result = ConversionEngine.convert(
            value: 150.0,
            from: StandardUnits.pounds,
            to: StandardUnits.kilograms
        )
        
        let unwrapped = try #require(result)
        // 150 lbs * 0.453592 = 68.0388 kg
        #expect(abs(unwrapped - 68.0388) < 0.001)
    }
    
    // MARK: - 3. Temperature Conversions (Offset Logic)
    
    @Test("Convert Temperature: Celsius to Fahrenheit")
    func testCelsiusToFahrenheit() throws {
        let result = ConversionEngine.convert(
            value: 100.0, // Boiling point of water
            from: StandardUnits.celsius,
            to: StandardUnits.fahrenheit
        )
        
        let unwrapped = try #require(result)
        #expect(abs(unwrapped - 212.0) < 0.001)
    }
    
    @Test("Convert Temperature: Fahrenheit to Celsius")
    func testFahrenheitToCelsius() throws {
        let result = ConversionEngine.convert(
            value: 32.0, // Freezing point of water
            from: StandardUnits.fahrenheit,
            to: StandardUnits.celsius
        )
        
        let unwrapped = try #require(result)
        #expect(abs(unwrapped - 0.0) < 0.001)
    }
    
    // MARK: - 4. Dynamic Compound Conversions (The "Magic" Feature)
    
    @Test("Convert dynamically created speeds (mi/min -> km/h)")
    func testDynamicSpeedConversion() throws {
        // User inputs distance in miles and time in minutes
        let milesPerMinute = StandardUnits.miles / StandardUnits.minutes
        
        // We want to display it as km/h
        let result = ConversionEngine.convert(
            value: 1.0, // 1 mile per minute (60 mph)
            from: milesPerMinute,
            to: StandardUnits.kilometersPerHour
        )
        
        let unwrapped = try #require(result)
        
        // 60 mph in km/h is ~96.5606
        #expect(abs(unwrapped - 96.5606) < 0.001)
    }
    
    // MARK: - 5. Failure States
    
    @Test("Conversion fails when dimensions do not match")
    func testDimensionalMismatchFails() {
        // Trying to convert Mass to Length should return nil
        let result = ConversionEngine.convert(
            value: 10.0,
            from: StandardUnits.pounds,
            to: StandardUnits.meters
        )
        
        #expect(result == nil)
    }
    
    @Test("Conversion fails when converting Volume to Area")
    func testVolumeToAreaFails() {
        let area = StandardUnits.meters * StandardUnits.meters
        
        let result = ConversionEngine.convert(
            value: 10.0,
            from: StandardUnits.gallons, // length^3
            to: area                     // length^2
        )
        
        #expect(result == nil)
    }
    
    // MARK: - Volume Conversions
    
    @Test("Convert Culinary Ratios: Tablespoons to Teaspoons")
    func testTablespoonsToTeaspoons() throws {
        let result = ConversionEngine.convert(
            value: 2.0,
            from: StandardUnits.tablespoons,
            to: StandardUnits.teaspoons
        )
        
        let unwrapped = try #require(result)
        // 1 tbsp = 3 tsp -> 2 tbsp = 6 tsp
        #expect(abs(unwrapped - 6.0) < 0.0001)
    }
    
    @Test("Convert US Customary Cup to Fluid Ounces & Tablespoons")
    func testUSCupConversions() throws {
        let flOzResult = ConversionEngine.convert(
            value: 1.0,
            from: StandardUnits.cups,
            to: StandardUnits.fluidOunces
        )
        let tbspResult = ConversionEngine.convert(
            value: 1.0,
            from: StandardUnits.cups,
            to: StandardUnits.tablespoons
        )
        
        let flOz = try #require(flOzResult)
        let tbsp = try #require(tbspResult)
        
        #expect(abs(flOz - 8.0) < 0.001)   // 1 US Cup = 8 fl oz
        #expect(abs(tbsp - 16.0) < 0.001)  // 1 US Cup = 16 tbsp
    }
    
    @Test("Distinguish US Customary Cup vs Metric Cup")
    func testMetricVsCustomaryCup() throws {
        let metricCupInMl = ConversionEngine.convert(
            value: 1.0,
            from: StandardUnits.metricCups,
            to: StandardUnits.milliliters
        )
        let customaryCupInMl = ConversionEngine.convert(
            value: 1.0,
            from: StandardUnits.cups,
            to: StandardUnits.milliliters
        )
        
        let metricMl = try #require(metricCupInMl)
        let customaryMl = try #require(customaryCupInMl)
        
        #expect(abs(metricMl - 250.0) < 0.001)      // Metric Cup = exactly 250 ml
        #expect(abs(customaryMl - 236.588) < 0.01)  // US Customary Cup ≈ 236.588 ml
    }
    
    @Test("Convert Liquid Volume: Gallons to Quarts and Pints")
    func testGallonSubdivisions() throws {
        let quarts = try #require(ConversionEngine.convert(
            value: 1.0,
            from: StandardUnits.gallons,
            to: StandardUnits.quarts
        ))
        let pints = try #require(ConversionEngine.convert(
            value: 1.0,
            from: StandardUnits.gallons,
            to: StandardUnits.pints
        ))
        
        #expect(abs(quarts - 4.0) < 0.001) // 1 gallon = 4 quarts
        #expect(abs(pints - 8.0) < 0.001)  // 1 gallon = 8 pints
    }
    
    @Test("Algebraic cancellation removes terms completely")
    func testUnitCancellation() throws {
        // (meters * seconds) / seconds
        let compound = (meters * seconds) / seconds
        
        // The seconds should algebraically cancel out (1 - 1 = 0)
        #expect(compound == meters)
        
        // The canonical symbol shouldn't have any residual "sec" tokens
        #expect(compound.symbol == "m")
        #expect(compound.terms["sec"] == nil)
    }
    
    @Test("Multiple paths to Acceleration produce identical canonical units")
    func testAccelerationMultiplePaths() throws {
        // Path 1: (m / s) / s
        let velocity = meters / seconds
        let accel1 = velocity / seconds
        
        // Path 2: m / (s * s)
        let accel2 = meters / (seconds * seconds)
        
        // 1. Check strict equivalence
        #expect(accel1 == accel2)
        #expect(accel1.signature == accel2.signature)
        
        // 2. Check canonical symbol generation
        // Both should algebraically resolve to ["m": 1, "sec": -2]
        // The generator sorts alphabetically and formats as "m/sec²"
        #expect(accel1.symbol == "m/s²")
        #expect(accel2.symbol == "m/s²")
    }
    
    @Test("Explicit aliased units equate mathematically to raw derived units")
    func testExplicitAliasEquivalence() throws {
        // Create an explicit alias for Force
        let explicitNewtons = ExpressionUnit(symbol: "N", wrapping: kilograms * meters / (seconds * seconds))
        
        // Compute raw force: kg * m / sec²
        let rawForceUnit = kilograms * (meters / (seconds * seconds))
        
        // 1. They must evaluate as equal (signatures match)
        #expect(rawForceUnit.isEquivalent(to: explicitNewtons))
        
        // 2. But their symbols behave appropriately!
        #expect(explicitNewtons.symbol == "N")
        
        // The raw unit sorts terms alphabetically: kg(1), m(1), sec(-2) -> "kg·m/sec²"
        #expect(rawForceUnit.symbol == "kg·m/s²")
    }
    
    @Test("Derived Acceleration and Force Unit Derivations")
    func testForceAndAccelerationDerivations() throws {
        let mass = StandardUnits.kilograms
        let distance = StandardUnits.meters
        let time = StandardUnits.seconds
        
        // Velocity: m / sec
        let velocity = distance / time
        #expect(velocity.category == .speed)
        
        // Acceleration: (m / sec) / sec -> m/sec²
        let acceleration = velocity / time
        #expect(acceleration == StandardUnits.metersPerSecondSquared)
        #expect(acceleration.category == .acceleration)
        
        // Force: kg * (m/sec²) -> kg·m/sec² (which is equivalent to Newtons)
        let force = mass * acceleration
        #expect(force.isEquivalent(to: StandardUnits.newtons))
        #expect(force.category == .force)
    }
    
    
    @Test("Derived Units are consistent regardless of mathematical grouping")
    func testAccelerationUnitComputations() throws {
        let meters = StandardUnits.meters
        let seconds = StandardUnits.seconds
        
        // Path 1: (m / sec) / sec
        let velocity = meters / seconds
        let a1 = velocity / seconds
        
        // Path 2: m / (sec * sec)
        let a2 = meters / (seconds * seconds)
        
        // The underlying units attached must match mathematically
        #expect(a1 == a2)
        
        // The canonical symbols should identical and perfectly reduced
        #expect(a1.symbol == "m/s²")
        #expect(a2.symbol == "m/s²")
        
        // Both should land squarely in the acceleration category
        #expect(a1.category == .acceleration)
        #expect(a2.category == .acceleration)
    }
}
