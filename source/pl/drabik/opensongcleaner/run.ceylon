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
	ExistingResource
}

import java.util {
	ArrayList
}

import javax.xml.bind {
	JAXBContext,
	Marshaller,
	Unmarshaller,
	UnmarshalException
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


shared class OpenSongSongProcessor(PresentationComputer presentationComputer, MyLog log) {
	
	shared void computeAndReplacePresentation(OpenSongSong song) {
		value oldPresentation = song.presentation; 
		value newPresentation = presentationComputer.compute(song.lyrics); 
		
		if (oldPresentation=="") {
			song.presentation = newPresentation;
			log.log("INFO", "Prezentácia nastavená.");
		} else if (oldPresentation!=newPresentation){
			log.log("WARNING", "Vypočítaná prezentácia nie je v súlade s existujúcou.");
		}
	}
}


shared class OpenSongCleaner(String[] args, shared MyLog log) {
	
	value fsp = FileSystemProcessor(log);
	
	Directory parseArgs(String[] args) {
		if (args.size == 1) {
			value directoryString = args[0];
			assert (exists directoryString);
			try {
				return fsp.getDirectory(directoryString);
			} catch(FileSystemProcessorException e) {
				value errorMessage = log.lastMessage();
				throw Exception(errorMessage);
			}
		} else {
			log.log("SEVERE","Nesprávny počet argumentov (``args.size.string``). Očakáva sa jeden argument - názov adresára.");
			value errorMessage = log.lastMessage();
			throw Exception(errorMessage);
		}
	}
	
	value directory = parseArgs(args);
		
	String processOpenSongSong(OpenSongSong openSongSong) {
		value presentationComputer = OpenSongPresentationComputer();
		value openSongSongProcessor = OpenSongSongProcessor(presentationComputer,log);
		openSongSongProcessor.computeAndReplacePresentation(openSongSong);
		
		value songFilenameProcessor = SongFilenameProcessor();
		return songFilenameProcessor.createSongFilename(openSongSong.title,openSongSong.hymnNumber.intValue());
	}
		
	void processOpenSongFile(File file) {
		log.log("INFO", "Spracúvam súbor '``file.name``':");

		value serializer = OpenSongSongSerializer(log);
		try {
			OpenSongSong openSongSong = serializer.readFromXml(file);
			serializer.writeToXml(openSongSong, file);
			value newFilename = processOpenSongSong(openSongSong);
			fsp.renameFile(file, newFilename);
		} catch (OpenSongSongSerializerException e) {
			// do nothing
		}
	}
	
	void runOnEachFileInDirectory(Directory dir) {
		value filenamePicker = FilenamePicker(dir);
		log.log("INFO", "Spracúvam adresár '``directory``'.");

		for (file in filenamePicker) {
			processOpenSongFile(file);
		}
	}
	
	shared void run() {
		runOnEachFileInDirectory(directory);
	}
}

"The runnable method of the module."
shared void run() {
	value log = PrinterLog();
	value openSongCleaner = OpenSongCleaner(process.arguments, log);
	openSongCleaner.run();
}


shared interface MyLog {
	shared formal void log(String logLevel, String message);//TODO logLevel should be enumerated
	shared formal String lastMessage();
}


shared class PrinterLog() satisfies MyLog {

	value logArrayList = ArrayList<String>();
	
	shared actual void log(String logLevel, String message) {
		value logText = logLevel + ": " + message;
		print(logText);
		logArrayList.add(message);
	}
	
	shared actual String lastMessage() {
		value logSize = logArrayList.size();
		if (logSize == 0) {
			return "Log is empty";
		} else {
			return logArrayList.get(logSize-1);
		}
	}
}


shared class FilenamePicker(Directory dir) satisfies Iterable<File> {
	
	Boolean isExtensionLess(File file) => !file.name.contains('.');
	
	shared actual Iterator<File> iterator() => dir.files().filter(isExtensionLess).iterator();
}


class OpenSongSongSerializerException() extends Exception() {
}

shared class OpenSongSongSerializer(MyLog log) {
	
	JAXBContext jaxbContext = JAXBContext.newInstance("pl.drabik.opensongcleaner.opensong");
	
	shared OpenSongSong readFromXml(File file) {
		Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
		JFile jFile  = JFile(file.path.string);
		try {
			Object openSongSong = jaxbUnmarshaller.unmarshal(jFile);
			assert(is OpenSongSong openSongSong);
			return openSongSong;
		} catch (UnmarshalException e) {
			log.log("WARNING", "Súbor nemá štruktúru OpenSong piesne.");
			throw OpenSongSongSerializerException();
		}
	}

	shared void writeToXml(OpenSongSong openSongSong, File file) {
		Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
		jaxbMarshaller.setProperty(Marshaller.\iJAXB_FORMATTED_OUTPUT, JBoolean.\iTRUE);
		JFile jFile  = JFile(file.path.string);
		jaxbMarshaller.marshal(openSongSong,jFile); 
	}
}


class FileSystemProcessorException() extends Exception() {
}


class FileSystemProcessor(MyLog log){
	
	shared void renameFile(File file, String newFilename) {
		if (newFilename != file.name) {
			value newPath = file.path.siblingPath(newFilename); 
			if (is Nil loc = newPath.resource) {
				file.move(loc);
				log.log("INFO", "Súbor '``file.name``' premenovaný na '``newFilename``'.");
			} else {
				log.log("WARNING", "Súbor '``file.name``' nemôže byť premenovaný na '``newFilename``'. Cieľový súbor už existuje.");
				throw FileSystemProcessorException();
			}
		}
	}
	
	shared Directory getDirectory(String directoryString) {
		value path = parsePath(directoryString);
		if (is Directory dir = path.resource) {
			return dir;
		} else {
			log.log("WARNING", "Adresár '``directoryString``' neexistuje.");
			throw FileSystemProcessorException();
		}
	}
	
	shared void deleteRecursively(ExistingResource res) {
		switch (res)
		case (is File) { 
			res.delete(); 
		}
		case (is Directory) {
			for (child in res.children()) {
				deleteRecursively(child);
			}
			res.delete();
		}
		else {
			log.log("WARNING", "'``res``' nie je adresár.");
			throw FileSystemProcessorException();
		}
	}
	
	shared Boolean containsFile({File*} files, File expectedFile) => 
			files.any((file) => file.path.absolutePath == expectedFile.path.absolutePath);
}
