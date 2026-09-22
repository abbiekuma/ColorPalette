import AppKit
import SwiftUI

// LEARN: struct 是值类型，适合表示「一条数据记录」（类似 TS 的 interface + 普通对象）
// LEARN: Codable 让结构体可以编码成 JSON；Equatable 让两个值可以用 == 比较
struct SavedColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double

    // LEARN: 计算属性 — 没有存储字段，每次访问时根据 rgb 算出 hex
    var hex: String {
        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    // LEARN: 从 SwiftUI Color 转成可存储的 rgb 值（需要经过 AppKit 的 NSColor）
    init(color: Color) {
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
        self.red = Double(nsColor.redComponent)
        self.green = Double(nsColor.greenComponent)
        self.blue = Double(nsColor.blueComponent)
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }
}

// LEARN: Identifiable 要求有 id 字段，ForEach 遍历数组时需要
struct PaletteSlot: Identifiable, Codable, Equatable {
    let id: UUID
    // LEARN: Optional（?）表示「可能有值，也可能是空的」— 类似 TS 的 SavedColor | null
    var color: SavedColor?

    init(id: UUID = UUID(), color: SavedColor? = nil) {
        self.id = id
        self.color = color
    }
}
