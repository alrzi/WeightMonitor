import Domain
import SwiftUI

struct WatchWeightView: View {
    @ObservedObject private var viewModel: WatchWeightViewModel

    var body: some View {
        List {
            Section("Add") {
                TextField("Weight", text: $viewModel.mass)

                Button("Save") {
                    Task {
                        await viewModel.create()
                    }
                }
            }

            Section("History") {
                ForEach(viewModel.weights) { weight in
                    Text(weight.mass, format: .number.precision(.fractionLength(1)))
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .alert(
            "Sync error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    init(viewModel: WatchWeightViewModel) {
        self.viewModel = viewModel
    }
}
