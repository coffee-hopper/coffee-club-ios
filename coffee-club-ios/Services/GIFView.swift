import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.contentMode = .scaleAspectFit
        webView.clipsToBounds = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif") else {
            print("❌ GIF file not found: \(name).gif")
            return
        }

        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return }
        let base64 = data.base64EncodedString()

        let html = """
            <html>
            <head>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100%;
                }
                img {
                    max-width: 100%;
                    max-height: 100%;
                    object-fit: contain;
                }
            </style>
            </head>
            <body>
                <img src="data:image/gif;base64,\(base64)" />
            </body>
            </html>
            """

        uiView.loadHTMLString(html, baseURL: nil)
    }
}
