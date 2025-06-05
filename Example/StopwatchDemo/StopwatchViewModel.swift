//
//  StopwatchViewModel.swift
//  StopwatchDemo
//
//  Created by Reed hunsaker on 6/2/25.
//

import Observation
import SwiftUI
import Foundation
import Stopwatch

@Observable
@MainActor
class StopwatchViewModel {
    
    @ObservationIgnored
    let stopwatch = Stopwatch()
    
    var elapsedTime: String = "0.0"
    var elapsedLapTime: String = "0.0"
    var laps = [String]()
    var phase: StopwatchPhase = .initialized
    
    enum StopwatchAction {
        case start
        case stop
        case reset
        case lap
    }
    
    func dispatchAction(_ action: StopwatchAction) {
        Task {
            switch action {
            case .start:
                await stopwatch.start()
                
            case .stop:
                await stopwatch.stop()
                Task { @MainActor in
                    elapsedTime = await stopwatch.totalTimeElapsedInSeconds.toSecondsString()
                }
                
            case .reset:
                await stopwatch.reset()
                Task { @MainActor in
                    elapsedTime = "0.0"
                    elapsedLapTime = "0.0"
                    laps = []
                }
                
            case .lap:
                await stopwatch.lap()
                Task { @MainActor in
                    laps = await stopwatch.laps.map { $0.toSecondsString() }
                }
            }
            
            Task { @MainActor in
                phase = await stopwatch.phase
            }
        }
    }
    
    func pollTime() {
        Task {
            for await snapshot in await self.stopwatch.poll() {
                Task { @MainActor in
                    self.elapsedTime = snapshot.totalTimeElapsedInSeconds.toSecondsString()
                    self.elapsedLapTime = snapshot.lapTimeElapsedInSeconds.toSecondsString()
                }
            }
        }
    }
}

extension Double {
    func toSecondsString() -> String {
        String(format: "%.3f", self)
    }
}
