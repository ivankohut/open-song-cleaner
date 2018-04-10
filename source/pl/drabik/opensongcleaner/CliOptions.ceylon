
shared interface CleaningOptions {
	shared formal Boolean presentation;
	shared formal Boolean fileName;
	shared formal Boolean lyrics;
}

class OpenSongCleanerOptions() satisfies CleaningOptions & Iterable<Character> {

	Nothing noDirectorySpecified() {
		throw Exception("No directory specified. Example: '-d <directory>'");
	}

	suppressWarnings ("expressionTypeNothing")
	shared actual Iterator<Character> iterator() => (process.namedArgumentValue("d") else noDirectorySpecified()).iterator();

	shared actual Boolean fileName => process.namedArgumentPresent("r");
	shared actual Boolean presentation => process.namedArgumentPresent("p");
	shared actual Boolean lyrics => process.namedArgumentPresent("l");

}