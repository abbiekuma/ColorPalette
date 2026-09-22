import SwiftUI

struct ContentView: View {
    // LEARN: @Environment 从上层注入的 PaletteStore 读取共享状态
    @Environment(PaletteStore.self) private var store

    // LEARN: LazyVGrid 是自适应网格布局，GridItem(.flexible()) 表示列均分宽度
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("Color Palette")
                .font(.title2.bold())
                .padding(.top, 24)
                .padding(.bottom, 16)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // LEARN: ForEach 遍历 slots，每个 slot 渲染一个 SlotView
                    ForEach(store.slots) { slot in
                        SlotView(slotID: slot.id)
                    }

                    // 加号格始终在末尾，不属于 slots 数据
                    AddSlotButton {
                        store.addSlot()
                    }
                }
                .padding(24)
            }
        }
        .frame(minWidth: 420, minHeight: 360)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .environment(PaletteStore())
}
