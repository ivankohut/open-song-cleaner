import ceylon.file {
	File
}

import java.nio.charset {
	StandardCharsets
}

"The runnable method of the module."
shared void run() {
	value illegalWindowsFileNameCharacters = "[/?<>\\:*|\"]";
	value illegalLinuxFileNameCharacters = "/";
	value illegalWindowsFileNameTrailingCharacters = ". ";
	value options = OpenSongCleanerOptions();
	value jaxbContext = LazyJaxbContext("pl.drabik.opensongcleaner.opensong");
	value logger = CliLogger();
	try {
		HymnBook(
			Mapped(
				ExtensionLess(
					Mapped(
						DirectoryOfFiles(options),
						(File file) => FileMyFile(file)
					)
				),
				(FileOnPath file) =>
					let (
						openSongSong = SingleCache(XmlFileOpenSongSongProvider(jaxbContext, file)),
					 	songFile = SongFile(openSongSong),
					 	listener = LoggingPresentationListener(file, logger)
				 	)
					CleanableSong(
						options,
						TextContentCorrection(
							OpenSongSongPresentation(openSongSong),
							Presentation(PartCodesSong(ExtractedPartCodes(songFile))),
							XmlFirstElement(TextFile(file, StandardCharsets.utf8), "presentation"),
							listener,
							false
						),
						FileNameCorrecting {
							file = RenameableFile(file, listener);
							newName = ChainedIterables(
								LeftPadded(OpenSongSongHymnNumber(openSongSong), 3, '0'),
								" - ",
								TrimmedTrailing(
									FilteredOut(
										AccentsLess(OpenSongSongTitle(openSongSong)),
										ChainedIterables(illegalWindowsFileNameCharacters, illegalLinuxFileNameCharacters)
									),
									illegalWindowsFileNameTrailingCharacters
								)
							);
						},
						TextContentCorrection(
							OpenSongSongLyrics(openSongSong),
							WhitespaceStrippedLyrics(songFile),
							XmlFirstElement(TextFile(file, StandardCharsets.utf8), "lyrics"),
							listener,
							true
						)
					)
			)
		).clean();
	} catch (Exception e) {
		e.printStackTrace();
	}
}


