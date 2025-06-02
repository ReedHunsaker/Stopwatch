//
//  StopwatchState.swift
//  Stopwatch
//
//  Created by Reed hunsaker on 5/28/25.
//

import Foundation

/// A programmatic stopwatch that computes the time elapsed lazily
///
/// ## Features include:
/// - Stopping the recording of elapsed time
/// - Resuming a stopwatch that has been stopped
/// - Recording a lap in the stopwatch
/// - Polling the stop watch with a custom duration for up to date `totalTimeElapsedInSeconds`
actor Stopwatch {
    
    /// Laps are saved as the total seconds that have elapsed since the last lap was recorded
    ///
    /// The first lap recorded is the number of seconds that have elapsed since the stopwatch was started
    private(set) var laps: [Double] = []
    
    /// The total time elapsed in seconds since the stopwatch has started
    /// This does not included the time the stopwatch was stopped
    public var totalTimeElapsedInSeconds: Double {
        secondsElapsed + pauseDiff
    }
    
    /// The current phase the stopwatch is in
    public var phase: StopwatchPhase = .initialized
        
    public init() {}
    
    deinit {
        pollingContinuation?.finish()
    }
    
    /// Sets a start time and begins measuring the time that has elapsed
    public func start() {
        guard startTime == nil else { return }
        startTime = DispatchTime.now()
        stopTime = nil
        phase = .running
    }
    
    /// Resumes a stopwatch that has been stopped
    public func resume() {
        guard phase == .stopped else { return }
        pauseDiff += secondsElapsed
        self.startTime = DispatchTime.now()
        self.stopTime = nil
        phase = .running
        pollingTask = createPollingTask?()
    }
    
    /// Stops a stopwatch from running
    ///
    /// It can be resumed and the time elapsed while stopped is not counted
    public func stop() {
        guard stopTime == nil else { return }
        stopTime = DispatchTime.now()
        phase = .stopped
        pollingTask?.cancel()
    }
    
    
    /// Records a lap in the stopwatch
    public func lap() {
        guard phase == .running else { return }
        laps.append(totalTimeElapsedInSeconds)
    }
    
    
    /// Resets the stopwatch to its initial values
    public func reset() {
        startTime = nil
        stopTime = nil
        pauseDiff = 0
        laps.removeAll()
        phase = .initialized
    }
    
    
    /// Polls the stopwatch for updated `totalTimeElapsedInSeconds`
    ///
    /// The polling task is canceled when the stopwatch is stopped and recreated when it resumes.
    public func poll(every duration: ContinuousClock.Instant.Duration = .milliseconds(10)) -> AsyncStream<Double> {
        
        self.createPollingTask = { [weak self] in
            Task.detached {
                try await Task.sleep(for: duration)
                guard let self else { return }
                await self.pollingContinuation?.yield(self.totalTimeElapsedInSeconds)
            }
        }
        
        // An async stream of size 1
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            
            self.pollingContinuation = continuation
            
            self.pollingTask = self.createPollingTask?()
            
            continuation.yield(totalTimeElapsedInSeconds)
            
            continuation.onTermination = { @Sendable _ in
                Task {
                    await self.pollingTask?.cancel()
                }
            }
        }
    }
    
    /// The dispatch time the stop watch starts recording from
    var startTime: DispatchTime?
    
    /// The stop time the stop watch records to
    ///
    /// The elapsed time is calculated as the diff between the stop and start time
    var stopTime: DispatchTime?
    
    /// The time elapsed before the stopwatch was paused.
    private var pauseDiff: Double = 0
    
    /// Computes the seconds elapsed from the start time to the stop time
    private var secondsElapsed: Double {
        startTime.secondsSince(stopTime)
    }
    
    private var createPollingTask: (@Sendable () -> Task<Void, any Error>)?
    
    private var pollingTask: Task<Void, any Error>?
    
    private var pollingContinuation: AsyncStream<Double>.Continuation?
}
