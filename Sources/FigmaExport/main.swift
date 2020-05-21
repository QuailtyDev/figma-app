import ArgumentParser

struct FigmaExportCommand: ParsableCommand {
    
    static let fileConverter = FileConverter()
    static let fileWritter = FileWritter()
    static let fileDownloader = FileDownloader()
    
    static var configuration = CommandConfiguration(
        commandName: "figma-export",
        abstract: "Exports resources from Figma",
        discussion: "Exports resources (colors, icons, images) from Figma to Xcode / Android Studio project",
        subcommands: [
            ExportColors.self,
            ExportIcons.self,
            ExportImages.self
        ],
        defaultSubcommand: ExportColors.self
    )
    
}

FigmaExportCommand.main()
