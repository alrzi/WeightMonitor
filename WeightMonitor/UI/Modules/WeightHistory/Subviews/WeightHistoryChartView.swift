//
//  WeightHistoryChartView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 29.10.2025.
//

import SwiftUI
import Charts
import WeigthMonitorDomain

struct WeightHistoryChartView: View {
    let weights: [Weight]
    let weightUnit: WeightUnit

    @Environment(\.locale) private var locale

    var body: some View {
        Section {
            Chart(weights.reversed(), id: \.id) { weight in
                LineMark(
                    x: .value("Date", weight.createdAt),
                    y: .value("Weight (kg)", weight.mass)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", weight.createdAt),
                    y: .value("Weight (\(weightUnit.toUnitMass().symbol)", weight.mass)
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
                                MassFormatter
                                    .twoDigits
                                    .string(
                                        fromValue: Measurement(value: mass, unit: .kilograms)
                                            .converted(to: weightUnit.toUnitMass())
                                            .value,
                                        unit: weightUnit.toUnit()
                                    )
                            )
                        }
                    }
                }
            }
            .frame(height: 240)
            .animation(.easeInOut, value: weights)
        } header: {
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
    }
}

#Preview {
    WeightHistoryChartView(weights: Weight.mockWeights, weightUnit: .metric)
}
