//
//  StopwatchPhaseTests.swift
//  Stopwatch
//
//  Created by Reed hunsaker on 6/02/25.
//

@testable import Stopwatch
import Testing

@Suite("Stopwatch Phase Tests")
struct StopwatchPhaseTests {
    
    @Test("Test Phase: Initialized")
    func initializedPhase() async {
        let stopwatch = Stopwatch()
        
        #expect(await stopwatch.phase == .initialized)
    }
    
    @Test("Test Phase: Running")
    func runningPhase() async {
        let stopwatch = Stopwatch()
        
        await stopwatch.start()
        
        #expect(await stopwatch.phase == .running)
    }
    
    @Test("Test Phase: Stopped")
    func stoppedPhase() async {
        let stopwatch = Stopwatch()
                
        await stopwatch.start()
        
        await stopwatch.stop()
        
        #expect(await stopwatch.phase == .stopped)
    }
}
