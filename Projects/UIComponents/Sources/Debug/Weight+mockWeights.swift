//
//  Weight+mockWeights.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.11.2025.
//

import Foundation
import WeigthMonitorDomain

#if DEBUG
public extension Weight {
    /// Returns ~365 days of realistic weight data.
    /// - Parameters:
    ///   - startMass: The weight on the most recent day (default 75 kg).
    ///   - variation: Maximum daily change in kg (default 0.3 kg).
    ///   - seed: Optional seed for reproducible results.
    static func mockYearlyWeights(
        startMass: Double = 75.0,
        variation: Double = 0.3,
        seed: UInt64? = nil
    ) -> [Self] {
        // Use a deterministic RNG when a seed is supplied (useful for UI snapshots)
        var rng: any RandomNumberGenerator = seed
            .map { SeededGenerator(seed: $0) } ?? SystemRandomNumberGenerator()

        // Helper to produce a small random delta in the range [-variation, +variation]
        func randomDelta() -> Double {
            let range = -variation...variation
            return Double.random(in: range, using: &rng)
        }

        var result: [Weight] = []
        var currentMass = startMass
        let today = Date()
        let calendar = Calendar.current

        // Generate one entry per day, newest first
        for offset in 0..<365 {
            // Date for “offset” days ago
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!

            // Apply a random walk – keep the mass within a sensible band (50‑100 kg)
            currentMass = (currentMass + randomDelta())
                .clamped(to: 50.0...100.0)

            result.append(
                Weight(
                    id: Int64(offset),
                    createdAt: date,
                    mass: (currentMass * 10).rounded() / 10   // round to 0.1 kg
                )
            )
        }
        return result
    }
}

// MARK: - Small utilities

public extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // Xorshift64* – a tiny, fast PRNG
        self.state = seed == 0 ? 0xdeadbeef : seed
    }

    mutating func next() -> UInt64 {
        var x = state
        x ^= x &>> 12
        x ^= x &<< 25
        x ^= x &>> 27
        state = x
        return x &* 2685821657736338717
    }
}
#endif
