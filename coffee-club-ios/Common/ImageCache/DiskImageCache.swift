import CryptoKit
import Foundation
import UIKit

enum DiskImageCache {
    private static var cacheDir: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ProfileImages", isDirectory: true)
    }

    static func ensureDir() {
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    private static func key(for urlString: String) -> String {
        let data = Data(urlString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    static func path(for urlString: String) -> String {
        ensureDir()
        return cacheDir.appendingPathComponent("\(key(for: urlString)).jpg").path
    }

    static func loadImagePathIfExists(for urlString: String) -> String? {
        let p = path(for: urlString)
        return FileManager.default.fileExists(atPath: p) ? p : nil
    }

    static func fetchAndCache(from urlString: String) async -> String? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard UIImage(data: data) != nil else { return nil }
            let p = path(for: urlString)
            try data.write(to: URL(fileURLWithPath: p), options: .atomic)
            return p
        } catch {
            return nil
        }
    }
}
