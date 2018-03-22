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
	assertTrue
}

//shared class TestLog() satisfies Logger {
//
//	value logArrayList = ArrayList<String>();
//
//	shared actual void log(LogLevel logLevel, String message) {
//		logArrayList.add(message);
//	}
//
//	shared Boolean containsMessage(String message) => logArrayList.contains(message);
//
//	shared String lastMessage() {
//		value logSize = logArrayList.size();
//		if (logSize == 0) {
//			return "Log is empty";
//		} else {
//			return logArrayList.get(logSize-1);
//		}
//	}
//}
//
//class TestLogTest() {
//
//	test
//	shared void testLogLogsMessage() {
//
//		value sut = TestLog();
//		value testMessage = "Message";
//
//		//exercise
//		sut.log(info, testMessage);
//
//		//verify
//		assertEquals(sut.lastMessage(), testMessage);
//	}
//
//	test
//	shared void testLogContainsMessageFindsLoggedMessage() {
//
//		value sut = TestLog();
//		value testMessage = "Message";
//
//		//exercise
//		sut.log(info, testMessage);
//
//		//verify
//		assertTrue(sut.containsMessage(testMessage));
//	}
//}


//shared OpenSongSong createOpenSongSong(String presentation) {
//	value song = OpenSongSong();
//	song.lyrics = "";
//	song.presentation = presentation;
//	return song;
//}
//
//class OpenSongSongProcessorTest() {
//
//	test
//	shared void songWithEmptyPresentationGetsComputedPresentationAndSuccessMessageIsLogged() {
//		value computedPresentation = "V1 C V2 C";
//		value presentationComputer = ConstantPresentationComputer(computedPresentation);
//		value log = TestLog();
//		value sut = OpenSongSongProcessor(presentationComputer,log);
//
//		value song = createOpenSongSong{presentation="";};
//
//		//exercise
//		sut.computeAndReplacePresentation(song);
//
//		//verify
//		assertEquals(song.presentation,computedPresentation);
//	}
//
//	test
//	shared void songWithCorrectPresentationStaysTheSame(){
//		value existingPresentation = "V1 C V2 C";
//		value presentationComputer = ConstantPresentationComputer(existingPresentation);
//		value log = TestLog();
//		value sut = OpenSongSongProcessor(presentationComputer,log);
//
//		value song = createOpenSongSong{presentation=existingPresentation;};
//
//		//exercise
//		sut.computeAndReplacePresentation(song);
//
//		//verify
//		assertEquals(song.presentation,existingPresentation);
//	}
//
//	test
//	shared void songWithWrongPresentationStaysTheSameAndErrorIsLogged(){
//		value computedPresentation = "V1 C V2 C";
//		value presentationComputer = ConstantPresentationComputer(computedPresentation);
//		value log = TestLog();
//		value sut = OpenSongSongProcessor(presentationComputer,log);
//
//		value existingPresentation = computedPresentation + " V3";
//		value song = createOpenSongSong{presentation=existingPresentation;};
//
//		//exercise
//		sut.computeAndReplacePresentation(song);
//
//		//verify
//		assertEquals(song.presentation,existingPresentation);
//		assertTrue(log.containsMessage("Vypočítaná prezentácia nie je v súlade s existujúcou."));
//	}
//}


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


//class PrinterLogTest(){
//
//	test
//	shared void printerLogLogsMessage() {
//
//		value sut = CliLogger();
//		value testMessage = "Message";
//
//		//exercise
//		sut.log("INFO", testMessage);
//
//		//verify
//		assertEquals(sut.lastMessage(), testMessage);
//	}
//}

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
		value result = ExtensionLess({picked, notPicked});

		//verify
		assertEquals(result.sequence(), [picked]);
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

//shared class FileSystemProcessorTest() {
//
//	test
//	shared void todo() {
//		//exercise
//		//TODO: test1 -- write xml, read xml
//		//currently errors in Ceylon Test (JAXBException)
//
//		//verify
//		assertTrue(false);
//	}
//}
