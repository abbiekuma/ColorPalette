import SwiftUI

struct SlotView: View {
    @Environment(PaletteStore.self) private var store
    let slotID: UUID

    @State private var showingColorPicker = false
    @State private var pickerColor = Color.white

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
        .frame(height: 120)
        .sheet(isPresented: $showingColorPicker) {
            colorPickerSheet
        }
    }

    // MARK: - 空格子

    private var emptySlotView: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
            .foregroundStyle(.secondary.opacity(0.6))
            .overlay {
                VStack(spacing: 8) {
                    pickColorButton(title: "Pick", systemImage: "eyedropper") {
                        startEyedropper()
                    }
                    pickColorButton(title: "Palette", systemImage: "paintpalette") {
                        pickerColor = .white
                        showingColorPicker = true
                    }
                }
            }
    }

    // MARK: - 已填色

    private func filledSlotView(_ savedColor: SavedColor) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(savedColor.swiftUIColor)
            .overlay(alignment: .bottom) {
                Text(savedColor.hex)
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(contrastingTextColor(for: savedColor))
                    .padding(.bottom, 8)
            }
            .overlay(alignment: .topTrailing) {
                Menu {
                    Button("Pick Color") { startEyedropper() }
                    Button("Choose Color") {
                        pickerColor = savedColor.swiftUIColor
                        showingColorPicker = true
                    }
                    Button("Copy HEX") {
                        store.copyHexToClipboard(for: slotID)
                    }
                    Divider()
                    Button("Clear", role: .destructive) {
                        store.clearColor(for: slotID)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.body)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(contrastingTextColor(for: savedColor), .white.opacity(0.3))
                        .padding(8)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
            }
            .onTapGesture {
                store.copyHexToClipboard(for: slotID)
            }
            .help("Click to copy HEX. Use the menu to change or clear.")
    }

    // MARK: - 色板 Sheet

    private var colorPickerSheet: some View {
        VStack(spacing: 20) {
            Text("Choose Color")
                .font(.headline)

            // LEARN: ColorPicker 是 SwiftUI 内置的系统色板控件
            // LEARN: $pickerColor 是 Binding，双向绑定（类似 React 受控组件的 value + onChange）
            ColorPicker("Color", selection: $pickerColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 200)

            HStack {
                Button("Cancel") {
                    showingColorPicker = false
                }
                .keyboardShortcut(.cancelAction)

                Button("Confirm") {
                    store.setColor(SavedColor(color: pickerColor), for: slotID)
                    showingColorPicker = false
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 280)
    }

    // MARK: - Helpers

    private func pickColorButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
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

    private func contrastingTextColor(for color: SavedColor) -> Color {
        let luminance = 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue
        return luminance > 0.5 ? .black : .white
    }
}

#Preview("Empty") {
    let store = PaletteStore()
    let id = store.slots[0].id
    return SlotView(slotID: id)
        .environment(store)
        .padding()
        .frame(width: 140)
}

#Preview("Filled") {
    let store = PaletteStore()
    let id = store.slots[0].id
    store.setColor(SavedColor(red: 0.2, green: 0.5, blue: 0.9), for: id)
    return SlotView(slotID: id)
        .environment(store)
        .padding()
        .frame(width: 140)
}
