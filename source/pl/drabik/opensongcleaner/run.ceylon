import ceylon.interop.java {
	javaString
}

import org.apache.commons.lang3 {
	StringUtils{leftPad}
}

import java.text {
	Normalizer
}
import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}
import ceylon.file {
	parsePath,
	Directory
}
import java.util {
	ArrayList
}

	
shared class SongFilenameProcessor() {

	shared String removeAccents(String input) {
		value normalizedString = Normalizer.normalize(javaString(input), Normalizer.Form.\iNFD);
		return javaString(normalizedString).replaceAll("[^\\p{ASCII}]", "");
	}
	
	shared String formatHymnNumber(Integer input) => leftPad(input.string, 3, '0');
	
	shared String createSongFilename(String songName, Integer hymnNumber) 	
			=> formatHymnNumber(hymnNumber) + " - " + removeAccents(songName);
}


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


shared class OpenSongSongProcessor(PresentationComputer presentationComputer, OpenSongCleanerLog openSongCleanerLog) {
	
	variable OpenSongCleanerLog log = openSongCleanerLog;
	
	shared void computeAndReplacePresentation(OpenSongSong song) {
		value oldPresentation = song.presentation; 
		value newPresentation = presentationComputer.compute(song.lyrics); 
		
		if (oldPresentation=="") {
			song.presentation = newPresentation;
			log.printToLog("Prezentácia vytvorená.");
		} else if (oldPresentation!=newPresentation){
			log.printToLog("Vypočítaná prezentácia nie je v súlade s existujúcou.");
		} else {
			log.printToLog("");//TODO: satisfies specification, but not nice
		}
	}
}

shared class OpenSongCleaner() {
	
	variable OpenSongCleanerLog log = OpenSongCleanerLog();
	
	void raiseError(String message) {
		//throw Exception(message);
		log.printToLog("chyba[``message``]");
	}
	
	shared String lastLogMessage() {
		return log.lastMessage();
	}
		
	shared void run(String[] args) {
		
		if (args.size == 1) {
			value directory = args[0];
			assert(exists directory);
			
			value path = parsePath(directory);
			if (is Directory loc = path.resource) {
				log.printToLog("Spracúvam adresár '``directory``'.");
				//TODO loop through all files and call OpenSongCleaner on each
			} else {
				raiseError("Adresár '``directory``' neexistuje.");
			}
		} else {
			raiseError("Nesprávny počet argumentov (``args.size.string``). Očakáva sa jeden argument - názov adresára.");
		}
	}
}

"The runnable method of the module."
shared void run() {
	value openSongCleaner = OpenSongCleaner();
	openSongCleaner.run(process.arguments);
}


shared class OpenSongCleanerLog() {
	variable ArrayList<String> log = ArrayList<String>();
	
	shared void printToLog(String message) {
		print(message);
		log.add(message);
	}
	
	shared String lastMessage() {
		if (log.size() == 0) {
			return "";
		} else {
			return log.get(log.size()-1);
		}
	}
}
