import SwiftUI

// LEARN: @main 标记程序入口，类似其他语言的 main() 或 JS 的 index.tsx
@main
struct ColorPaletteApp: App {
    // LEARN: @State 让这个 store 在 App 生命周期内存活，并传给子视图
    @State private var store = PaletteStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // LEARN: .environment 把 store 注入视图树，子视图用 @Environment(PaletteStore.self) 读取
                .environment(store)
        }
        .defaultSize(width: 480, height: 420)
    }
}
