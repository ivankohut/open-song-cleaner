import java.text {
	Normalizer
}
import ceylon.interop.java {
	javaString
}

class AccentsLess({Character*} input) satisfies {Character*} {
	shared actual Iterator<Character> iterator() {
		value normalizedString = Normalizer.normalize(javaString(input.string), Normalizer.Form.\iNFD);
		return javaString(normalizedString).replaceAll("[^\\p{ASCII}]", "").iterator();
	}
}

shared interface SongIdentifiers {
	shared formal String title;
	shared formal Integer hymnNumber;
}


shared class SongFileName(SongIdentifiers identifiers) satisfies {Character*} {

	String formatHymnNumber(Integer input) => input.string.padLeading(3, '0');

	String createSongFilename(String songName, Integer hymnNumber)
		=> formatHymnNumber(hymnNumber) + " - " + String(AccentsLess(songName));

	shared actual Iterator<Character> iterator() =>
		createSongFilename(identifiers.title, identifiers.hymnNumber).iterator();
}