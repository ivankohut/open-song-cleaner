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