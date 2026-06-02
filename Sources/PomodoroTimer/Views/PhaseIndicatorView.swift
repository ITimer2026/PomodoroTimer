import SwiftUI

struct PhaseIndicatorView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "brain.head.profile")
            Text("Focus")
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.red.opacity(0.18))
        .foregroundStyle(.red)
        .clipShape(Capsule())
    }
}
