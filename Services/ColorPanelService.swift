import AppKit

// LEARN: NSColorPanel 是 macOS 系统调色板（单例窗口）。直接弹出它，就不用再包一层 SwiftUI sheet。
final class ColorPanelService: NSObject {
    static let shared = ColorPanelService()

    private var onChange: ((SavedColor) -> Void)?

    func pick(initial: SavedColor?, onChange: @escaping (SavedColor) -> Void) {
        self.onChange = onChange

        let panel = NSColorPanel.shared
        panel.showsAlpha = false
        panel.isContinuous = true

        // 先设颜色，再绑 action，避免打开时误触发一次保存
        if let initial {
            panel.color = NSColor(
                srgbRed: initial.red,
                green: initial.green,
                blue: initial.blue,
                alpha: 1
            )
        }

        panel.setTarget(self)
        panel.setAction(#selector(colorDidChange(_:)))
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func colorDidChange(_ sender: NSColorPanel) {
        let rgb = sender.color.usingColorSpace(.sRGB) ?? sender.color
        onChange?(
            SavedColor(
                red: Double(rgb.redComponent),
                green: Double(rgb.greenComponent),
                blue: Double(rgb.blueComponent)
            )
        )
    }
}
