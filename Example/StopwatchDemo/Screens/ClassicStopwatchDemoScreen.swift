//
//  ClassicStopwatchDemoScreen.swift
//  StopwatchDemo
//
//  Created by Reed hunsaker on 6/2/25.
//

import SwiftUI

struct ClassicStopwatchDemoScreen: View {
    let viewModel = StopwatchViewModel()
    var body: some View {
        VStack(spacing: 40) {
            timerView
                .onAppear {
                    viewModel.pollTime()
                }
            buttonsView
            
            lapsView
        }
        .padding()
    }
    
    var timerView: some View {
        Text(String(viewModel.elapsedTime))
            .font(.system(size: 64, weight: .semibold, design: .monospaced))
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .shadow(radius: 4)
            )
    }
    
    var buttonsView: some View {
        HStack(spacing: 32) {
            
            if viewModel.phase == .initialized {
                Button(action: {
                    viewModel.dispatchAction(.start)
                }) {
                    Text("Start")
                        .frame(width: 100, height: 44)
                        .background(viewModel.phase == .running ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                let isRunning = viewModel.phase == .running
                Button(action: {
                    viewModel.dispatchAction(isRunning ? .stop : .start)
                }) {
                    Text(isRunning ? "Stop" : "Resume")
                        .frame(width: 100, height: 44)
                        .background(isRunning ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            
            if viewModel.phase == .stopped {
                Button(action: {
                    viewModel.dispatchAction(.reset)
                }) {
                    Text("Reset")
                        .frame(width: 100, height: 44)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
            } else if viewModel.phase == .running {
                Button(action: {
                    viewModel.dispatchAction(.lap)
                }) {
                    Text("Lap")
                        .frame(width: 100, height: 44)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    var lapsView: some View {
        VStack(alignment: .leading) {
            Text("Laps")
                .font(.headline)
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(viewModel.laps.enumerated()), id: \.offset) { index, lap in
                            let lapIndex = index + 1
                            LapView(timeElapsed: String(viewModel.laps[index]), index: lapIndex)
                                .id(lapIndex)
                        }
                        RunningLapView(viewModel: viewModel)
                    }
                    .onChange(of: viewModel.laps) {
                        let lastIndex = viewModel.laps.count + 1
                        scrollProxy.scrollTo(lastIndex)
                    }
                    .padding(.top)
                }
            }
        }
    }
}

struct RunningLapView: View {
    let viewModel: StopwatchViewModel
    
    var body: some View {
        let isEmpty = viewModel.laps.isEmpty
        let lapIndex = viewModel.laps.count + 1
        let currentLapIndex = isEmpty ?  1 : lapIndex
        LapView(timeElapsed: viewModel.elapsedLapTime, index: currentLapIndex)
            .id(currentLapIndex)
    }
}

struct LapView: View {
    let timeElapsed: String
    /// A 1 base index
    let index: Int
    var body: some View {
        HStack {
            Text("Lap \(index)")
            Spacer()
            Text(timeElapsed)
                .font(.system(.body, design: .monospaced))
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}
