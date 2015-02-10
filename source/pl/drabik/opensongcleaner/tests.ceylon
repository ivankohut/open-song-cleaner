import ceylon.test {
	test,
	assertEquals
}

test 
void shouldRemoveAccentsFromString() {
	value input="ľščťžýáíéúäôň";

	//exercise
	value result=removeAccents(input);
	
	//verify
	assertEquals(result,"lsctzyaieuaon");
}

test
void hymnNumberFormattedToLengthThreeByAddingLeftPaddingByZeros() {
	value input = 37;
	
	//exercise
	value result=formatHymnNumber(input);
	
	//verify
	assertEquals(result,"037");
}

test
void songFilenameConsistsOfFormattedHymnNumberAndSongNameWithoutAccents() {
	value hymnNumber = 2;
	value songName = "Vďaka, česť, Otče náš";
	
	//exercise
	value result=createSongFilename(songName,hymnNumber);
	
	//verify
	assertEquals(result,"002 - Vdaka, cest, Otce nas");
}

test
void twoVerseTextWithChorusContainsTwoVerseCodeAndChorus() {
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
void twoVerseTextWithoutChorusContainsTwoVerseCodeAndNoChorus() {
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

class ConstantPartCodes({String*} versesCodes, Boolean _containsChorus) extends PartCodes("") {
	
	actual shared {String*} extractVersesCodes() {
		return versesCodes;
	}

	actual shared Boolean containsChorus() {
		return _containsChorus;
	}
}

test
void presentationConsistOfSpaceDelimitedVersesCodesWhenNoChorus() {
	
	value partCodes = ConstantPartCodes({"V1","V2","V3"},false);
	value sut = Presentation(partCodes);
	
	//exercise
	value result = sut.computePresentation();
	
	//verify
	assertEquals(result,"V1 V2 V3");
}

test
void presentationConsistOfSpaceDelimitedVersesCodesInterleavedWithCWhenChorus() {
	
	value partCodes = ConstantPartCodes({"V1","V2","V3"},true);
	value sut = Presentation(partCodes);
	
	//exercise
	value result = sut.computePresentation();
	
	//verify
	assertEquals(result,"V1 C V2 C V3 C");
}

