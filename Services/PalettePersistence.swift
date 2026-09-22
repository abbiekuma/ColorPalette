import Foundation

// LEARN: 负责把格子数据读写为 JSON 文件，和 UI 逻辑分开（类似前端的 storage service）
struct PalettePersistence {
    private let fileName = "palette.json"

    private var fileURL: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        let appDir = appSupport.appendingPathComponent("ColorPalette", isDirectory: true)
        return appDir.appendingPathComponent(fileName)
    }

    func load() -> [PaletteSlot]? {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([PaletteSlot].self, from: data)
        } catch {
            print("Failed to load palette: \(error)")
            return nil
        }
    }

    func save(_ slots: [PaletteSlot]) {
        let url = fileURL
        let directory = url.deletingLastPathComponent()

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(slots)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save palette: \(error)")
        }
    }
}
