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
import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
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
	
	function compute() {
		value versesCodes = partCodes.extractVersesCodes();
		if (partCodes.containsChorus()) {
			return versesCodes.map((element) => element + separator + "C");
		}
		else {
			return versesCodes;
		}
	}
	
	shared actual String string {
		value presentationCollection=compute();
		return separator.join(presentationCollection);
	}
}


shared interface PresentationComputer {
	shared formal String compute(String lyrics); 
}

shared class OpenSongPresentationComputer() satisfies PresentationComputer {
	shared actual String compute(String lyrics) {
		value partCodes = PartCodes(lyrics);
		value presentation = Presentation(partCodes);
		return presentation.string;
	}
}


shared class OpenSongSongProcessor(PresentationComputer presentationComputer) {
	
	shared void computeAndReplacePresentation(OpenSongSong song) {
		value oldPresentation = song.presentation; 
		value newPresentation = presentationComputer.compute(song.lyrics); 
		
		if (oldPresentation=="") {
			song.presentation = newPresentation;
		} else if (oldPresentation!=newPresentation){
			throw Exception("Vypočítaná prezentácia nie je v súlade s existujúcou.");
		}
	}
}
