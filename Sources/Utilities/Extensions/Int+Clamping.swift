//
//  Int+Clamping.swift
//  MonstaGuru-macOS
//
//  Created by Mistral Vibe Code on 2026-05-04.
//

public extension Int {
    /// Clamps the value to the specified range.
    /// - Parameter range: The closed range to clamp the value to.
    /// - Returns: The value clamped to the range.
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
