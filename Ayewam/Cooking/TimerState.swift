//
//  TimerState.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation

struct TimerState: Equatable {
    let duration: Int
    let startTime: Date
    var remainingTime: Int
    var isRunning: Bool
    
    init(duration: Int, startTime: Date, isRunning: Bool = true) {
        self.duration = duration
        self.startTime = startTime
        self.remainingTime = duration
        self.isRunning = isRunning
    }
    
    var progress: Float {
        if duration == 0 { return 0 }
        return Float(duration - remainingTime) / Float(duration)
    }
    
    var formattedTimeRemaining: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static func == (lhs: TimerState, rhs: TimerState) -> Bool {
        return lhs.duration == rhs.duration &&
               lhs.startTime == rhs.startTime &&
               lhs.remainingTime == rhs.remainingTime &&
               lhs.isRunning == rhs.isRunning
    }
}
