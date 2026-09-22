import AppKit
import Foundation
import Observation

// LEARN: @Observable 让 SwiftUI 在属性变化时自动刷新界面（类似 React 的 state）
@Observable
final class PaletteStore {
    var slots: [PaletteSlot]

    private let persistence = PalettePersistence()

    init() {
        if let saved = persistence.load() {
            slots = saved
        } else {
            // 默认 5 个空格子
            slots = (0..<5).map { _ in PaletteSlot() }
        }
    }

    func setColor(_ color: SavedColor, for slotID: UUID) {
        guard let index = slots.firstIndex(where: { $0.id == slotID }) else { return }
        slots[index].color = color
        save()
    }

    func clearColor(for slotID: UUID) {
        guard let index = slots.firstIndex(where: { $0.id == slotID }) else { return }
        slots[index].color = nil
        save()
    }

    func addSlot() {
        slots.append(PaletteSlot())
        save()
    }

    func copyHexToClipboard(for slotID: UUID) {
        guard let slot = slots.first(where: { $0.id == slotID }),
              let hex = slot.color?.hex else { return }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(hex, forType: .string)
    }

    private func save() {
        persistence.save(slots)
    }
}
