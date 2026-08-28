import Testing
@testable import S7Units

@Suite("Unit Engine Physics & Conversion Tests")
struct UnitEngineTests {
    
    // MARK: - 1. Signature & Math Tests
    
    @Test("Unit Multiplication creates correct dimensional signatures")
    func testUnitMultiplication() {
        let area = StandardUnits.meters * StandardUnits.meters
        
        #expect(area.symbol == "m·m")
        #expect(area.signature.length == 2)
        #expect(area.signature.mass == 0)
        #expect(area.category == .none) // Compound unit fallback
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
}
