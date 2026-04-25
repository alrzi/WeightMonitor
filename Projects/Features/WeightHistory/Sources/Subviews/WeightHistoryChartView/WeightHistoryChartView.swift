//
//  WeightHistoryChartView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 29.10.2025.
//

import Charts
import Domain
import SwiftUI
import UIComponents

struct WeightHistoryChartView: View {
    let weights: [Weight]
    let weightUnit: WeightUnit

    @Environment(\.locale)
    private var locale
    @State private var period: WeightHistoryChartPeriod = .all

    private var filteredWeights: [Weight] {
        guard let start = period.startDate(calendar: locale.calendar) else {
            return weights.reversed()
        }

        return
            weights
            .filter { $0.createdAt >= start }
            .reversed()
    }

    var body: some View {
        Section {
            periodPicker
            weightChart
        } header: {
            headerView
        }
    }

    private var periodPicker: some View {
        Picker("Period", selection: $period) {
            ForEach(WeightHistoryChartPeriod.allCases) { period in
                Text(period.rawValue)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding(.bottom, 8)
    }

    private var weightChart: some View {
        Chart(filteredWeights, id: \.id) { weight in
            LineMark(
                x: .value("Date", weight.createdAt),
                y: .value("Weight (kg)", weight.mass)
            )
            .foregroundStyle(.blue)
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Date", weight.createdAt),
                y: .value("Weight (\(weightUnit.toUnitMass().symbol))", weight.mass)
            )
            .foregroundStyle(.blue)
            .symbolSize(30)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let mass = value.as(Double.self) {
                        Text(
                            Measurement(value: mass, unit: weightUnit.toUnitMass())
                                .converted(to: weightUnit.toUnitMass())
                                .formattedNarrow()
                        )
                    }
                }
            }
        }
        .chartYScale(domain: yDomain)
        .frame(height: 240)
        .animation(.easeInOut, value: filteredWeights)
    }

    private var headerView: some View {
        VStack(alignment: .leading) {
            Text("График веса")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 16)

            Text("Динамика изменения веса по датам")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }

    private var yDomain: ClosedRange<Double> {
        let masses = filteredWeights.map(\.mass)

        guard let min = masses.min(),
            let max = masses.max()
        else {
            return 0...150
        }

        let lower = (min - 2).rounded(.down)
        let upper = (max + 2).rounded(.up)

        return Swift.max(lower, 0)...upper
    }
}

#Preview {
    WeightHistoryChartView(
        weights: Weight.mockYearlyWeights(
            startMass: 56,
            variation: 0.8,
            seed: 1
        ),
        weightUnit: .metric
    )
}
