import ceylon.file {
	File
}

import java.nio.charset {
	StandardCharsets
}

"The runnable method of the module."
shared void run() {
	value options = OpenSongCleanerOptions();
	value logger = CliLogger();
	try {
		runCleaner(options, logger);
	} catch (Exception e) {
		e.printStackTrace();
	}
}

shared void runCleaner(CleaningOptions & Iterable<Character> options, Logger logger) {
	value illegalWindowsFileNameCharacters = "[/?<>\\:*|\"]";
	value illegalLinuxFileNameCharacters = "/";
	value illegalWindowsFileNameTrailingCharacters = ". ";
	value jaxbContext = LazyJaxbContext("pl.drabik.opensongcleaner.opensong");
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
						JoinedText(" ", PartsPresentation(ExtractedPartCodes(songFile), "C")),
						XmlFirstElement(TextFile(file, StandardCharsets.utf8), "presentation"),
						listener,
						false
					),
					FileNameCorrecting {
						file = RenameableFile(file, listener);
						newName = ChainedIterables(
							LeftPadded(OpenSongSongHymnNumber(openSongSong), 3, '0'),
							" ",
							TrimmedTrailing(
								FilteredOut(
									AccentsLess(
										OpenSongSongTitle(openSongSong)
									)
									,
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
}
