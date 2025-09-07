import SwiftUI

// MARK: - Animation Completion Utility

/// Observes an animatable value and invokes a closure once the animation reaches the target value.
private struct _AnimationCompletionObserver<Value>: AnimatableModifier where Value: VectorArithmetic & Equatable {
    nonisolated(unsafe) var targetValue: Value
    nonisolated(unsafe) var onComplete: () -> Void
    nonisolated(unsafe) private var observed: Value

    // SwiftUI drives this from the old value to the new (target) value.
    nonisolated var animatableData: Value {
        get { observed }
        set {
            // Update observed value and check for completion.
            observed = newValue
            checkIfFinished(current: newValue)
        }
    }

    init(observedValue: Value, targetValue: Value, onComplete: @escaping () -> Void) {
        self.observed = observedValue
        self.targetValue = targetValue
        self.onComplete = onComplete
    }

    func body(content: Content) -> some View { content }

    nonisolated private func checkIfFinished(current: Value) {
        if current == targetValue {
            // Defer to next runloop tick to avoid state mutation during view updates.
            DispatchQueue.main.async { onComplete() }
        }
    }
}

extension View {
    /// Calls `action` when SwiftUI finishes animating `value` to its latest target.
    func onAnimationCompleted<Value: VectorArithmetic & Equatable>(for value: Value, perform action: @escaping () -> Void) -> some View {
        modifier(_AnimationCompletionObserver(observedValue: value, targetValue: value, onComplete: action))
    }
}
