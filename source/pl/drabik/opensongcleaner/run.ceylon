import javax.xml.bind {
	JAXBContext
}


"The runnable method of the module."
shared void run() {
	value options = OpenSongCleanerOptions();
	FileCleanableOpenSongSongs(
		SongFiles(
			DirectoryOfFiles(options)
		),
		OpenSongFileBasedCleanableSongFactory(
			JAXBContext.newInstance("pl.drabik.opensongcleaner.opensong"),
			CliLogger(),
			options
		)
	).clean();
}

shared interface CleaningOptions {
	shared formal Boolean presentation;
	shared formal Boolean fileName;
}

class OpenSongFileBasedCleanableSongFactory(JAXBContext jaxbContext, Logger logger, CleaningOptions settings) satisfies Mapping<MyFile, {Cleanable*}> {
	shared actual {Cleanable*} map(MyFile file) {

		value openSongSong = SingleCache(XmlFileOpenSongSongProvider(jaxbContext, file));
		value songFile = SongFile(openSongSong);
		value listener = LoggingPresentationListener(file, logger);

		return expand([
			if (settings.presentation) then {
				PresentationCorrectingSong(
					songFile,
					Presentation(PartCodesSong(ExtractedPartCodes(songFile))),
					PresentableSongFile(UTF8TextFile(file)),
					listener
				)
			} else {},

			if (settings.fileName) then {
				FileNameCorrecting{
					file;
					newName = ChainedIterables(
						LeftPadded(OpenSongSongHymnNumber(openSongSong), 3, '0'),
						" - ",
						AccentsLess(OpenSongSongTitle(openSongSong))
					);
					listener;
				}
			} else {}
		]);
	}
}

class OpenSongCleanerOptions() satisfies CleaningOptions & MyFile {

	Nothing noDirectorySpecified() {
		throw Exception("No directory specified.");
	}

	suppressWarnings("expressionTypeNothing")
	shared actual String path => process.namedArgumentValue("d") else noDirectorySpecified();

	shared actual Boolean fileName => process.namedArgumentPresent("r");
	shared actual Boolean presentation => process.namedArgumentPresent("p");
}
