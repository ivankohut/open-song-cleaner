import ceylon.interop.java {
	javaString
}

import org.apache.commons.lang3 {
	StringUtils{leftPad}
}

import java.text {
	Normalizer
}

String removeAccents(String input) {
	value normalizedString = Normalizer.normalize(javaString(input), Normalizer.Form.\iNFD);
	return javaString(normalizedString).replaceAll("[^\\p{ASCII}]", "");
}

String formatHymnNumber(Integer input) => leftPad(input.string, 3, '0');

shared String createSongFilename(String songName, Integer hymnNumber) 	
	=> formatHymnNumber(hymnNumber) + " - " + removeAccents(songName);
