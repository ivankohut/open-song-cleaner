import ceylon.test {
	test,
	assertEquals,
	assertFalse,
	assertTrue
}
import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}

class SongFilenameProcessorTest() {
	test 
	shared void shouldRemoveAccentsFromString() {
		value input="ľščťžýáíéúäôň";
		value sut = SongFilenameProcessor();
		
		//exercise
		value result=sut.removeAccents(input);
		
		//verify
		assertEquals(result,"lsctzyaieuaon");
	}
	
	test
	shared void hymnNumberFormattedToLengthThreeByAddingLeftPaddingByZeros() {
		value input = 37;
		value sut = SongFilenameProcessor();
		
		//exercise
		value result=sut.formatHymnNumber(input);
		
		//verify
		assertEquals(result,"037");
	}
	
	test
	shared void songFilenameConsistsOfFormattedHymnNumberAndSongNameWithoutAccents() {
		value hymnNumber = 2;
		value songName = "Vďaka, česť, Otče náš";
		value sut = SongFilenameProcessor();
		
		//exercise
		value result=sut.createSongFilename(songName,hymnNumber);
		
		//verify
		assertEquals(result,"002 - Vdaka, cest, Otce nas");
	}
}


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
		value log = OpenSongCleanerLog();
		value sut = OpenSongSongProcessor(presentationComputer,log);

		value song = createOpenSongSong{presentation="";};
		
		//exercise
		sut.computeAndReplacePresentation(song);
		
		//verify
		assertEquals(song.presentation,computedPresentation);
	}
	
	test 
	shared void songWithCorrectPresentationStaysTheSameAndEmptyMessageIsLogged(){
		value existingPresentation = "V1 C V2 C";
		value presentationComputer = ConstantPresentationComputer(existingPresentation);
		value log = OpenSongCleanerLog();
		value sut = OpenSongSongProcessor(presentationComputer,log);

		value song = createOpenSongSong{presentation=existingPresentation;};
		
		//exercise
		sut.computeAndReplacePresentation(song);
		
		//verify
		assertEquals(song.presentation,existingPresentation);
		assertEquals(log.lastMessage(),"");
	}
	
	test 
	shared void songWithWrongPresentationStaysTheSameAndErrorIsLogged(){
		value computedPresentation = "V1 C V2 C";
		value presentationComputer = ConstantPresentationComputer(computedPresentation);
		value log = OpenSongCleanerLog();
		value sut = OpenSongSongProcessor(presentationComputer,log);

		value existingPresentation = computedPresentation + " V3";
		value song = createOpenSongSong{presentation=existingPresentation;};
		
		//exercise
		sut.computeAndReplacePresentation(song);
		
		//verify
		assertEquals(song.presentation,existingPresentation);
		assertEquals(log.lastMessage(),"Vypočítaná prezentácia nie je v súlade s existujúcou.");
	}
}


class OpenSongCleanerTest() {
	
	test
	shared void openSongCleanerRunExecutedWithNoArgumentsReturnsErrorMessage(){
		
		value log = OpenSongCleanerLog();
		value sut = OpenSongCleaner([],log);
	
		//exercise
		sut.run();

		//verify
		assertEquals(sut.lastLogMessage(),"chyba[Nesprávny počet argumentov (0). Očakáva sa jeden argument - názov adresára.]");
	}

	test
	shared void openSongCleanerRunExecutedWithTwoArgumentsReturnsErrorMessage(){
		
		value log = OpenSongCleanerLog();
		value sut = OpenSongCleaner([],log);
		
		//exercise
		sut.run();

		//verify
		assertEquals(sut.lastLogMessage(),"chyba[Nesprávny počet argumentov (2). Očakáva sa jeden argument - názov adresára.]");
	}

	test
	shared void openSongCleanerRunExecutedWithArgumentNonExistingDirectoryReturnsErrorMessage(){
		
		value log = OpenSongCleanerLog();
		value sut = OpenSongCleaner([],log);
		
		//exercise
		sut.run();

		//verify
		assertEquals(sut.lastLogMessage(),"chyba[Adresár 'neexistujuci/adresar' neexistuje.]");
	}

	test
	shared void openSongCleanerRunExecutedWithArgumentExistingDirectoryReturnsPositiveMessage(){
		
		value log = OpenSongCleanerLog();
		value sut = OpenSongCleaner([],log);
		
		//exercise
		sut.run();

		//verify
		assertEquals(sut.lastLogMessage(),"Spracúvam adresár '/Users/peter/Downloads/piesne'.");
	}
	
	test
	shared void todo() {
		//exercise
		//TODO: test1 -- write xml, read and unmarshal
		//TODO: test2 -- ...
		//shared void peter() {
		//	value openSongCleaner = OpenSongCleaner();
		//	openSongCleaner.run(["/Users/peter/Downloads/piesne"]);
		//}

		//verify
		assertTrue(true);
	}
}


class OpenSongCleanerLogTest(){

	test
	shared void todo() {
		
		
		//exercise
		
		
		//verify
		assertTrue(true);
	}	
}


class FilenamePickerTest() {
	
	test
	shared void filenameWithExtensionTxtIsNotPicked() {
		
		value sut = FilenamePicker();
		
		//exercise
		value shouldPickFilename = sut.shouldPick("song.txt");
		
		//verify
		assertFalse(shouldPickFilename);
	}

	test
	shared void filenameWithExtensionXmlIsNotPicked() {
		
		value sut = FilenamePicker();
		
		//exercise
		value shouldPickFilename = sut.shouldPick("song.xml");
		
		//verify
		assertFalse(shouldPickFilename);
	}

	test
	shared void filenameWithSubfolderIsNotPicked() {
		
		value sut = FilenamePicker();
		
		//exercise
		value shouldPickFilename = sut.shouldPick("subfolder/song");
		
		//verify
		assertFalse(shouldPickFilename);
	}

	test
	shared void filenameWithoutSubfolderAndExtensionIsPicked() {
		
		value sut = FilenamePicker();
		
		//exercise
		value shouldPickFilename = sut.shouldPick("song");
		
		//verify
		assertTrue(shouldPickFilename);
	}
}

