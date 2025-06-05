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
public actor Stopwatch {
    
    /// Laps are saved as the total seconds that have elapsed since the last lap was recorded
    ///
    /// The first lap recorded is the number of seconds that have elapsed since the stopwatch was started
    public var laps: [Double] {
        get async {
            await getLapTimes()
        }
    }
    
    /// The total time elapsed in seconds since the stopwatch has started
    /// This does not included the time the stopwatch was stopped
    public var totalTimeElapsedInSeconds: Double {
        secondsElapsed + pauseDiff
    }
    
    public var secondsElapsedThisLap: Double {
        get async {
            guard let lastLap = _laps.last else { return totalTimeElapsedInSeconds }
            return await lastLap.secondsElapsed
        }
    }
    
    /// The current phase the stopwatch is in
    public var phase: StopwatchPhase = .initialized
    
    
    public init() {
        self.isLap = false
        _laps.append(Stopwatch.lap())
    }
    
    init(isLap: Bool) {
        self.isLap = isLap
    }
    
    deinit {
        pollingContinuation?.finish()
    }
    
    /// Sets a start time and begins measuring the time that has elapsed
    ///
    /// If the stop watch was stopped (or paused) it will store the seconds measured and reset the start time
    public func start() {
        if phase == .stopped {
            pauseDiff += secondsElapsed
        }
        startTime = DispatchTime.now()
        stopTime = nil
        phase = .running
        
        Task {
            await _laps.last?.start()
        }
        
        pollingTask = createPollingTask?()
    }
    
    /// Stops a stopwatch from running
    ///
    /// It can be resumed and the time elapsed while stopped is not counted
    public func stop() {
        guard stopTime == nil else { return }
        stopTime = DispatchTime.now()
        phase = .stopped
        Task {
            await _laps.last?.stop()
        }
        pollingTask?.cancel()
    }
    
    
    /// Records a lap in the stopwatch if running
    public func lap() {
        guard phase == .running, !isLap else { return }
        let newLap = Stopwatch.lap()
        let lastLap = _laps.last
        Task {
            await lastLap?.stop()
            await newLap.start()
        }
        _laps.append(newLap)
    }
    
    
    /// Resets the stopwatch to its initial values
    public func reset() {
        startTime = nil
        stopTime = nil
        pauseDiff = 0
        if !isLap {
            _laps = [Stopwatch.lap()]
        }
        phase = .initialized
    }
    
    
    /// Polls the stopwatch for updated `totalTimeElapsedInSeconds`
    ///
    /// The polling task is canceled when the stopwatch is stopped and recreated when it resumes.
    public func poll(every duration: ContinuousClock.Instant.Duration = .milliseconds(10)) -> AsyncStream<StopwatchSnapshot> {
        
        self.createPollingTask = { [weak self] in
            Task.detached {
                while true {
                    try await Task.sleep(for: duration)
                    guard let self else { return }
                    let snapshot = await self.currentSnapshot
                    await self.pollingContinuation?.yield(snapshot)
                }
            }
        }
        
        // An async stream of size 1
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            
            self.pollingContinuation = continuation
            
            self.pollingTask = self.createPollingTask?()
            
            Task {
                let snapshot = await self.currentSnapshot
                continuation.yield(snapshot)
            }
            
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
    
    /// Each lap is just another stopwatch
    private var _laps = [Stopwatch]()
    
    /// Is the current instance of stopwatch a lap
    private let isLap: Bool
    
    private var currentSnapshot: StopwatchSnapshot {
        get async {
            let totalTimeElapsedInSeconds = self.totalTimeElapsedInSeconds
            return await StopwatchSnapshot(
                totalTimeElapsedInSeconds: totalTimeElapsedInSeconds,
                lapTimeElapsedInSeconds: _laps.last?.totalTimeElapsedInSeconds ?? totalTimeElapsedInSeconds
            )
        }
    }
    
    /// Computes the seconds elapsed from the start time to the stop time
    private var secondsElapsed: Double {
        startTime.secondsSince(stopTime)
    }
    
    private var createPollingTask: (@Sendable () -> Task<Void, any Error>)?
    
    private var pollingTask: Task<Void, any Error>?
    
    private var pollingContinuation: AsyncStream<StopwatchSnapshot>.Continuation?
    
    private func getLapTimes() async -> [Double] {
        var lapTimes = [Double]()
        for lap in _laps {
            guard await lap.phase == .stopped else { continue }
            await lapTimes.append(lap.totalTimeElapsedInSeconds)
        }
        return lapTimes
    }
    
    static func lap() -> Self {
        .init(isLap: true)
    }
}
