import SwiftUI

struct AddSlotButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: PaletteTheme.corner, style: .continuous)
                .fill(PaletteTheme.creamSoft.opacity(0.7))
                .frame(height: PaletteTheme.slotHeight)
                .overlay { DashedRoundedFrame().opacity(0.55) }
                .shadow(color: PaletteTheme.cocoa.opacity(0.08), radius: 6, x: 2, y: 4)
                .overlay {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(PaletteTheme.cocoa.opacity(0.7))
                }
        }
        .buttonStyle(.plain)
        .help("Add a new slot")
        .padding(.trailing, PaletteTheme.chunk)
        .padding(.bottom, PaletteTheme.chunk)
    }
}

#Preview {
    AddSlotButton {}
        .padding()
        .frame(width: 150)
        .background(PaletteTheme.cream)
}
