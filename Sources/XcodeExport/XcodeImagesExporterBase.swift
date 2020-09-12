import FigmaExportCore
import Foundation

public class XcodeImagesExporterBase {
    
    let output: XcodeImagesOutput
    
    public init(output: XcodeImagesOutput) {
        self.output = output
    }
    
    func generateExtensions(names: [String], append: Bool) throws -> [FileContents] {
        var files = [FileContents]()
        
        // SwiftUI extension Image {
        if let url = output.swiftUIImageExtensionURL {
            let contents: String
            
            if append {
                let strings = names.map { "    static var \($0): Image { return Image(#function) }" }
                let string = strings.joined(separator: "\n") + "\n}"
                contents = try appendContent(string: string, to: url)
            }
            else {
                contents = makeSwiftUIExtension(assetNames: names)
            }
            
            files.append(makeFileContents(string: contents, url: url))
        }
        
        // UIKit extension UIImage {
        if let url = output.uiKitImageExtensionURL {
            let contents: String
            
            if append {
                let strings = names.map { "    static var \($0): UIImage { return UIImage(named: #function)! }" }
                let string = strings.joined(separator: "\n") + "\n}"
                contents = try appendContent(string: string, to: url)
            } else {
                contents = makeUIKitExtension(assetNames: names)
            }
            
            files.append(makeFileContents(string: contents, url: url))
        }
        
        return files
    }
    
    private func appendContent(string: String, to fileURL: URL) throws -> String {
        var existingContents = try String(contentsOf: URL(fileURLWithPath: fileURL.path), encoding: .utf8)

        if let index = existingContents.lastIndex(of: "}") {
           let nextIndex = existingContents.index(after: index)
           existingContents.replaceSubrange(index...nextIndex, with: string)
        }
        return existingContents
    }
    
    private func makeFileContents(string: String, url: URL) -> FileContents {
        let data = string.data(using: .utf8)!
        let fileURL = URL(string: url.lastPathComponent)!
        let directoryURL = url.deletingLastPathComponent()
        
        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: data
        )
    }
    
    private func makeSwiftUIExtension(assetNames: [String]) -> String {
        let images = assetNames.map { name -> String in
            return "    static var \(name): Image { return Image(#function) }"
        }
        
        return """
        \(header)

        import SwiftUI

        extension Image {
        \(images.joined(separator: "\n"))
        }

        """
    }
    
    private func makeUIKitExtension(assetNames: [String]) -> String {
        let images = assetNames.map { name -> String in
            return "    static var \(name): UIImage { return UIImage(named: #function)! }"
        }
        
        return """
        \(header)

        import UIKit

        extension UIImage {
        \(images.joined(separator: "\n"))
        }

        """
    }
}
