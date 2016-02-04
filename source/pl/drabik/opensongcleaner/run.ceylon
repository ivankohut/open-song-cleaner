import ceylon.file {
	parsePath,
	Directory,
	Nil,
	File
}
import ceylon.interop.java {
	javaString
}
import java.io {
	JFile=File
}
import java.util {
	ArrayList
}
import java.util.regex {
	Pattern
}
import javax.xml.bind {
	JAXBContext,
	Unmarshaller,
	UnmarshalException
}
import org.apache.commons.io {
	FileUtils
}
import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}


shared interface MyFile satisfies Named {
	shared formal String path;
}

shared class FileMyFile(File file) satisfies MyFile {
	shared actual String name => file.name;
	shared actual String path => file.path.string;
}


class OneArgument(String[] args) satisfies {Character*} {
	shared actual Iterator<Character> iterator() {
		if (args.size == 1) {
			value directoryString = args[0];
			assert (exists directoryString);
			return directoryString.iterator();
		} else {
			throw Exception("Nesprávny počet argumentov (``args.size.string``). Očakáva sa jeden argument - názov adresára.");
		}
	}
}

class DirectoryOfFiles({Character*} directoryString) satisfies Iterable<MyFile> {

	Directory directory() {
		if (is Directory dir = parsePath(String(directoryString)).resource) {
			return dir;
		} else {
			throw Exception("Adresár '``directoryString``' neexistuje.");
		}
	}

	shared actual Iterator<MyFile> iterator() => directory().files()
		.sort((File x, File y) => x.name.compare(y.name))
		.map((file) => FileMyFile(file)).iterator();
}


shared interface CleanableOpenSongSong {
	shared formal void clean();
}

shared interface FileSerializer {
	shared formal OpenSongSong readFromXml(MyFile file);
	shared formal void writeToXml(OpenSongSong openSongSong, MyFile file);
}

shared interface SongLyrics {
	shared formal String lyrics;
}

shared interface SongPresentation {
	shared formal String presentation;
}

class SongFile(OpenSongSongProvider openSongSong) satisfies SongLyrics & SongIdentifiers & SongPresentation {
	shared actual Integer hymnNumber => openSongSong.get().hymnNumber.intValue();
	shared actual String lyrics => openSongSong.get().lyrics;
	shared actual String title => openSongSong.get().title;
	shared actual String presentation => openSongSong.get().presentation;
}

shared interface UpdatedSong satisfies Named {
	shared formal Boolean wasFileRenamed();
	shared formal Boolean? originalPresentationCorrect();
}

shared interface UpdateblePresentation {
	shared formal Boolean? originalPresentationCorrect();
}

class UpdatablePresentableSong({Character*} _existingPresentation, {Character*} _newPresentation, Presentable song) satisfies UpdateblePresentation {

	shared actual Boolean? originalPresentationCorrect() {
		value existingPresentation = String(_existingPresentation);
		value newPresentation = String(_newPresentation);
		
		if (existingPresentation == newPresentation) {
			return true;
		} else if (existingPresentation.empty) {
			song.setPresentation(newPresentation);
			return null;
		} else {
			return false;
		}
	}
}

shared interface Presentable {
	shared formal void setPresentation(String presentation);
}

class PresentableSongFile(TextFile file) satisfies Presentable {
	
	shared actual void setPresentation(String presentation) {
		value content = file.content();
		value matcher = Pattern.compile("(\\<presentation\\>(.*)\\<\\/presentation\\>)").matcher(javaString(content));
		if (matcher.find()) {
			file.replaceContent(
				content.replaceFirst(matcher.group(1), "<presentation>" + presentation + "</presentation>")
			);
		} else {
			throw Exception("File without presentation element: " + file.name);
		}
	}
}

shared interface TextFile satisfies Named {
	shared formal String content();
	shared formal void replaceContent(String newContent);
}

class UTF8TextFile(String filePath) satisfies TextFile {
	value fileEncoding = "UTF-8";
	value file = JFile(filePath);
	
	shared actual String name => file.name;
	
	shared actual String content() {
		return FileUtils.readFileToString(file, fileEncoding);
	}

	shared actual void replaceContent(String newContent) {
		FileUtils.writeStringToFile(file, newContent, fileEncoding);
	}
}


class FileCleanableOpenSongSongs({MyFile*} songFiles, JAXBContext jaxbContext) satisfies Iterable<UpdatedSong>{
	shared actual Iterator<UpdatedSong> iterator() =>
		songFiles.map((file) {
			value songFile = SongFile(CachedOpenSongSongProvider(XmlFileOpenSongSongProvider(jaxbContext, file)));
			value song = UpdatablePresentableSong(
				songFile.presentation,
				Presentation(PartCodesSong(ExtractedPartCodes(songFile.lyrics))),
				PresentableSongFile(UTF8TextFile(file.path))
			);
			value renamedSongFile = RenamedFile(file, SongFileName(songFile));
			return object satisfies UpdatedSong {
				shared actual Boolean? originalPresentationCorrect() => song.originalPresentationCorrect();
				shared actual String name => file.name;
				shared actual Boolean wasFileRenamed() => renamedSongFile.wasRenamed();
			};
		}).iterator();
}


shared class OpenSongCleaner(Iterable<UpdatedSong> songs, MyLog logger) {
	shared void clean() {
		songs.each(void (UpdatedSong song) {
			if (song.wasFileRenamed()) {
				logger.log("INFO", "``song.name`` - subor piesne premenovany");
			}
			switch (song.originalPresentationCorrect())
				case (false) {
					 logger.log("WARN", "``song.name`` - Prezentacia sa nezhoduje");
				}
				case (true) {
				}
				case (null) {
					logger.log("INFO", "``song.name`` - Prezentacia bola nastavena.");
				}
		});
	}
}

"The runnable method of the module."
shared void run() {
	value log = PrinterLog();
	OpenSongCleaner(
		FileCleanableOpenSongSongs(
			SongFiles(
				DirectoryOfFiles(OneArgument(process.arguments))
			),
			JAXBContext.newInstance("pl.drabik.opensongcleaner.opensong")
		),
		log
	).clean();
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



shared interface Named {
	shared formal String name;
}


shared class SongFiles<N>(Iterable<N> files) satisfies Iterable<N> given N satisfies Named {

	Boolean isExtensionLess(Named file) => !file.name.contains('.');

	shared actual Iterator<N> iterator() => files.filter(isExtensionLess).iterator();
}


class OpenSongSongSerializerException() extends Exception() {
}


interface OpenSongSongProvider {
	shared formal OpenSongSong get();
}

class CachedOpenSongSongProvider(OpenSongSongProvider underlying) satisfies OpenSongSongProvider {
	variable OpenSongSong? cached = null;

	shared actual OpenSongSong get() =>
			cached else (cached = underlying.get());
}

class XmlFileOpenSongSongProvider(JAXBContext jaxbContext, MyFile file) satisfies OpenSongSongProvider {
	shared actual OpenSongSong get() {
		Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
		JFile jFile  = JFile(file.path.string);
		try {
			Object openSongSong = jaxbUnmarshaller.unmarshal(jFile);
			assert(is OpenSongSong openSongSong);
			return openSongSong;
		} catch (UnmarshalException e) {
//			log.log("WARNING", "Súbor nemá štruktúru OpenSong piesne.");
			throw OpenSongSongSerializerException();
		}
	}
}

class RenamedFile(MyFile file, {Character*} newName) {
	shared Boolean wasRenamed() {
		value newFilenameString = String(newName);
		if (newFilenameString != file.name) {
			value filePath = parsePath(file.path);
			value newPath = filePath.siblingPath(newFilenameString);
			if (is Nil loc = newPath.resource) {
				if (is File r = filePath.resource) {
					r.move(loc);
					return true;
				} else {
					throw Exception("'``file.name`` nie je súbor");
				}
			} else {
				throw Exception("Súbor '``file.name``' nemôže byť premenovaný na '``newFilenameString``'. Cieľový súbor už existuje.");
			}
		} else {
			return false;
		}
	}
}
