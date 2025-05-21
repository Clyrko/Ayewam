//
//  ActiveTimersView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct ActiveTimersView: View {
    let timers: [(stepIndex: Int, state: TimerState)]
    let steps: [Step]
    let onCancel: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Timers")
                .font(.headline)
            
            if timers.isEmpty {
                Text("No active timers")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .italic()
            } else {
                ForEach(timers, id: \.stepIndex) { timer in
                    timerRow(for: timer.stepIndex, state: timer.state)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func timerRow(for stepIndex: Int, state: TimerState) -> some View {
        let step = steps.first { Int($0.orderIndex) == stepIndex }
        
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(stepIndex + 1)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let instruction = step?.instruction {
                    Text(instruction)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(state.formattedTimeRemaining)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.orange)
            
            Button(action: { onCancel(stepIndex) }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}
