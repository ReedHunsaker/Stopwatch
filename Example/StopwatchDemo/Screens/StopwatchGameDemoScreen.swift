//
//  StopwatchGameDemoScreen.swift
//  StopwatchDemo
//
//  Created by Reed hunsaker on 6/5/25.
//

import SwiftUI

struct StopwatchGameDemoScreen: View {
    @State var buttonPosition: CGPoint = .zero
    @State var screenSize: CGSize = .zero
    @State var score = 0
    @State var isGameOver = false
    var stopwatch = StopwatchViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                    .onAppear {
                        screenSize = geometry.size
                        startGame()
                    }
                
                if !isGameOver {
                    Button(action: {
                        if score < 10 {
                            stopwatch.dispatchAction(.lap)
                            score += 1
                            moveButton(in: geometry.size)
                        } else {
                            stopwatch.dispatchAction(.stop)
                            isGameOver = true
                        }
                    
                    }) {
                        Text("Tap Me!")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .position(buttonPosition)
                } else {
                    VStack(spacing: 20) {
                        Text("Game Over")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text("Total time: \(stopwatch.elapsedTime)")
                            .font(.title)
                            .foregroundColor(.white)
                        Button("Restart") {
                            resetGame()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        List {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(stopwatch.laps.enumerated()), id: \.offset) { index, lap in
                                    Text("Tap \(index + 1): \(lap)")
                                        .font(.title2)
                                }
                            }
                            .listRowBackground(Color.black)
                        }
                        .padding(.horizontal, 16)
                        .foregroundStyle(.white)
                        .background(Color.black)
                        .scrollContentBackground(.hidden)
                        .scrollBounceBehavior(.basedOnSize)
                        .frame(height: 400)

                    }
                }
            }
        }
    }
    
    func startGame() {
        moveButton(in: screenSize)
        stopwatch.dispatchAction(.start)
    }
    
    func moveButton(in size: CGSize) {
        buttonPosition = CGPoint(
            x: CGFloat.random(in: 60...(size.width - 60)),
            y: CGFloat.random(in: 120...(size.height - 60))
        )
    }
    
    func resetGame() {
        stopwatch.dispatchAction(.reset)
        isGameOver = false
        score = 0
        startGame()
    }
}

struct StopwatchGameDemoScreen_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchGameDemoScreen()
    }
}
