
import javax.xml.bind {
	JAXBContext,
	Marshaller,
	Unmarshaller,
	Validator
}


"The runnable method of the module."
shared void run() {
	value options = OpenSongCleanerOptions();
	value jaxbContext = LazyJaxbContext("pl.drabik.opensongcleaner.opensong");
	value logger = CliLogger();
	HymnBook(
		Songs(
			OpenSongFiles(
				DirectoryOfFiles(options)
			),
			(MyFile file) =>
				let (
					openSongSong = SingleCache(XmlFileOpenSongSongProvider(jaxbContext, file)),
				 	songFile = SongFile(openSongSong),
				 	listener = LoggingPresentationListener(file, logger)
			 	)
				CleanableSong(
					options,
					PresentationCorrectingSong(
						songFile,
						Presentation(PartCodesSong(ExtractedPartCodes(songFile))),
						PresentableSongFile(UTF8TextFile(file)),
						listener
					),
					FileNameCorrecting {
						file;
						newName = ChainedIterables(
							LeftPadded(OpenSongSongHymnNumber(openSongSong), 3, '0'),
							" - ",
							AccentsLess(OpenSongSongTitle(openSongSong))
						);
						listener;
					}
				)
		)
	).clean();
}

class LazyJaxbContext({Character*} packageName) extends JAXBContext() {
	
	late value context = JAXBContext.newInstance(String(packageName));
	
	shared actual Marshaller createMarshaller() => context.createMarshaller();
	
	shared actual Unmarshaller createUnmarshaller() => context.createUnmarshaller();
	
	suppressWarnings("deprecation")
	shared actual Validator createValidator() => context.createValidator();
}

class Songs({MyFile*} files, Cleanable(MyFile) fileToCleanable) satisfies Iterable<Cleanable> {
	shared actual Iterator<Cleanable> iterator() => files.map((songFile) => fileToCleanable(songFile)).iterator();
}

shared interface CleaningOptions {
	shared formal Boolean presentation;
	shared formal Boolean fileName;
}

class CleanableSong(CleaningOptions options, Cleanable presentation, Cleanable fileName) satisfies Cleanable {
	shared actual void clean() {
		if (options.presentation) {
			presentation.clean();
		}
		if (options.fileName) {
			fileName.clean();
		}
	}
}

class OpenSongCleanerOptions() satisfies CleaningOptions & MyFile {
	
	Nothing noDirectorySpecified() {
		throw Exception("No directory specified.");
	}
	
	suppressWarnings ("expressionTypeNothing")
	shared actual String path => process.namedArgumentValue("d") else noDirectorySpecified();
	
	shared actual Boolean fileName => process.namedArgumentPresent("r");
	shared actual Boolean presentation => process.namedArgumentPresent("p");
}
