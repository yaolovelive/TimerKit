import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct ProgressRing: View {
    public let progress: Double
    public let state: TactState

    public init(progress: Double, state: TactState) {
        self.progress = progress
        self.state = state
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(state.primaryTextColor.opacity(0.05), lineWidth: 2)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(state.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.35), value: progress)
        }
        .padding(8)
    }
}

public struct IconButton: View {
    public let systemName: String
    public let isPrimary: Bool
    public let state: TactState
    public let action: () -> Void

    public init(
        systemName: String,
        isPrimary: Bool,
        state: TactState,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.isPrimary = isPrimary
        self.state = state
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: isPrimary ? 17 : 16, weight: isPrimary ? .semibold : .regular))
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isPrimary ? .white : state.secondaryTextColor)
        .background(isPrimary ? state.accentColor : Color.clear, in: Circle())
        .contentShape(Circle())
    }
}

public struct DetectionChip: View {
    public let detection: Detection

    public init(detection: Detection) {
        self.detection = detection
    }

    public var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.4), in: Capsule())
            .overlay {
                Capsule().stroke(.white.opacity(0.2), lineWidth: 1)
            }
            .foregroundStyle(TactState.capture.secondaryTextColor)
            .labelStyle(.titleAndIcon)
    }

    private var title: String {
        switch detection.kind {
        case .url: return "Link"
        case .date: return "Reminder"
        case .phone: return "Phone"
        case .email: return "Email"
        case .todo: return "Todo"
        case .tag(let name): return "#\(name)"
        case .question: return "Question"
        }
    }

    private var icon: String {
        switch detection.kind {
        case .url: return "link"
        case .date: return "calendar"
        case .phone: return "phone"
        case .email: return "envelope"
        case .todo: return "checkmark.circle.fill"
        case .tag: return "number"
        case .question: return "questionmark.circle"
        }
    }
}

public struct CheckInDelayPicker: View {
    @Binding public var selection: CheckInDelay?

    public init(selection: Binding<CheckInDelay?>) {
        _selection = selection
    }

    public var body: some View {
        FlowLayout(spacing: 8) {
            delayChip(title: "不提醒", icon: "bell.slash", delay: nil)
            ForEach(CheckInDelay.allCases, id: \.self) { delay in
                delayChip(title: delay.label, icon: "clock", delay: delay)
            }
        }
    }

    private func delayChip(title: String, icon: String, delay: CheckInDelay?) -> some View {
        Button {
            selection = delay
        } label: {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    (selection == delay ? TactState.capture.accentColor.opacity(0.25) : .white.opacity(0.4)),
                    in: Capsule()
                )
                .overlay {
                    Capsule().stroke(.white.opacity(selection == delay ? 0.5 : 0.2), lineWidth: 1)
                }
                .foregroundStyle(TactState.capture.secondaryTextColor)
        }
        .buttonStyle(.plain)
    }
}

public struct FlowLayout: Layout {
    public var spacing: CGFloat

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: width, height: y + rowHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
#endif
