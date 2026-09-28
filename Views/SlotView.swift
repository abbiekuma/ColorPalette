import SwiftUI

struct SlotView: View {
    @Environment(PaletteStore.self) private var store
    let slotID: UUID

    @State private var didCopyHex = false

    // LEARN: 从 store 实时查找格子，保证改色后 UI 立刻更新
    private var slot: PaletteSlot? {
        store.slots.first { $0.id == slotID }
    }

    var body: some View {
        Group {
            if let slot, let savedColor = slot.color {
                filledSlotView(savedColor)
            } else {
                emptySlotView
            }
        }
        .frame(height: PaletteTheme.slotHeight)
        .overlay(alignment: .topLeading) {
            if slot?.color != nil {
                Menu {
                    Button("Pick Color") { startEyedropper() }
                    Button("Choose Color") { startColorPanel() }
                    Button("Copy HEX") { copyHex() }
                    Divider()
                    Button("Clear", role: .destructive) {
                        store.clearColor(for: slotID)
                    }
                } label: {
                    CuteMenuButton()
                }
                .buttonStyle(.plain)
                .menuIndicator(.hidden)
                .offset(x: 8, y: 8)
            }
        }
        .overlay(alignment: .topTrailing) {
            if store.canRemoveSlot {
                CuteDeleteButton {
                    store.removeSlot(id: slotID)
                }
                .offset(x: 6, y: -6)
            }
        }
        .padding(.trailing, PaletteTheme.chunk)
        .padding(.bottom, PaletteTheme.chunk)
    }

    // MARK: - 空格子

    private var emptySlotView: some View {
        RoundedRectangle(cornerRadius: PaletteTheme.corner, style: .continuous)
            .fill(PaletteTheme.creamSoft.opacity(0.7))
            .overlay {
                DashedRoundedFrame()
                    .opacity(0.55)
            }
            .shadow(color: PaletteTheme.cocoa.opacity(0.08), radius: 6, x: 2, y: 4)
            .overlay {
                VStack(spacing: 10) {
                    CutePillButton(title: "Pick", systemImage: "eyedropper") {
                        startEyedropper()
                    }
                    CutePillButton(title: "Palette", systemImage: "paintpalette.fill") {
                        startColorPanel()
                    }
                }
            }
    }

    // MARK: - 已填色

    private func filledSlotView(_ savedColor: SavedColor) -> some View {
        let blob = RoundedRectangle(cornerRadius: PaletteTheme.corner, style: .continuous)

        return blob
            .fill(savedColor.swiftUIColor)
            .overlay(
                blob.stroke(PaletteTheme.frame, lineWidth: 3.5)
            )
            .shadow(color: PaletteTheme.cocoa.opacity(0.2), radius: 10, x: 4, y: 8)
            .overlay(alignment: .bottom) {
                Button(action: copyHex) {
                    Text(didCopyHex ? "copied ♡" : savedColor.hex)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(PaletteTheme.cocoa)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule(style: .continuous)
                                .fill(PaletteTheme.creamSoft.opacity(0.92))
                        )
                        .shadow(color: PaletteTheme.cocoa.opacity(0.14), radius: 3, x: 1, y: 2)
                }
                .buttonStyle(.plain)
                .help("Click to copy HEX")
                .padding(.bottom, 12)
            }
            .help("Click the HEX code to copy. Use the menu to change or clear.")
    }

    // MARK: - Helpers

    private func copyHex() {
        store.copyHexToClipboard(for: slotID)
        didCopyHex = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            didCopyHex = false
        }
    }

    private func startColorPanel() {
        ColorPanelService.shared.pick(initial: slot?.color) { color in
            store.setColor(color, for: slotID)
        }
    }

    private func startEyedropper() {
        EyedropperService.pick { color in
            // LEARN: 闭包回到主线程更新 UI（macOS 要求界面操作在主线程）
            DispatchQueue.main.async {
                guard let color else { return }
                store.setColor(color, for: slotID)
            }
        }
    }
}

#Preview("Empty") {
    let store = PaletteStore()
    let id = store.slots[0].id
    return SlotView(slotID: id)
        .environment(store)
        .padding()
        .frame(width: 150)
        .background(PaletteTheme.cream)
}

#Preview("Filled") {
    let store = PaletteStore()
    let id = store.slots[0].id
    store.setColor(SavedColor(red: 0.89, green: 0.68, blue: 0.70), for: id)
    return SlotView(slotID: id)
        .environment(store)
        .padding()
        .frame(width: 150)
        .background(PaletteTheme.cream)
}
