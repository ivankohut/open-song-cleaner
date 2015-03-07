import ceylon.test {
	test,
	assertEquals,
	fail
}
import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}

class SongFilenameTest() {
	test 
	shared void shouldRemoveAccentsFromString() {
		value input="ľščťžýáíéúäôň";
		
		//exercise
		value result=removeAccents(input);
		
		//verify
		assertEquals(result,"lsctzyaieuaon");
	}
	
	test
	shared void hymnNumberFormattedToLengthThreeByAddingLeftPaddingByZeros() {
		value input = 37;
		
		//exercise
		value result=formatHymnNumber(input);
		
		//verify
		assertEquals(result,"037");
	}
	
	test
	shared void songFilenameConsistsOfFormattedHymnNumberAndSongNameWithoutAccents() {
		value hymnNumber = 2;
		value songName = "Vďaka, česť, Otče náš";
		
		//exercise
		value result=createSongFilename(songName,hymnNumber);
		
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



class ConstantPartCodes({String*} versesCodes, Boolean _containsChorus) extends PartCodes("") {
	
	actual shared {String*} extractVersesCodes() {
		return versesCodes;
	}

	actual shared Boolean containsChorus() {
		return _containsChorus;
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
	shared void songWithEmptyPresentationGetsComputedPresentation() {
		value computedPresentation = "V1 C V2 C";
		value presentationComputer = ConstantPresentationComputer(computedPresentation);
		value sut = OpenSongSongProcessor(presentationComputer);

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
		value sut = OpenSongSongProcessor(presentationComputer);

		value song = createOpenSongSong{presentation=existingPresentation;};
		
		//exercise
		sut.computeAndReplacePresentation(song);
		
		//verify
		assertEquals(song.presentation,existingPresentation);
	}
	
	test 
	shared void songWithWrongPresentationThrowsErrorMessageWhenComputingPresentation(){
		value computedPresentation = "V1 C V2 C";
		value presentationComputer = ConstantPresentationComputer(computedPresentation);
		value sut = OpenSongSongProcessor(presentationComputer);

		value existingPresentation = computedPresentation + " V3";
		value song = createOpenSongSong{presentation=existingPresentation;};
		
		//exercise
		try {
			sut.computeAndReplacePresentation(song);
			fail();
		}
		//verify
		catch (Exception e){
			assertEquals(e.message,"Vypočítaná prezentácia nie je v súlade s existujúcou.");
		}
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