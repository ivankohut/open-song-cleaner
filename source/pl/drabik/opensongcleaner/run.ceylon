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
	shared actual default String name => parsePath(path).normalizedPath.elementPaths.last?.string else "";
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

class DirectoryOfFiles(MyFile directory) satisfies Iterable<MyFile> {

	Directory fsDirectory() {
		if (is Directory dir = parsePath(directory.path).resource) {
			return dir;
		} else {
			throw Exception("Adresár '``directory.path``' neexistuje.");
		}
	}

	shared actual Iterator<MyFile> iterator() => fsDirectory().files()
		.sort((File x, File y) => x.name.compare(y.name))
		.map((file) => FileMyFile(file)).iterator();
}


shared interface Cleanable {
	shared formal void clean();
}

shared interface PresentationListener {
	shared formal void onSame();
	shared formal void onNew();
	shared formal void onDifferent();
}

shared class PresentationCorrectingSong(
	SongPresentation _existingPresentation,
	{Character*} _newPresentation, 
	Presentable song,
	PresentationListener listener
) satisfies Cleanable {
	shared actual void clean() {
		value existingPresentation = _existingPresentation.presentation;
		value newPresentation = String(_newPresentation);
		
		if (existingPresentation == newPresentation) {
			listener.onSame();
		} else if (existingPresentation.empty) {
			song.setPresentation(newPresentation);
			listener.onNew();
		} else {
			listener.onDifferent();
		}
	}
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

class UTF8TextFile(MyFile myFile) satisfies TextFile {
	value fileEncoding = "UTF-8";
	value file = JFile(myFile.path);

	shared actual String name => file.name;

	shared actual String content() {
		return FileUtils.readFileToString(file, fileEncoding);
	}

	shared actual void replaceContent(String newContent) {
		FileUtils.writeStringToFile(file, newContent, fileEncoding);
	}
}

shared class LoggingPresentationListener(Named subject, Logger logger) satisfies PresentationListener & RenamingListener {
	shared actual void onDifferent() {
		logger.log(warning, "``subject.name`` - Prezentácia sa nezhoduje!");
	}
	
	shared actual void onNew() {
		logger.log(info, "``subject.name`` - Prezentácia bola nastavená.");
	}
	
	shared actual void onSame() {}
	
	shared actual void onRename(String newName) {
		logger.log(info, "``subject.name`` - súbor piesne premenovaný na '``newName``'");
	}
}

shared interface CleanableFileFactory {
	shared formal {Cleanable*} create(MyFile file);
}

shared interface CleaningOptions {
	shared formal Boolean presentation;
	shared formal Boolean fileName;
}

class OpenSongFileBasedCleanableSongFactory(JAXBContext jaxbContext, Logger logger, CleaningOptions settings) satisfies CleanableFileFactory {
	shared actual {Cleanable*} create(MyFile file) {
		
		value songFile = SongFile(CachedOpenSongSongProvider(XmlFileOpenSongSongProvider(jaxbContext, file)));
		value listener = LoggingPresentationListener(file, logger);
		
		return expand([
			if (settings.presentation) then {PresentationCorrectingSong(
				songFile,
				Presentation(PartCodesSong(ExtractedPartCodes(songFile))),
				PresentableSongFile(UTF8TextFile(file)),
				listener
			)} else {},
			 
			if (settings.fileName) then {FileNameCorrecting(
				file, 
				SongFileName(songFile), 
				listener
			)} else {}
		]);
	}
}

class FileCleanableOpenSongSongs({MyFile*} songFiles, CleanableFileFactory factory) satisfies Cleanable {
	shared actual void clean() {
		songFiles.flatMap(factory.create).each((song) => song.clean());
	}
}

"The runnable method of the module."
shared void run() {
	value options = OpenSongCleanerOptions();
	FileCleanableOpenSongSongs(
		SongFiles(
			DirectoryOfFiles(options)
		),
		OpenSongFileBasedCleanableSongFactory(
			JAXBContext.newInstance("pl.drabik.opensongcleaner.opensong"),
			CliLogger(),
			options
		)
	).clean();
}

class OpenSongCleanerOptions() satisfies CleaningOptions & MyFile {
	
	Nothing noDirectorySpecified() {
		throw Exception("No directory specified.");
	}
	
	suppressWarnings("expressionTypeNothing")
	shared actual String path => process.namedArgumentValue("d") else noDirectorySpecified();
	
	shared actual Boolean fileName => process.namedArgumentPresent("r");
	shared actual Boolean presentation => process.namedArgumentPresent("p");
	
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

shared interface RenamingListener {
	shared formal void onRename(String newName);
}

class FileNameCorrecting(MyFile file, {Character*} newName, RenamingListener listener) satisfies Cleanable {
	shared actual void clean() {
		value newFilenameString = String(newName);
		if (newFilenameString != file.name) {
			value filePath = parsePath(file.path);
			value newPath = filePath.siblingPath(newFilenameString);
			if (is Nil loc = newPath.resource) {
				if (is File r = filePath.resource) {
					r.move(loc);
					listener.onRename(newFilenameString);
				} else {
					throw Exception("'``file.name``' nie je súbor.");
				}
			} else {
				throw Exception("Súbor '``file.name``' nemôže byť premenovaný na '``newFilenameString``'. Cieľový súbor už existuje.");
			}
		}
	}
}
