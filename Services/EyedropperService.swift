import AppKit

// LEARN: enum 没有实例也可以当「命名空间」放静态方法（这里不需要创建 EyedropperService()）
enum EyedropperService {
    // LEARN: @escaping 表示闭包会在函数返回之后才被调用（异步回调，类似 JS 的 callback）
    static func pick(completion: @escaping (SavedColor?) -> Void) {
        // LEARN: NSColorSampler 是 macOS 系统自带的屏幕吸管工具
        let sampler = NSColorSampler()
        sampler.show { nsColor in
            guard let rgb = nsColor?.usingColorSpace(.sRGB) else {
                completion(nil)
                return
            }

            let saved = SavedColor(
                red: Double(rgb.redComponent),
                green: Double(rgb.greenComponent),
                blue: Double(rgb.blueComponent)
            )
            completion(saved)
        }
    }
}
