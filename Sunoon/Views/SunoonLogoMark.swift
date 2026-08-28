//
//  SunoonLogoMark.swift
//  رسم شعار سنون (نخلة مبسطة) بشكل متجهي — نفس مسار أيقونة التطبيق
//  بالضبط، مُعاد استخدامه هنا كعنصر واجهة (شاشة الإعدادات، بطاقة المشاركة).
//

import SwiftUI

struct SunoonLogoMark: View {
    var size: CGFloat = 40
    var trunkColor: Color = Color(hex: 0xC9A25E)
    var frondColor: Color = .primary

    var body: some View {
        Canvas { context, canvasSize in
            let s = canvasSize.width / 100

            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: x * s, y: y * s)
            }

            var trunk = Path()
            trunk.move(to: point(50, 52))
            trunk.addLine(to: point(50, 86))
            context.stroke(trunk, with: .color(trunkColor), style: StrokeStyle(lineWidth: 5 * s, lineCap: .round))

            // نفس إحداثيات السعف الخمس المستخدمة في أيقونة التطبيق بالضبط
            let fronds: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (30, 40, 18, 48),
                (70, 40, 82, 48),
                (35, 34, 30, 20),
                (65, 34, 70, 20),
                (50, 30, 50, 16),
            ]
            for f in fronds {
                var frond = Path()
                frond.move(to: point(50, 52))
                frond.addQuadCurve(to: point(f.2, f.3), control: point(f.0, f.1))
                context.stroke(frond, with: .color(frondColor), style: StrokeStyle(lineWidth: 5 * s, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}
