//
//  StopwatchPhase.swift
//  Stopwatch
//
//  Created by Reed hunsaker on 5/28/25.
//

public enum StopwatchPhase: Sendable {
    
    /// The stop watch has been created or reset but hasn't started running
    ///
    /// If it was reset it can not be resumed
    case initialized
    
    /// The stop watch is currently running
    case running
    
    /// The stop watch has stopped and can be resumed
    case stopped
}
