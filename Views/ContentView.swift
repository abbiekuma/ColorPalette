import SwiftUI

enum PaletteTheme {
    static let cocoa = Color(hex: 0x936F57)
    static let cream = Color(hex: 0xF3E6D8)
    static let blush = Color(hex: 0xE2AEB2)
    static let sand = Color(hex: 0xDEC7AF)
    static let frame = Color(hex: 0xC6A88B)
    static let creamSoft = Color(hex: 0xFFF6EC)

    static let corner: CGFloat = 36
    static let stroke: CGFloat = 1.8
    static let chunk: CGFloat = 6
    static let slotHeight: CGFloat = 136
    static let dash = StrokeStyle(lineWidth: 2, lineCap: .round, dash: [9, 8])
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

struct SoftBlob<S: Shape>: View {
    var shape: S
    var fill: Color
    var showsStroke: Bool = false

    var body: some View {
        shape
            .fill(fill)
            .overlay {
                if showsStroke {
                    shape.stroke(PaletteTheme.cocoa.opacity(0.18), lineWidth: PaletteTheme.stroke)
                }
            }
            .shadow(color: PaletteTheme.cocoa.opacity(0.18), radius: 8, x: 4, y: 7)
    }
}

struct DashedRoundedFrame: View {
    var cornerRadius: CGFloat = PaletteTheme.corner

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(PaletteTheme.cocoa, style: PaletteTheme.dash)
    }
}

struct CuteWindowBackground: View {
    var body: some View {
        ZStack {
            PaletteTheme.cream
            Circle()
                .fill(PaletteTheme.blush.opacity(0.32))
                .frame(width: 280, height: 280)
                .blur(radius: 18)
                .offset(x: -180, y: -220)
            Circle()
                .fill(Color(hex: 0xF6E6A8).opacity(0.28))
                .frame(width: 180, height: 180)
                .blur(radius: 12)
                .offset(x: 190, y: 210)
        }
        .ignoresSafeArea()
    }
}

struct CuteCrossMark: View {
    var body: some View {
        ZStack {
            xArm.rotationEffect(.degrees(45))
            xArm.rotationEffect(.degrees(-45))
        }
        .rotationEffect(.degrees(20))
        .frame(width: 36, height: 36)
        .contentShape(Rectangle())
    }

    private var xArm: some View {
        Capsule(style: .continuous)
            .fill(PaletteTheme.blush)
            .frame(width: 24, height: 5.5)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(PaletteTheme.cocoa, lineWidth: 2)
            )
    }
}

struct CuteMenuButton: View {
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(PaletteTheme.sand)
                    .frame(width: 9, height: 9)
                    .overlay(
                        Circle().stroke(PaletteTheme.cocoa, lineWidth: 2.4)
                    )
            }
        }
        .frame(width: 44, height: 28)
        .contentShape(Rectangle())
    }
}

struct CuteDeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CuteCrossMark()
        }
        .buttonStyle(.plain)
        .help("Delete this slot")
    }
}

struct CutePillButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .foregroundStyle(PaletteTheme.cocoa)
                .background(Capsule(style: .continuous).fill(PaletteTheme.blush))
                .shadow(color: PaletteTheme.cocoa.opacity(0.16), radius: 4, x: 1, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct ContentView: View {
    @Environment(PaletteStore.self) private var store

    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18),
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(store.slots) { slot in
                        SlotView(slotID: slot.id)
                    }

                    AddSlotButton {
                        store.addSlot()
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .frame(minWidth: 460, minHeight: 400)
        .background(CuteWindowBackground())
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(alignment: .top) {
            HStack(spacing: 12) {
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("color palette")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(PaletteTheme.cocoa)
                    Text("tap a code to copy  ♡")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(PaletteTheme.cocoa.opacity(0.72))
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 18)
            .padding(.vertical, 8)
            .background {
                SoftBlob(
                    shape: RoundedRectangle(cornerRadius: PaletteTheme.corner, style: .continuous),
                    fill: PaletteTheme.creamSoft
                )
            }
            .padding(.trailing, 6)
            .padding(.bottom, 8)

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    ContentView()
        .environment(PaletteStore())
}
