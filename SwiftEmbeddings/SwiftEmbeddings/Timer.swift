//
//  Timer.swift
//
//  Created by Till Gartner on 17.10.25.
//

import Foundation

// MARK: - Public API

/// Times the execution of `block` and records it under `name`.
@discardableResult
public func timerTrack<T>(_ name: String, _ block: () throws -> T) rethrows -> T {
    let start = CFAbsoluteTimeGetCurrent()
    defer {
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        TimerRegistry.shared.record(name: name, duration: elapsed)
    }
    return try block()
}

/// Prints stats (count, total, average) for a specific timer name.
public func timerReport(_ name: String) {
    guard let stats = TimerRegistry.shared.report(name: name) else {
        print("⏱️ [\(name)] No recordings.")
        return
    }
    let totalStr = formatSeconds(stats.total)
    let avgStr   = formatSeconds(stats.average)
    print("⏱️ [\(name)] count=\(stats.count)  total=\(totalStr)  avg=\(avgStr)")
}

/// Resets the accumulated stats for a specific timer name.
public func timerReset(_ name: String) {
    TimerRegistry.shared.reset(name: name)
    print("🔄 [\(name)] reset.")
}

/// Optional: report all timers at once.
public func timerReportAll() {
    let all = TimerRegistry.shared.reportAll()
    if all.isEmpty {
        print("⏱️ No timers recorded.")
        return
    }
    print("=== ⏱️ Timer Report (all) ===")
    for (name, stats) in all.sorted(by: { $0.key < $1.key }) {
        let totalStr = formatSeconds(stats.total)
        let avgStr   = formatSeconds(stats.average)
        print("• [\(name)] count=\(stats.count)  total=\(totalStr)  avg=\(avgStr)")
    }
    print("============================")
}

// MARK: - Async variant

/// Times the execution of an async `operation` and records it under `name`.
@discardableResult
public func timerTrack<T>(_ name: String, _ operation: () async throws -> T) async rethrows -> T {
    let start = CFAbsoluteTimeGetCurrent()
    defer {
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        TimerRegistry.shared.record(name: name, duration: elapsed)
    }
    return try await operation()
}

// MARK: - Internal impl

private struct TimerStats: Sendable {
    var count: Int = 0
    var total: CFTimeInterval = 0
    var average: CFTimeInterval { count > 0 ? total / Double(count) : 0 }
}

private final class TimerRegistry {
    static let shared = TimerRegistry()

    private var store: [String: TimerStats] = [:]
    private let queue = DispatchQueue(label: "timer.registry.queue", qos: .userInitiated)

    func record(name: String, duration: CFTimeInterval) {
        queue.sync {
            var s = store[name] ?? TimerStats()
            s.count += 1
            s.total += duration
            store[name] = s
        }
    }

    func report(name: String) -> TimerStats? {
        queue.sync { store[name] }
    }

    func reset(name: String) {
        queue.sync { store[name] = nil }
    }

    func reportAll() -> [String: TimerStats] {
        queue.sync { store }
    }
}

// MARK: - Helpers

/// Formats seconds into a friendly string, choosing ms for small values.
private func formatSeconds(_ seconds: CFTimeInterval) -> String {
    if seconds < 1.0 {
        let ms = seconds * 1_000
        if ms < 1.0 {
            let µs = ms * 1_000
            return String(format: "%.0fµs", µs)
        } else if ms < 1000 {
            return String(format: "%.3fms", ms)
        }
    }
    return String(format: "%.6fs", seconds)
}
