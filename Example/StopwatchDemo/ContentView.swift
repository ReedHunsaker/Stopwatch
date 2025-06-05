//
//  ContentView.swift
//  StopwatchDemo
//
//  Created by Reed hunsaker on 5/28/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Classic stopwatch demo") {
                    ClassicStopwatchDemoScreen()
                }
                NavigationLink("Stopwatch game demo") {
                    StopwatchGameDemoScreen()
                }
            }.navigationTitle("Stopwatch Demo App")
        }
    }
}

#Preview {
    ContentView()
}
