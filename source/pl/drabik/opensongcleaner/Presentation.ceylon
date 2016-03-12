class ExtractedPartCodes(SongLyrics song) satisfies {String*} {
	shared actual Iterator<String> iterator() => song.lyrics
			.split((char) => {'[',']'}.contains(char))
			.indexed
			.filter((i) => !i.key.even)
			.map((element) => element.item)
			.iterator();
}

interface SongWithVerses {
	shared formal Boolean containsChorus;
	shared formal {String*} versesCodes;
}

class PartCodesSong({String*} partCodes) satisfies SongWithVerses {

	shared actual Boolean containsChorus {
		return partCodes.contains("C");
	}

	shared actual {String*} versesCodes {
		return partCodes.filter((element) => element != "C");
	}
}


class Presentation(SongWithVerses song) satisfies {Character*} {

	shared actual String string {
		value containsChorus = song.containsChorus;
		return " ".join(
			song.versesCodes
					.flatMap((verseCode) => if (containsChorus) then { verseCode, "C" } else { verseCode })
		);
	}

	shared actual Iterator<Character> iterator() => string.iterator();
}
