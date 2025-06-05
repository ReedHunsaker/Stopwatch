//
//  StopwatchPhase.swift
//  Stopwatch
//
//  Created by Reed hunsaker on 5/28/25.
//

public enum StopwatchPhase: Sendable {
    
    /// The stopwatch has been created or reset but hasn't started running
    case initialized
    
    /// The stopwatch is measuring the elapsed time
    case running
    
    /// The stopwatch was running and has now been stopped
    case stopped
}
