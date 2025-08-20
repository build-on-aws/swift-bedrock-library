//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Bedrock Library open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Bedrock Library project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Bedrock Library project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftUI
import WebKit

struct MarkdownLatexView: UIViewRepresentable {
    let markdownContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        loadMarkdownContent(webView: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        loadMarkdownContent(webView: uiView)
    }

    private func loadMarkdownContent(webView: WKWebView) {
        let htmlContent = convertMarkdownToHTML(markdownContent)
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

// Function to convert markdown to HTML with LaTeX support
func convertMarkdownToHTML(_ markdown: String) -> String {
    // Create the HTML wrapper with MathJax support
    let htmlTemplate = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Markdown with LaTeX</title>
            
            <!-- MathJax configuration -->
            <script type="text/x-mathjax-config">
                MathJax.Hub.Config({
                    tex2jax: {
                        inlineMath: [['\\\\(', '\\\\)']],
                        displayMath: [['\\\\[', '\\\\]']],
                        processEscapes: true
                    }
                });
            </script>
            
            <!-- Load MathJax - use version 2 which has better compatibility -->
            <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
            
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    line-height: 1.6;
                    padding: 20px;
                    max-width: 800px;
                    margin: 0 auto;
                }
                h3 { font-size: 1.5em; margin-top: 1.5em; }
                h4 { font-size: 1.25em; margin-top: 1.2em; }
                ul { padding-left: 20px; }
                li { margin-bottom: 0.5em; }
                code {
                    background-color: #f5f5f5;
                    padding: 2px 4px;
                    border-radius: 3px;
                    font-family: monospace;
                }
                pre {
                    background-color: #f5f5f5;
                    padding: 10px;
                    border-radius: 5px;
                    overflow-x: auto;
                }
            </style>
        </head>
        <body>
            CONTENT_PLACEHOLDER
        </body>
        </html>
        """

    // Split the markdown into lines
    let lines = markdown.components(separatedBy: .newlines)
    var htmlLines: [String] = []
    var inList = false

    for line in lines {
        // Skip empty lines
        guard !line.trimmingCharacters(in: .whitespaces).isEmpty else {
            if inList {
                htmlLines.append("</ul>")
                inList = false
            }
            continue
        }

        // Handle headers
        if line.hasPrefix("### ") {
            let content = line.dropFirst(4)
            htmlLines.append("<h3>\(content)</h3>")
        } else if line.hasPrefix("#### ") {
            let content = line.dropFirst(5)
            htmlLines.append("<h4>\(content)</h4>")
        }
        // Handle bullet points
        else if line.hasPrefix("- ") {
            if !inList {
                htmlLines.append("<ul>")
                inList = true
            }
            let content = line.dropFirst(2)
            htmlLines.append("<li>\(content)</li>")
        }
        // Handle paragraphs
        else {
            if inList {
                htmlLines.append("</ul>")
                inList = false
            }
            htmlLines.append("<p>\(line)</p>")
        }
    }

    // Close any open list
    if inList {
        htmlLines.append("</ul>")
    }

    // Join all lines and clean up
    var htmlContent = htmlLines.joined(separator: "\n")

    // Handle bold text
    let boldPattern = #"\*\*([^*]+)\*\*"#
    if let regex = try? Regex(boldPattern) {
        htmlContent = htmlContent.replacing(
            regex,
            with: { (match: Regex<AnyRegexOutput>.Match) in
                let text = match.output[1].value
                return "<b>\(text ?? "")</b>"
            }
        )
    }

    // Handle code blocks
    let codeBlockPattern = #"```([\s\S]*?)```"#
    if let regex = try? Regex(codeBlockPattern) {
        htmlContent = htmlContent.replacing(
            regex,
            with: { (match: Regex<AnyRegexOutput>.Match) in
                let code = match.output[1].value
                return "<pre><code>\(code ?? "")</code></pre>"
            }
        )
    }

    // Handle inline code
    let inlineCodePattern = #"`([^`]+)`"#
    if let regex = try? Regex(inlineCodePattern) {
        htmlContent = htmlContent.replacing(
            regex,
            with: { (match: Regex<AnyRegexOutput>.Match) in
                let code = match.output[1].value
                return "<code>\(code ?? "")</code>"
            }
        )
    }

    // Insert the converted content into the HTML template
    let finalHTML = htmlTemplate.replacingOccurrences(of: "CONTENT_PLACEHOLDER", with: htmlContent)

    return finalHTML
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownLatexView(markdownContent: content)
    }
}
