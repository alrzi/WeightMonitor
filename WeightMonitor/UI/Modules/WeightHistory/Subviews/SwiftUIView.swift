//
//  SwiftUIView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 29.10.2025.
//

import SwiftUI
import Charts
import WeigthMonitorDomain

struct WeightHistoryChartView: View {
    let weights: [Weight]

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
                    y: .value("Weight (kg)", weight.mass)
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
                                Measurement(value: mass, unit: UnitMass.kilograms)
                                    .formatted(.mass(style: .withOneComma, locale: locale))
                            )
                        }
                    }
                }
            }
            .frame(height: 240)
            .animation(.easeInOut, value: weights)
        } header: {
            VStack(alignment: .leading, spacing: 8) {
                Text("График веса")
                    .font(.headline)
                Text("Динамика изменения веса по датам")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider()
            }
            .padding(.top, 16)
            .background(Color(.systemBackground))
        }
    }
}

private extension FormatStyle where Self == Measurement<UnitMass>.FormatStyle {
    static func mass(style: FloatingPointFormatStyle<Double>, locale: Locale) -> Self {
        Measurement<UnitMass>.FormatStyle(
            width: .abbreviated,
            locale: locale,
            usage: .personWeight,
            numberFormatStyle: style
        )
    }
}

private extension FloatingPointFormatStyle<Double> {
    static var withOneComma: Self {
        .number.precision(.fractionLength(1))
    }

    static var withOneComaIncludingZero: Self {
        .withOneComma.sign(strategy: .always(includingZero: true))
    }
}

#Preview {
    WeightHistoryChartView(weights: [])
}
