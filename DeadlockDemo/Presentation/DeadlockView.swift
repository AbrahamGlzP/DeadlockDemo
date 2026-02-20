//
//  DeadlockView.swift
//  DeadlockDemo
//
//  Created by Abraham Gonzalez Puga on 20/02/26.
//

import SwiftUI


struct DeadlockView: View {
    
    @State private var viewModel = DeadlockViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(spacing: 10) {
                    Button("❌ Simulates deadlock GCD") {
                        viewModel.triggerDeadlock()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(viewModel.isRunning)
                    
                    Button("✅ Run with async/await") {
                        Task { await viewModel.runSafely() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(viewModel.isRunning)
                    
                    Button("⚠️ Deadlock between resources") {
                        Task { await viewModel.demonstrateMutualDeadlock() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(viewModel.isRunning)
                    
                }
                .padding(.horizontal)
                
                // Event log
                GroupBox("Log") {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.log, id: \.self) { entry in
                                Text(entry)
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                    }
                    .frame(maxHeight: 300)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Deadlocks")
        }
    }
    
}

#Preview {
    DeadlockView()
}
