import Testing
@testable import S7Units

@Suite("ConversionEngine Tests")
struct ConversionEngineTests {
    
    // MARK: - Helper Tolerance Check
    private func assertAlmostEqual(
        _ actual: Double?,
        _ expected: Double,
        tolerance: Double = 0.001,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let actual else {
            Issue.record("Expected non nil Double, failing")
            return
        }
        #expect(abs(actual - expected) <= tolerance, "Expected \(expected), got \(actual)", sourceLocation: sourceLocation)
    }
    

    // MARK: - Length Conversions
    @Test("Length: In-category conversions")
    func testLengthConversions() {
        // Imperial
        let ftToIn = ConversionEngine.convert(value: 12.0, from: StandardUnits.feet, to: StandardUnits.inches)
        assertAlmostEqual(ftToIn, 144.0)
        
        let miToFt = ConversionEngine.convert(value: 1.0, from: StandardUnits.miles, to: StandardUnits.feet)
        assertAlmostEqual(miToFt, 5280.0)
        
        // Metric
        let mToCm = ConversionEngine.convert(value: 1.0, from: StandardUnits.meters, to: StandardUnits.centimeters)
        assertAlmostEqual(mToCm, 100.0)
        
        let kmToM = ConversionEngine.convert(value: 1.5, from: StandardUnits.kilometers, to: StandardUnits.meters)
        assertAlmostEqual(kmToM, 1500.0)
        
        // Cross-system
        let inToCm = ConversionEngine.convert(value: 1.0, from: StandardUnits.inches, to: StandardUnits.centimeters)
        assertAlmostEqual(inToCm, 2.54)
    }

    // MARK: - Mass Conversions
    @Test("Mass: In-category conversions")
    func testMassConversions() {
        let lbsToOz = ConversionEngine.convert(value: 1.0, from: StandardUnits.pounds, to: StandardUnits.ounces)
        assertAlmostEqual(lbsToOz, 16.0)
        
        let kgToG = ConversionEngine.convert(value: 2.5, from: StandardUnits.kilograms, to: StandardUnits.grams)
        assertAlmostEqual(kgToG, 2500.0)
        
        let kgToLbs = ConversionEngine.convert(value: 1.0, from: StandardUnits.kilograms, to: StandardUnits.pounds)
        assertAlmostEqual(kgToLbs, 2.20462)
    }

    
    @Test("Volume: Metric vs. US Customary Cup conversions")
    func testCupConversions() {
        // 1 US Customary Cup = 8.0 US fluid ounces
        let usCupToFlOz = ConversionEngine.convert(value: 1.0, from: StandardUnits.cups, to: StandardUnits.fluidOunces)
        assertAlmostEqual(usCupToFlOz, 8.0)
        
        // 1 Metric Cup = 250 mL
        let metricCupToMl = ConversionEngine.convert(value: 1.0, from: StandardUnits.metricCups, to: StandardUnits.milliliters)
        assertAlmostEqual(metricCupToMl, 250.0)
        
        // Cross-conversion: 1 Metric Cup ≈ 8.4535 US fl oz
        let metricCupToFlOz = ConversionEngine.convert(value: 1.0, from: StandardUnits.metricCups, to: StandardUnits.fluidOunces)
        assertAlmostEqual(metricCupToFlOz, 8.4535)
    }
    
    
    // MARK: - Volume Conversions
    @Test("Volume: In-category conversions")
    func testVolumeConversions() {
        let galToQt = ConversionEngine.convert(value: 1.0, from: StandardUnits.gallons, to: StandardUnits.quarts)
        assertAlmostEqual(galToQt, 4.0)
        
        let qtToPt = ConversionEngine.convert(value: 1.0, from: StandardUnits.quarts, to: StandardUnits.pints)
        assertAlmostEqual(qtToPt, 2.0)
        
        let tbspToTsp = ConversionEngine.convert(value: 1.0, from: StandardUnits.tablespoons, to: StandardUnits.teaspoons)
        assertAlmostEqual(tbspToTsp, 3.0)
        
        let cupToFlOz = ConversionEngine.convert(value: 1.0, from: StandardUnits.cups, to: StandardUnits.fluidOunces)
        assertAlmostEqual(cupToFlOz, 8.0)
        
        let lToMl = ConversionEngine.convert(value: 1.0, from: StandardUnits.liters, to: StandardUnits.milliliters)
        assertAlmostEqual(lToMl, 1000.0)
    }

    // MARK: - Time Conversions (Standard & Custom Dimensions)
    @Test("Time: In-category conversions including custom days, weeks, months, years")
    func testTimeConversions() {
        let minToSec = ConversionEngine.convert(value: 1.5, from: StandardUnits.minutes, to: StandardUnits.seconds)
        assertAlmostEqual(minToSec, 90.0)
        
        let hrToMin = ConversionEngine.convert(value: 2.0, from: StandardUnits.hours, to: StandardUnits.minutes)
        assertAlmostEqual(hrToMin, 120.0)
        
        let dayToHr = ConversionEngine.convert(value: 1.0, from: StandardUnits.days, to: StandardUnits.hours)
        assertAlmostEqual(dayToHr, 24.0)
        
        let wkToDay = ConversionEngine.convert(value: 2.0, from: StandardUnits.weeks, to: StandardUnits.days)
        assertAlmostEqual(wkToDay, 14.0)
        
        let moToDay = ConversionEngine.convert(value: 1.0, from: StandardUnits.months, to: StandardUnits.days)
        assertAlmostEqual(moToDay, 30.0)
        
        let qrToMo = ConversionEngine.convert(value: 1.0, from: StandardUnits.quarters, to: StandardUnits.months)
        assertAlmostEqual(qrToMo, 3.0)
        
        let yrToDay = ConversionEngine.convert(value: 1.0, from: StandardUnits.years, to: StandardUnits.days)
        assertAlmostEqual(yrToDay, 365.0)
    }

    // MARK: - Rate / Frequency Conversions
    @Test("Frequency: Rate conversions (BPM & RPM)")
    func testRateConversions() {
        let bpmToRpm = ConversionEngine.convert(value: 120.0, from: StandardUnits.beatsPerMinute, to: StandardUnits.revolutionsPerMinute)
        assertAlmostEqual(bpmToRpm, 120.0)
    }

    // MARK: - Speed Conversions
    @Test("Speed: In-category conversions")
    func testSpeedConversions() {
        let mphToKph = ConversionEngine.convert(value: 60.0, from: StandardUnits.milesPerHour, to: StandardUnits.kilometersPerHour)
        assertAlmostEqual(mphToKph, 96.5606)
        
        let msToKph = ConversionEngine.convert(value: 10.0, from: StandardUnits.metersPerSecond, to: StandardUnits.kilometersPerHour)
        assertAlmostEqual(msToKph, 36.0)
        
        let mphToFps = ConversionEngine.convert(value: 100.0, from: StandardUnits.milesPerHour, to: StandardUnits.feetPerSecond)
        assertAlmostEqual(mphToFps, 100.0*5280.0/60.0/60.0)
        
        let mphToMps = ConversionEngine.convert(value: 100.0, from: StandardUnits.milesPerHour, to: StandardUnits.metersPerSecond)
        assertAlmostEqual(mphToMps, 44.704)
    }

    // MARK: - Temperature Conversions
    @Test("Temperature: Offsets and absolute scale conversions")
    func testTemperatureConversions() {
        let fToC = ConversionEngine.convert(value: 32.0, from: StandardUnits.fahrenheit, to: StandardUnits.celsius)
        assertAlmostEqual(fToC, 0.0)
        
        let boilingFToC = ConversionEngine.convert(value: 212.0, from: StandardUnits.fahrenheit, to: StandardUnits.celsius)
        assertAlmostEqual(boilingFToC, 100.0)
        
        let cToK = ConversionEngine.convert(value: 0.0, from: StandardUnits.celsius, to: StandardUnits.kelvin)
        assertAlmostEqual(cToK, 273.15)
    }

    // MARK: - Energy & Power Conversions
    @Test("Energy & Power: In-category conversions")
    func testEnergyAndPowerConversions() {
        // 1. Small Calories (cal) to Joules (J)
        // Standard thermochemical calorie: 1 cal = 4.184 J
        let calToJ = ConversionEngine.convert(value: 1.0, from: StandardUnits.calories, to: StandardUnits.joules)
        assertAlmostEqual(calToJ, 4.184)
        
        // 2. Kilocalories (kcal) to Joules (J)
        // 1 kcal = 4,184 J
        let kcalToJ = ConversionEngine.convert(value: 1.0, from: StandardUnits.kilocalories, to: StandardUnits.joules)
        assertAlmostEqual(kcalToJ, 4184.0)
        
        // 3. Kilocalories (kcal) to Kilojoules (kJ)
        // 1 kcal = 4.184 kJ
        let kcalToKj = ConversionEngine.convert(value: 1.0, from: StandardUnits.kilocalories, to: StandardUnits.kilojoules)
        assertAlmostEqual(kcalToKj, 4.184)
        
        // 4. Dietary Calories (Cal) to Kilocalories (kcal)
        // 1 Dietary Cal = 1 kcal (1:1 ratio check)
        let dietaryToKcal = ConversionEngine.convert(value: 500.0, from: StandardUnits.dietaryCalories, to: StandardUnits.kilocalories)
        assertAlmostEqual(dietaryToKcal, 500.0)
        
        // 5. Kilojoules (kJ) to Dietary Calories (Cal)
        // Reverse calculation: 1000 kJ = ~239.0057 kcal
        let kjToDietary = ConversionEngine.convert(value: 1000.0, from: StandardUnits.kilojoules, to: StandardUnits.dietaryCalories)
        assertAlmostEqual(kjToDietary, 239.005736, tolerance: 1e-5)
        
        // 6. Small Calories (cal) to Kilojoules (kJ)
        // 1000 cal = 4.184 kJ
        let calToKj = ConversionEngine.convert(value: 1000.0, from: StandardUnits.calories, to: StandardUnits.kilojoules)
        assertAlmostEqual(calToKj, 4.184)
        
        // 7. Joules (J) to Kilocalories (kcal)
        // 10,000 J = 10 kJ = 2.390057 kcal
        let jToKcal = ConversionEngine.convert(value: 10_000.0, from: StandardUnits.joules, to: StandardUnits.kilocalories)
        assertAlmostEqual(jToKcal, 2.390057, tolerance: 1e-5)
        
        let wToW = ConversionEngine.convert(value: 250.0, from: StandardUnits.watts, to: StandardUnits.watts)
        assertAlmostEqual(wToW, 250.0)
    }

    // MARK: - Edge Cases & Mismatched Dimensions
    @Test("Edge Cases: Identity, .none, and cross-category safety fallbacks")
    func testEdgeCasesAndFallbacks() {
        // Identity
        let sameUnit = ConversionEngine.convert(value: 50.0, from: StandardUnits.kilograms, to: StandardUnits.kilograms)
        #expect(sameUnit == 50.0)
        
        // Either is .none
        let fromNone = ConversionEngine.convert(value: 10.0, from: StandardUnits.none, to: StandardUnits.meters)
        #expect(fromNone == nil)
        
        let toNone = ConversionEngine.convert(value: 10.0, from: StandardUnits.meters, to: StandardUnits.none)
        #expect(toNone == nil)
        
        // Mismatched categories (e.g. Mass to Length) must safely return original value
        let invalidCross = ConversionEngine.convert(value: 100.0, from: StandardUnits.miles, to: StandardUnits.pounds)
        #expect(invalidCross == nil)
        
        let invalidTimeMass = ConversionEngine.convert(value: 10.0, from: StandardUnits.days, to: StandardUnits.kilograms)
        #expect(invalidTimeMass == nil)
    }

    
    @Test("Acceleration: G-Force to meters per second squared conversions")
    func testAccelerationConversions() {
        // 1.0 G = 9.80665 m/s²
        let gToMs2 = ConversionEngine.convert(value: 1.0, from: StandardUnits.standardGravity, to: StandardUnits.metersPerSecondSquared)
        assertAlmostEqual(gToMs2, 9.80665)
        
        // 19.6133 m/s² = 2.0 G
        let ms2ToG = ConversionEngine.convert(value: 19.6133, from: StandardUnits.metersPerSecondSquared, to: StandardUnits.standardGravity)
        assertAlmostEqual(ms2ToG, 2.0)
    }
    
}
