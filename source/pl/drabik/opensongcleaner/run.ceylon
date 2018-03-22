
import ceylon.file {
	File
}

import java.nio.charset {
	StandardCharsets
}

import javax.xml.bind {
	JAXBContext,
	Marshaller,
	Unmarshaller,
	Validator
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
						PresentationCorrectingSong(
							songFile,
							Presentation(PartCodesSong(ExtractedPartCodes(songFile))),
							PresentableSongFile(TextFile(file, StandardCharsets.utf8)),
							listener
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
						}
					)
			)
		).clean();
	} catch (Exception e) {
		e.printStackTrace();
	}
}

class LazyJaxbContext({Character*} packageName) extends JAXBContext() {

	late value context = JAXBContext.newInstance(String(packageName));

	shared actual Marshaller createMarshaller() => context.createMarshaller();

	shared actual Unmarshaller createUnmarshaller() => context.createUnmarshaller();

	suppressWarnings("deprecation")
	shared actual Validator createValidator() => context.createValidator();
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

class OpenSongCleanerOptions() satisfies CleaningOptions & Iterable<Character> {

	Nothing noDirectorySpecified() {
		throw Exception("No directory specified. Example: '-d <directory>'");
	}

	suppressWarnings ("expressionTypeNothing")
	shared actual Iterator<Character> iterator() => (process.namedArgumentValue("d") else noDirectorySpecified()).iterator();

	shared actual Boolean fileName => process.namedArgumentPresent("r");
	shared actual Boolean presentation => process.namedArgumentPresent("p");
}
