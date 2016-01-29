import ceylon.file {
	parsePath,
	Directory,
	Nil,
	File,
	ExistingResource
}
import ceylon.test {
	test,
	assertEquals,
	assertTrue,
	afterTest
}

import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}
import java.util {
	ArrayList
}

shared class TestLog() satisfies MyLog {

	value logArrayList = ArrayList<String>();

	shared actual void log(String logLevel, String message) {
		logArrayList.add(message);
	}

	shared Boolean containsMessage(String message) => logArrayList.contains(message);

	shared actual String lastMessage() {
		value logSize = logArrayList.size();
		if (logSize == 0) {
			return "Log is empty";
		} else {
			return logArrayList.get(logSize-1);
		}
	}
}

class TestLogTest(){

	test
	shared void testLogLogsMessage() {

		value sut = TestLog();
		value testMessage = "Message";

		//exercise
		sut.log("INFO", testMessage);

		//verify
		assertEquals(sut.lastMessage(), testMessage);
	}

	test
	shared void testLogContainsMessageFindsLoggedMessage() {

		value sut = TestLog();
		value testMessage = "Message";

		//exercise
		sut.log("INFO", testMessage);

		//verify
		assertTrue(sut.containsMessage(testMessage));
	}
}


//class SongFileNameTest() {
//	test
//	shared void shouldRemoveAccentsFromString() {
//		//exercise
//		value sut = SongFileName("ľščťžýáíéúäôň", 0);
//		//verify
//		assertTrue(String(sut).contains("lsctzyaieuaon"));
//	}
//
//	test
//	shared void hymnNumberFormattedToLengthThreeByAddingLeftPaddingByZeros() {
//		//exercise
//		value sut = SongFileName("", 37);
//		//verify
//		assertTrue(String(sut).contains("037"));
//	}
//
//	test
//	shared void songFilenameConsistsOfFormattedHymnNumberAndSongNameWithoutAccents() {
//		//exercise
//		value result = SongFileName("Vďaka, česť, Otče náš", 2);
//		//verify
//		assertEquals(String(result), "002 - Vdaka, cest, Otce nas");
//	}
//}


class PartCodesTest() {
	test
	shared void twoVerseTextWithChorusContainsTwoVerseCodeAndChorus() {
		value songText="""
		                  [V1]
		                  Prvý riadok
		                  Druhý riadok
		                  [C]
		                  Refrén
		                  [V2]
		                  Prvý riadok
		                  Druhý riadok
		                  """;

		value sut = PartCodes(songText);

		//exercise
		value resultCodes = sut.extractVersesCodes();
		value resultChorus = sut.containsChorus();

		//verify
		assertEquals(" ".join(resultCodes),"V1 V2");
		assert(resultChorus);
	}

	test
	shared void twoVerseTextWithoutChorusContainsTwoVerseCodeAndNoChorus() {
		value songText="""
		                  [V1]
		                  Prvý riadok
		                  Druhý riadok
		                  [V2]
		                  Prvý riadok
		                  Druhý riadok
		                  """;

		value sut = PartCodes(songText);

		//exercise
		value resultCodes = sut.extractVersesCodes();
		value resultChorus = sut.containsChorus();

		//verify

		assertEquals(" ".join(resultCodes),"V1 V2");
		assert(!resultChorus);
	}
}


class ConstantPartCodes({String*} versesCodes, Boolean doesContainChorus) extends PartCodes("") {

	actual shared {String*} extractVersesCodes() {
		return versesCodes;
	}

	actual shared Boolean containsChorus() {
		return doesContainChorus;
	}
}

class PresentationTest() {
	test
	shared void presentationConsistOfSpaceDelimitedVersesCodesWhenNoChorus() {

		value partCodes = ConstantPartCodes({"V1","V2","V3"},false);
		value sut = Presentation(partCodes);

		//exercise
		value result = sut.string;

		//verify
		assertEquals(result,"V1 V2 V3");
	}

	test
	shared void presentationConsistOfSpaceDelimitedVersesCodesInterleavedWithCWhenChorus() {

		value partCodes = ConstantPartCodes({"V1","V2","V3"},true);
		value sut = Presentation(partCodes);

		//exercise
		value result = sut.string;

		//verify
		assertEquals(result,"V1 C V2 C V3 C");
	}
}


class OpenSongPresentationComputerTest() {

	test
	shared void computesPresentationFromLyrics(){
		value sut = OpenSongPresentationComputer();

		value lyrics="""
		                  [V1]
		                  Prvý riadok
		                  Druhý riadok
		                  [C]
		                  Refrén
		                  [V2]
		                  Prvý riadok
		                  Druhý riadok
		                """;

		//exercise
		value computedPresentation = sut.compute(lyrics);

		//verify
		assertEquals(computedPresentation,"V1 C V2 C");
	}
}


shared class ConstantPresentationComputer(String presentation) satisfies PresentationComputer {
	shared actual String compute(String lyrics) {
		return presentation;
	}
}

shared OpenSongSong createOpenSongSong(String presentation) {
	value song = OpenSongSong();
	song.lyrics = "";
	song.presentation = presentation;
	return song;
}

class OpenSongSongProcessorTest() {

	test
	shared void songWithEmptyPresentationGetsComputedPresentationAndSuccessMessageIsLogged() {
		value computedPresentation = "V1 C V2 C";
		value presentationComputer = ConstantPresentationComputer(computedPresentation);
		value log = TestLog();
		value sut = OpenSongSongProcessor(presentationComputer,log);

		value song = createOpenSongSong{presentation="";};

		//exercise
		sut.computeAndReplacePresentation(song);

		//verify
		assertEquals(song.presentation,computedPresentation);
	}

	test
	shared void songWithCorrectPresentationStaysTheSame(){
		value existingPresentation = "V1 C V2 C";
		value presentationComputer = ConstantPresentationComputer(existingPresentation);
		value log = TestLog();
		value sut = OpenSongSongProcessor(presentationComputer,log);

		value song = createOpenSongSong{presentation=existingPresentation;};

		//exercise
		sut.computeAndReplacePresentation(song);

		//verify
		assertEquals(song.presentation,existingPresentation);
	}

	test
	shared void songWithWrongPresentationStaysTheSameAndErrorIsLogged(){
		value computedPresentation = "V1 C V2 C";
		value presentationComputer = ConstantPresentationComputer(computedPresentation);
		value log = TestLog();
		value sut = OpenSongSongProcessor(presentationComputer,log);

		value existingPresentation = computedPresentation + " V3";
		value song = createOpenSongSong{presentation=existingPresentation;};

		//exercise
		sut.computeAndReplacePresentation(song);

		//verify
		assertEquals(song.presentation,existingPresentation);
		assertTrue(log.containsMessage("Vypočítaná prezentácia nie je v súlade s existujúcou."));
	}
}


class OpenSongCleanerTest() {

//	test
//	shared void openSongCleanerRunExecutedWithNoArgumentsReturnsErrorMessage(){
//
//		try {
//			value log = TestLog();
//			value sut = OpenSongCleaner([],log);
//
//			//exercise
//			sut.run();
//		} catch (Exception e) {
//			//verify
//			assertEquals(e.message,"Nesprávny počet argumentov (0). Očakáva sa jeden argument - názov adresára.");
//		}
//	}
//
//	test
//	shared void openSongCleanerRunExecutedWithTwoArgumentsReturnsErrorMessage(){
//
//		try {
//			value log = TestLog();
//			value sut = OpenSongCleaner(["one","two"],log);
//
//			//exercise
//			sut.run();
//		} catch (Exception e) {
//			//verify
//			assertEquals(e.message,"Nesprávny počet argumentov (2). Očakáva sa jeden argument - názov adresára.");
//		}
//	}
//
//	test
//	shared void openSongCleanerRunExecutedWithArgumentNonExistingDirectoryReturnsErrorMessage(){
//
//		try {
//			value log = TestLog();
//			value sut = OpenSongCleaner(["neexistujuci/adresar"],log);
//
//			//exercise
//			sut.run();
//		} catch (Exception e) {
//			//verify
//			assertEquals(e.message, "Adresár 'neexistujuci/adresar' neexistuje.");
//		}
//
//	}
//
//	test
//	shared void openSongCleanerRunExecutedWithArgumentExistingDirectoryReturnsPositiveMessage(){
//
//		value log = TestLog();
//		value sut = OpenSongCleaner(["/Users/peter/Downloads/piesne"],log);
//
//		//exercise
//		sut.run();
//
//		//verify
//		value sutLog = sut.log;
//		assert(is TestLog sutLog);
//		assertTrue(sutLog.containsMessage("Spracúvam adresár '/Users/peter/Downloads/piesne'."));
//	}
}


class PrinterLogTest(){

	test
	shared void printerLogLogsMessage() {

		value sut = PrinterLog();
		value testMessage = "Message";

		//exercise
		sut.log("INFO", testMessage);

		//verify
		assertEquals(sut.lastMessage(), testMessage);
	}
}

shared class TestDir(String dirName) {

	value resource = parsePath(dirName).resource;
	"Test directory already exists!"
	assert (is Nil resource);
	shared Directory directory = resource.createDirectory();

	shared File createFile(String relativePathWithFileName) {
		value file = directory.path.childPath(relativePathWithFileName).resource;
		switch (file)
		case (is Nil) {
			return file.createFile(true);
		}
		else {
			throw Exception();
		}
	}

	shared void deleteRecursively() {
		oscFileUtils.deleteRecursively(directory);
	}
}


shared object oscFileUtils {

	shared void deleteRecursively(ExistingResource res) {
		switch (res)
		case (is File) {
			res.delete();
		}
		case (is Directory) {
			for (child in res.children()) {
				deleteRecursively(child);
			}
			res.delete();
		}
		else {
			throw Exception();
		}
	}

	shared Boolean containsFile({File*} files, File expectedFile) =>
		files.any((file) => file.path.absolutePath == expectedFile.path.absolutePath);
}

shared class SongFilesTest() {

//	value testDir = TestDir("FileNamePickerTestDir");
//
//	afterTest
//	shared void deleteTestDirRecursively() {
//		testDir.deleteRecursively();
//	}
//
//	void assertFilesContain({File*} files, File expectedFile) {
//		assertTrue(oscFileUtils.containsFile(files, expectedFile));
//	}

	class SimpleNamed(shared actual String name) satisfies Named {}

	test
	shared void filenameWithoutExtensionIsPicked() {

		value picked = SimpleNamed("song");
		value notPicked = SimpleNamed("song.txt");

		//exercise
		value result = SongFiles({picked, notPicked});

		//verify
		assertEquals(result, {picked});
	}
//
//	test
//	shared void filenameWithoutExtensionInSubdirectoryIsNotPicked() {
//
//		testDir.createFile("subdir/songInSubdir");
//
//		//exercise
//		value result = FilenamePicker(testDir.directory);
//
//		//verify
//		assertTrue(result.empty);
//	}

}

shared class FileSystemProcessorTest() {

	test
	shared void todo() {
		//exercise
		//TODO: test1 -- write xml, read xml
		//currently errors in Ceylon Test (JAXBException)

		//verify
		assertTrue(false);
	}
}
