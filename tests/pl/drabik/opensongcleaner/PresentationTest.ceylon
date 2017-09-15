import ceylon.test {
	test,
	assertEquals
}

//import com.athaydes.specks {
//	Specification,
//	feature,
//	SpecksTestExecutor
//}
//import com.athaydes.specks.assertion {
//	expect
//}
//import com.athaydes.specks.matcher {
//	containSameAs,
//	to,
//	equalTo
//}

//testExecutor(`class SpecksTestExecutor`)
//test
//shared Specification extractedPartCodesSpec() => Specification {
//	feature {
//		description = "Two verse codes and chorus code when lyrics contain two verses and chorus.";
//
//		examples = {
//			["""[V1]
//			        Prvý riadok
//			        Druhý riadok
//			        [C]
//			        Refrén
//			        [V2]
//			        Prvý riadok
//			        Druhý riadok
//			        """]
//		};
//
//		when(String songText) => [ExtractedPartCodes(FakeSongLyrics(songText))];
//
//		({String*} result) => expect(result, to(containSameAs({"V1", "C", "V2"})))
//	}
//};

class FakeSongLyrics(shared actual String lyrics) satisfies SongLyrics {}

class ExtractedPartCodesTest() {
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
		// exercise
		value sut = ExtractedPartCodes(SimpleSongLyrics(songText));
		// verify
		assertIterable(sut.sequence()).containsExactly(["V1", "C", "V2"]);
	}

	class SimpleSongLyrics(shared actual String lyrics) satisfies SongLyrics {}
}

//testExecutor(`class SpecksTestExecutor`)
//test
//shared Specification partCodesSongSpec() => Specification {
//	feature {
//		description = "Two verse codes and chorus code when lyrics contain two verses and chorus.";
//
//		examples = {
//			[["V1", "C", "V2"], ["V1", "V2"], true],
//			[["V1", "V2"], ["V1", "V2"], false]
//		};
//
//		when({String*} partCodes, {String*} versesCodes, Boolean containsChorus) => [PartCodesSong(partCodes), versesCodes, containsChorus];
//
//		assertions = {
//			(SongWithVerses result, {String*} versesCodes, Boolean containsChorus) => expect(result.versesCodes, to(containSameAs(versesCodes))),
//			(SongWithVerses result, {String*} versesCodes, Boolean containsChorus) => expect(result.containsChorus, toBe(containsChorus))
//		};
//	}
//};


class PartCodesSongTest() {
	test shared void containsChorusIffAtLeastOnePartCodesIsC() {
		assert (PartCodesSong({"V1", "C", "V2"}).containsChorus);
		assert (!PartCodesSong({"V1", "V2"}).containsChorus);
	}

	test shared void versesCodesAreAllPartCodesExceptChorus() {
		assertIterable(PartCodesSong({"V1", "C", "V2"}).versesCodes).containsExactly({"V1", "V2"});
		assertIterable(PartCodesSong({"V1", "V2"}).versesCodes).containsExactly({"V1", "V2"});
	}
}

class PresentationTest() {
	test
	shared void presentationConsistOfSpaceDelimitedVersesCodesWhenNoChorus() {

		value partCodes = SimpleSongWithVerses({"V1","V2","V3"}, false);
		value sut = Presentation(partCodes);

		//exercise
		value result = sut.string;

		//verify
		assertEquals(result, "V1 V2 V3");
	}

	test
	shared void presentationConsistOfSpaceDelimitedVersesCodesInterleavedWithCWhenChorus() {

		value partCodes = SimpleSongWithVerses({"V1","V2","V3"}, true);
		value sut = Presentation(partCodes);

		//exercise
		value result = sut.string;

		//verify
		assertEquals(result, "V1 C V2 C V3 C");
	}

	class SimpleSongWithVerses(shared actual {String*} versesCodes, shared actual Boolean containsChorus) satisfies SongWithVerses {}
}