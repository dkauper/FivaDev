//
//  Bundle+Icon.swift
//  FivaDev
//
//  Cross-platform extension to load the app icon
//  Created by Doron Kauper on 9/17/25.
//  Updated: September 22, 2025, 3:20 PM
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

import SwiftUI

extension Bundle {
    /// Returns a SwiftUI Image of the app icon that works on all platforms
    var iconImage: Image? {
        #if os(iOS) || os(tvOS)
        // iOS/tvOS implementation
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last,
           let uiImage = UIImage(named: lastIcon) {
            return Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        // macOS implementation
        if let iconFileName = infoDictionary?["CFBundleIconFile"] as? String,
           let nsImage = NSImage(named: iconFileName) {
            return Image(nsImage: nsImage)
        }
        
        // Fallback to the app's icon on macOS
        if let appIcon = NSApplication.shared.applicationIconImage {
            return Image(nsImage: appIcon)
        }
        #endif
        
        return nil
    }
}

// MARK: - Platform-Specific Native Image Support (for backward compatibility)
extension Bundle {
    #if os(iOS) || os(tvOS)
    /// Returns the native UIImage for iOS/tvOS (for backward compatibility)
    var nativeIcon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    #elseif os(macOS)
    /// Returns the native NSImage for macOS (for backward compatibility)
    var nativeIcon: NSImage? {
        if let iconFileName = infoDictionary?["CFBundleIconFile"] as? String {
            return NSImage(named: iconFileName)
        }
        return NSApplication.shared.applicationIconImage
    }
    #endif
}
