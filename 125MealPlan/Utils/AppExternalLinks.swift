import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://www.termsfeed.com/live/7d58cc0f-4bb6-4d04-9975-af2b337ee6c0"
    case termsOfUse = "https://www.termsfeed.com/live/e5357de0-42b2-451b-be46-0fdc2c1c950c"

    var urlString: String {
        rawValue
    }
}
