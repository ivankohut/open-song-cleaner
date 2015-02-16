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

class OpenSongSongProcessorTest() {
	test
	shared void songWithEmptyPresentationGetsANewPresentation() {
		value sut = OpenSongSongProcessor();
		value song = OpenSongSong();
		song.lyrics =  "[V1] a [C] b [V2] c";
		song.presentation = "";
		
		//exercise
		sut.computeAndReplacePresentation(song);
		
		//verify
		assertEquals(song.presentation,"V1 C V2 C");
	}
	
	test 
	shared void songWithCorrectPresentationStaysTheSame(){
		value sut = OpenSongSongProcessor();
		value song = OpenSongSong();
		song.lyrics =  "[V1] a [C] b [V2] c";
		value existingPresentation = "V1 C V2 C";
		song.presentation = existingPresentation;
		
		//exercise
		sut.computeAndReplacePresentation(song);
		
		//verify
		assertEquals(song.presentation,existingPresentation);
		
	}
	
	test 
	shared void songWithWrongPresentationThrowsErrorMessageWhenComputingPresentation(){
		value sut = OpenSongSongProcessor();
		value song = OpenSongSong();
		song.lyrics =  "[V1] a [C] b [V2] c";
		song.presentation = "V1 C V2";
		
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
