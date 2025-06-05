//
//  DispatchTime+Seconds.swift
//  Stopwatch
//
//  Created by Reed hunsaker on 6/2/25.
//

import Foundation

extension Optional<DispatchTime> {
    
    /// Seconds which have elapsed between the start and stop time of a `DispatchTime`
    public func secondsSince(_ endTime: DispatchTime?) -> Double {
        guard let startTime = self else {
            return 0
        }
        return startTime.secondsSince(endTime)
    }
}

extension DispatchTime {
    /// Seconds which have elapsed between the start and stop time of a `DispatchTime`
    public func secondsSince(_ endTime: DispatchTime?) -> Double {
        let stopTime = endTime ?? DispatchTime.now()
        let elapsedTime = (stopTime.uptimeNanoseconds - self.uptimeNanoseconds)
        return (Double(elapsedTime)) / 1_000_000_000.0
    }
}
