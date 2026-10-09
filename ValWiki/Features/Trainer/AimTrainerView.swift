import SwiftUI
import UIKit
import Combine

/// 30-second flick trainer: tap the orbs before they fade. Best score is saved.
struct AimTrainerView: View {
    @AppStorage("aim.best") private var best = 0
    @State private var running = false
    @State private var score = 0
    @State private var misses = 0
    @State private var timeLeft = 30.0
    @State private var target = CGPoint(x: 0.5, y: 0.5)
    @State private var targetID = 0
    @State private var spawnedAt = Date()
    @State private var newBest = false

    private let roundLength = 30.0
    private let tick = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    private var accuracy: Int {
        let shots = score + misses
        return shots == 0 ? 100 : Int((Double(score) / Double(shots) * 100).rounded())
    }

    private var targetSize: CGFloat {
        let progress: Double = 1 - timeLeft / roundLength
        let size: Double = 64 - progress * 30
        return CGFloat(size)
    }

    var body: some View {
        VStack(spacing: 14) {
            GlassGroup(spacing: 10) {
                HStack(spacing: 10) {
                    stat("\(score)", "Hits")
                    stat("\(accuracy)%", "Accuracy")
                    stat(String(format: "%.1f", max(timeLeft, 0)), "Seconds")
                    stat("\(best)", "Best")
                }
            }
            .padding(.horizontal)

            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(colors: [VW.navy, VW.navy.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard running else { return }
                            misses += 1
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }

                    if running {
                        Orb(size: targetSize)
                            .id(targetID)
                            .position(x: target.x * geo.size.width, y: target.y * geo.size.height)
                            .transition(.scale.combined(with: .opacity))
                            .onTapGesture { hit(in: geo.size) }
                    } else {
                        VStack(spacing: 14) {
                            Image(systemName: newBest ? "trophy.fill" : "target")
                                .font(.system(size: 54, weight: .semibold))
                                .foregroundStyle(newBest ? .yellow : VW.red)
                                .symbolEffect(.bounce, value: newBest)
                            Text(score == 0 && misses == 0 ? "Tap the orbs as fast as you can" : (newBest ? "New best: \(score)!" : "You hit \(score)"))
                                .font(.headline)
                                .foregroundStyle(.white)
                            Button {
                                start(in: geo.size)
                            } label: {
                                Label(score == 0 && misses == 0 ? "Start" : "Play again", systemImage: "play.fill")
                                    .font(.headline)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            .glassProminentButton()
                        }
                    }
                }
            }
            .cardShape(28)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Aim Trainer")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(tick) { _ in
            guard running else { return }
            timeLeft -= 0.05
            if Date().timeIntervalSince(spawnedAt) > 1.6 {
                misses += 1
                respawn()
            }
            if timeLeft <= 0 { finish() }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(VW.title(24))
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 18)
    }

    private func start(in size: CGSize) {
        Haptics.tap()
        score = 0
        misses = 0
        timeLeft = roundLength
        newBest = false
        running = true
        respawn()
    }

    private func hit(in size: CGSize) {
        guard running else { return }
        score += 1
        Haptics.tap()
        respawn()
    }

    private func respawn() {
        withAnimation(.spring(duration: 0.18)) {
            target = CGPoint(x: .random(in: 0.12...0.88), y: .random(in: 0.1...0.9))
            targetID += 1
        }
        spawnedAt = Date()
    }

    private func finish() {
        running = false
        timeLeft = 0
        if score > best {
            best = score
            newBest = true
            Haptics.success()
        }
    }
}

private struct Orb: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(VW.red.opacity(0.25)).frame(width: size * 1.6, height: size * 1.6)
            Circle()
                .fill(RadialGradient(colors: [.white, VW.red], center: .center, startRadius: 1, endRadius: size / 2))
                .frame(width: size, height: size)
                .shadow(color: VW.red.opacity(0.8), radius: 12)
            Circle().stroke(.white.opacity(0.8), lineWidth: 2).frame(width: size * 0.45, height: size * 0.45)
        }
        .frame(width: size * 1.6, height: size * 1.6)
        .contentShape(Circle())
    }
}
