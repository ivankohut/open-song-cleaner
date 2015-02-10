import ceylon.interop.java {
	javaString
}

import org.apache.commons.lang3 {
	StringUtils{leftPad}
}

import java.text {
	Normalizer
}
import javax.xml.transform {
	Result
}

String removeAccents(String input) {
	value normalizedString = Normalizer.normalize(javaString(input), Normalizer.Form.\iNFD);
	return javaString(normalizedString).replaceAll("[^\\p{ASCII}]", "");
}

String formatHymnNumber(Integer input) => leftPad(input.string, 3, '0');

shared String createSongFilename(String songName, Integer hymnNumber) 	
	=> formatHymnNumber(hymnNumber) + " - " + removeAccents(songName);


shared class PartCodes(String songText) {

	{String*} extractPartCodes(String songText) {
		value splitSongText = songText.split(
			(char) => {'[',']'}.contains(char)
		);
		
		return splitSongText.indexed.filter(
			(i) => !i.key.even
		).map((element) => element.item);
	}

	value partCodes = extractPartCodes(songText); 
	
	default shared Boolean containsChorus() {
		return partCodes.contains("C");
	}
	default shared {String*} extractVersesCodes() {
		return partCodes.filter((element) => element!="C");
	}
	
}

shared class Presentation(PartCodes partCodes) {
	
	value separator = " ";
	
	shared String computePresentation() {
		value versesCodes = partCodes.extractVersesCodes();
		
		variable {String*} presentationCollection = {};
		if (partCodes.containsChorus()) {
			presentationCollection = versesCodes.map((element) => element + separator + "C");
		}
		else {
			presentationCollection = versesCodes;
		}
		 
		return separator.join(presentationCollection);
	}
}
