import Foundation

public enum DateFormatting {
    // MARK: - Parsers (ISO8601)
    private static let isoWithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let isoBasic: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    // MARK: - Formatters (output)
    private static let absoluteFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current  // device local time
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let r = RelativeDateTimeFormatter()
        r.unitsStyle = .short
        return r
    }()

    // MARK: - Public API
    public static func parseISO(_ iso: String) -> Date? {
        if let d = isoWithFractional.date(from: iso) { return d }
        return isoBasic.date(from: iso)
    }

    /// Format an ISO-8601 string like `2025-09-16T10:02:30.512Z` into `yyyy-MM-dd HH:mm`
    public static func absolute(fromISO iso: String) -> String {
        guard let date = parseISO(iso) else { return iso }
        return absoluteFormatter.string(from: date)
    }

    /// Relative formatting like "2h ago", "in 3d".
    public static func relative(fromISO iso: String, relativeTo ref: Date = Date()) -> String {
        guard let date = parseISO(iso) else { return iso }
        return relativeFormatter.localizedString(for: date, relativeTo: ref)
    }

    /// Custom absolute format.
    public static func absolute(fromISO iso: String, format: String) -> String {
        guard let date = parseISO(iso) else { return iso }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current
        df.dateFormat = format
        return df.string(from: date)
    }
}
