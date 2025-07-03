import SwiftUI

struct TaperedCardShape: Shape {
    var cornerRadius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        let topWidth = rect.width
        let bottomWidth: CGFloat = rect.width * 0.8
        let height = rect.height
        let taper = (topWidth - bottomWidth) / 4

        let topLeft = CGPoint(x: 0, y: 0)
        let topRight = CGPoint(x: topWidth, y: 0)
        let bottomRight = CGPoint(x: topWidth - taper, y: height)
        let bottomLeft = CGPoint(x: taper, y: height)

        var path = Path()

        // Start at top-left corner arc start
        path.move(to: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y))

        // Top edge to top-right arc
        path.addLine(to: CGPoint(x: topRight.x - cornerRadius, y: topRight.y))
        path.addArc(center: CGPoint(x: topRight.x - cornerRadius, y: topRight.y + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)

        // Right edge to bottom-right arc
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadius))
        path.addArc(center: CGPoint(x: bottomRight.x - cornerRadius, y: bottomRight.y - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        // Bottom edge to bottom-left arc
        path.addLine(to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y))
        path.addArc(center: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        // Left edge to top-left arc
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadius))
        path.addArc(center: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)

        path.closeSubpath()
        return path
    }
}
