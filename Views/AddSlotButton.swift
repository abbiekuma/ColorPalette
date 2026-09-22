import SwiftUI

struct AddSlotButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(.secondary)
                .frame(height: 120)
                .overlay {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
        }
        .buttonStyle(.plain)
        .help("Add a new slot")
    }
}

#Preview {
    AddSlotButton {}
        .padding()
        .frame(width: 140)
}
