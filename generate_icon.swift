import AppKit

func renderIcon(size: CGFloat) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    
    let ctx = NSGraphicsContext.current!.cgContext
    let scale = size / 1024.0
    
    // Squircle background path (Apple Big Sur+ standard style: inset ~10% for icon shadow margin)
    let margin = 100.0 * scale
    let iconRect = NSRect(x: margin, y: margin, width: size - 2 * margin, height: size - 2 * margin)
    let cornerRadius = 185.0 * scale
    let bgPath = NSBezierPath(roundedRect: iconRect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // Shadow under the squircle
    ctx.saveGState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.shadowOffset = NSSize(width: 0, height: -20.0 * scale)
    shadow.shadowBlurRadius = 35.0 * scale
    shadow.set()
    NSColor.black.setFill()
    bgPath.fill()
    ctx.restoreGState()
    
    // Background gradient (Rich Deep Blue -> Indigo)
    ctx.saveGState()
    bgPath.addClip()
    
    let colorTop = NSColor(red: 0.12, green: 0.28, blue: 0.65, alpha: 1.0)
    let colorBottom = NSColor(red: 0.05, green: 0.10, blue: 0.28, alpha: 1.0)
    let bgGradient = NSGradient(starting: colorBottom, ending: colorTop)!
    bgGradient.draw(in: iconRect, angle: 90)
    
    // Subtle inner glow / grid overlay
    ctx.setStrokeColor(NSColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.15).cgColor)
    ctx.setLineWidth(2.0 * scale)
    let gridStep = 80.0 * scale
    var x = iconRect.minX
    while x <= iconRect.maxX {
        ctx.move(to: CGPoint(x: x, y: iconRect.minY))
        ctx.addLine(to: CGPoint(x: x, y: iconRect.maxY))
        x += gridStep
    }
    var y = iconRect.minY
    while y <= iconRect.maxY {
        ctx.move(to: CGPoint(x: iconRect.minX, y: y))
        ctx.addLine(to: CGPoint(x: iconRect.maxX, y: y))
        y += gridStep
    }
    ctx.strokePath()
    
    // Center network tree / subnet diagram
    // Center node (Router / Switch / Gateway)
    let centerX = size / 2.0
    let topNodeY = size * 0.68
    let midNodeY = size * 0.48
    let botNodeY = size * 0.28
    
    // Subnet branches (nodes)
    let leftSubnetX = centerX - 190.0 * scale
    let rightSubnetX = centerX + 190.0 * scale
    
    // Connection lines
    ctx.setLineWidth(14.0 * scale)
    ctx.setLineCap(.round)
    ctx.setStrokeColor(NSColor(red: 0.35, green: 0.75, blue: 1.0, alpha: 0.85).cgColor)
    
    // Trunk from Top to Mid
    ctx.move(to: CGPoint(x: centerX, y: topNodeY))
    ctx.addLine(to: CGPoint(x: centerX, y: midNodeY))
    
    // Branch to Left Subnet
    ctx.move(to: CGPoint(x: centerX, y: midNodeY))
    ctx.addLine(to: CGPoint(x: leftSubnetX, y: botNodeY))
    
    // Branch to Right Subnet
    ctx.move(to: CGPoint(x: centerX, y: midNodeY))
    ctx.addLine(to: CGPoint(x: rightSubnetX, y: botNodeY))
    ctx.strokePath()
    
    // Draw Nodes (glowing circles)
    func drawNode(center: CGPoint, radius: CGFloat, fillColor: NSColor, ringColor: NSColor) {
        let nodeRect = NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        
        // Outer glow ring
        let ringPath = NSBezierPath(ovalIn: nodeRect.insetBy(dx: -8.0 * scale, dy: -8.0 * scale))
        ringColor.withAlphaComponent(0.3).setFill()
        ringPath.fill()
        
        // Inner circle
        let circlePath = NSBezierPath(ovalIn: nodeRect)
        fillColor.setFill()
        circlePath.fill()
        
        // Stroke
        ringColor.setStroke()
        circlePath.lineWidth = 4.0 * scale
        circlePath.stroke()
    }
    
    // Draw top root node (Gateway / /16)
    drawNode(center: CGPoint(x: centerX, y: topNodeY),
             radius: 38.0 * scale,
             fillColor: NSColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0),
             ringColor: NSColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 1.0))
    
    // Draw mid branch node (Router / /24)
    drawNode(center: CGPoint(x: centerX, y: midNodeY),
             radius: 28.0 * scale,
             fillColor: NSColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0),
             ringColor: NSColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 1.0))
    
    // Draw left subnet node
    drawNode(center: CGPoint(x: leftSubnetX, y: botNodeY),
             radius: 32.0 * scale,
             fillColor: NSColor(red: 0.2, green: 0.88, blue: 0.65, alpha: 1.0),
             ringColor: NSColor(red: 0.5, green: 1.0, blue: 0.8, alpha: 1.0))
    
    // Draw right subnet node
    drawNode(center: CGPoint(x: rightSubnetX, y: botNodeY),
             radius: 32.0 * scale,
             fillColor: NSColor(red: 1.0, green: 0.65, blue: 0.2, alpha: 1.0),
             ringColor: NSColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0))
    
    // Badge at top right of icon with "/24" or CIDR slash symbol
    let badgeText = "/24" as NSString
    let font = NSFont.systemFont(ofSize: 46.0 * scale, weight: .heavy)
    let textAttrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)
    ]
    let textSize = badgeText.size(withAttributes: textAttrs)
    let badgeRect = NSRect(x: centerX + 110.0 * scale, y: topNodeY + 25.0 * scale, width: textSize.width + 30.0 * scale, height: textSize.height + 14.0 * scale)
    let badgePath = NSBezierPath(roundedRect: badgeRect, xRadius: 14.0 * scale, yRadius: 14.0 * scale)
    NSColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 0.95).setFill()
    badgePath.fill()
    badgeText.draw(at: NSPoint(x: badgeRect.minX + 15.0 * scale, y: badgeRect.minY + 7.0 * scale), withAttributes: textAttrs)
    
    // Highlight reflection line on top edge of squircle
    let highlightPath = NSBezierPath()
    highlightPath.move(to: CGPoint(x: iconRect.minX + cornerRadius, y: iconRect.maxY - 2.0 * scale))
    highlightPath.line(to: CGPoint(x: iconRect.maxX - cornerRadius, y: iconRect.maxY - 2.0 * scale))
    highlightPath.lineWidth = 3.0 * scale
    NSColor.white.withAlphaComponent(0.25).setStroke()
    highlightPath.stroke()
    
    ctx.restoreGState()
    img.unlockFocus()
    return img
}

let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

let iconsetDir = "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

for (filename, s) in sizes {
    let img = renderIcon(size: s)
    if let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let path = "\(iconsetDir)/\(filename)"
        try? png.write(to: URL(fileURLWithPath: path))
    }
}
print("Iconset created successfully!")
