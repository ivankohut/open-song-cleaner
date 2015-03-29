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
	Directory,
	Nil,
	File,
	Path
}

import java.util {
	ArrayList
}

import javax.xml.bind {
	JAXBContext,
	Marshaller,
	Unmarshaller
}

import java.lang {
	JBoolean=Boolean
}

import java.io{
	JFile=File
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
			log.printToLog("Prezentácia nastavená.");
		} else if (oldPresentation!=newPresentation){
			log.printToLog("Vypočítaná prezentácia nie je v súlade s existujúcou.");
		} else {
			log.printToLog("");//TODO: satisfies specification, but not nice
		}
	}
}

shared class OpenSongCleaner() {
	
	variable OpenSongCleanerLog openSongCleanerLog = OpenSongCleanerLog();
	
	void raiseError(String message) {
		//throw Exception(message);
		log("chyba[``message``]");
	}
	
	void log(String message) {
		openSongCleanerLog.printToLog(message);
	}
	
	shared String lastLogMessage() {
		return openSongCleanerLog.lastMessage();
	}
		
	shared OpenSongSong readOpenSongSongFromXml(File file) {
		JAXBContext jaxbContext = JAXBContext.newInstance("pl.drabik.opensongcleaner.opensong");
		Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
		JFile jFile  = JFile(file.path.string);
		try {
			Object openSongSong = jaxbUnmarshaller.unmarshal(jFile);
			assert(is OpenSongSong openSongSong);
			return openSongSong;
		} catch (Exception e) {
			raiseError("Súbor nemá štruktúru OpenSong piesne.");
			throw e;
		}
	}
		
	shared void processOpenSongSong(OpenSongSong openSongSong) {
		value presentationComputer = OpenSongPresentationComputer();
		value openSongSongProcessor = OpenSongSongProcessor(presentationComputer,openSongCleanerLog);
		openSongSongProcessor.computeAndReplacePresentation(openSongSong);
	}
		
	shared void writeOpenSongSongToXml(OpenSongSong openSongSong, File file) {
		JAXBContext jaxbContext = JAXBContext.newInstance("pl.drabik.opensongcleaner.opensong");
		Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
		jaxbMarshaller.setProperty(Marshaller.\iJAXB_FORMATTED_OUTPUT, JBoolean.\iTRUE);
		JFile jFile  = JFile(file.path.string);
		jaxbMarshaller.marshal(openSongSong,jFile); 
	}
	
	shared void renameFileAccordingToOpenSongSongInfo(Path path, File file, OpenSongSong openSongSong) {
		value songFilenameProcessor = SongFilenameProcessor();
		value songFilename = songFilenameProcessor.createSongFilename(openSongSong.title,openSongSong.hymnNumber.intValue());
		if (songFilename != file.name) {
			value newPath = path.childPath(songFilename);
			if (is Nil loc = newPath.resource) {
				file.move(loc);
				log("Súbor '``file.name``' premenovaný na '``songFilename``'.");
			} else {
				raiseError("target file already exists");
			}
		}
	}
	
	void runOnEachFileInDirectory(String directory) {
			
		value path = parsePath(directory);
		value filenamePicker = FilenamePicker();

		if (is Directory dir = path.resource) {
			log("Spracúvam adresár '``directory``'.");

			for (file in dir.files()) {
				if (filenamePicker.shouldPick(file.name)) {
					log("Spracúvam súbor '``file.name``':");
					
					OpenSongSong openSongSong = readOpenSongSongFromXml(file);
					processOpenSongSong(openSongSong);
					writeOpenSongSongToXml(openSongSong, file);
					renameFileAccordingToOpenSongSongInfo(path, file, openSongSong);
				}
			}
		} else {
			raiseError("Adresár '``directory``' neexistuje.");
		}
	}
	
	shared void run(String[] args) {
	
		if (args.size == 1) {
			value directoryString = args[0];
			assert (exists directoryString);
			runOnEachFileInDirectory(directoryString);
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


shared class FilenamePicker() {
	shared Boolean shouldPick(String filename) {
		variable Boolean output = true;
		for (char in {'.','/','\\'} ) {
			output = output && !filename.contains(char);
		}
		return output;
	}
}
