import ceylon.test {
	test
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

class ExtractedPartCodesTest() {
	" Parts codes extracted from lyrics, empty and comment lines (lines starting with ;) and accords lines (lines starting with .) are ignored."
	test
	shared void extractedParts() {
		value songText="""
		                  [Part]
		                  . F# Cdim
		                   Some text
		                  1Some text

		                  2Some text
		                   Some text
		                  1Some text
		                  2Some text
		                  ;Some text

		                  [AnotherPart]

		                   Some text
		                  1Some text
		                  . F# Cdim
		                  2Some text
		                   Some text
		                  1Some text
		                  2Some text

		                  """;
		// exercise
		value sut = ExtractedPartCodes(SimpleSongLyrics(songText));
		// verify
		assertIterable(sut.sequence()).containsExactly(["Part", "Part1", "Part2", "AnotherPart", "AnotherPart1", "AnotherPart2"]);
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

class PartsPresentationTest() {
	test
	shared void justGivenPartsWhenChorusIsNotPresent() {
		// exercise
		value sut = PartsPresentation({"V1", "V2", "V3"}, "C");
		// verify
		assertIterable(sut).containsExactly({"V1", "V2", "V3"});
	}

	test
	shared void partsInterleavedWithChorusStartingWithChorusWhenChorusIsTheFirstPart() {
		// exercise
		value sut = PartsPresentation({"C", "V1", "V2", "V3"}, "C");
		// verify
		assertIterable(sut).containsExactly({"C", "V1", "C", "V2", "C", "V3"});
	}

	test
	shared void partsInterleavedWithChorusStartingWithFirstPartWhenChorusIsTheSecondOrLaterPart() {
		// exercise
		value sut = PartsPresentation({"V1", "C", "V2", "V3"}, "C");
		// verify
		assertIterable(sut).containsExactly({"V1", "C", "V2", "C", "V3", "C"});
	}
}
