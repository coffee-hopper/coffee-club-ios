import Foundation

enum API {
    static let baseURL: String = {
        #if targetEnvironment(simulator)
            return "http://127.0.0.1:3000"
        #else
            return "http://172.20.10.6:3000"
        #endif
    }()
}
