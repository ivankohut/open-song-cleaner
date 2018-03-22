import java.io {
	JFile=File
}
import java.util.regex {
	Pattern
}

import javax.xml.bind {
	JAXBContext,
	UnmarshalException,
	Unmarshaller
}

import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}

import java.lang {
	Types {
		nativeString
	}
}

shared interface Cleanable {
	shared formal void clean();
}

class HymnBook({Cleanable*} songs) satisfies Cleanable {
	shared actual void clean() {
		// this does not work - method reference (possible ceylon bug):
		//   songs.each(Cleanable.clean);
		// so I must use this:
		for (song in songs) {
			song.clean();
		}
	}
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
	PresentationListener listener) satisfies Cleanable {
	shared actual void clean() {
		value existingPresentation = _existingPresentation.presentation;
		value newPresentation = String(_newPresentation);

		if (existingPresentation == newPresentation) {
			listener.onSame();
		} else if (existingPresentation.empty) {
			song.updatePresentation(newPresentation);
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

class SongFile(Provider<OpenSongSong> openSongSong) satisfies SongLyrics & SongPresentation {
	shared actual String lyrics => openSongSong.get().lyrics;
	shared actual String presentation => openSongSong.get().presentation;
}

class OpenSongSongTitle(Provider<OpenSongSong> song) satisfies {Character*} {
	shared actual Iterator<Character> iterator() => song.get().title.iterator();
}

class OpenSongSongHymnNumber(Provider<OpenSongSong> song) {
	shared actual String string => song.get().hymnNumber.string;
}

shared interface Presentable {
	shared formal void updatePresentation(String presentation);
}

class PresentableSongFile(NamedText file) satisfies Presentable {

	shared actual void updatePresentation(String presentation) {
		value content = file.content();
		value matcher = Pattern.compile("(\\<presentation\\>(.*)\\<\\/presentation\\>)").matcher(nativeString(content));
		if (matcher.find()) {
			file.replaceContent(
				content.replaceFirst(matcher.group(1), "<presentation>" + presentation + "</presentation>")
			);
		} else {
			throw Exception("File without presentation element: " + file.name);
		}
	}
}

"Named objects whose name does not contain dot ('.')"
shared class ExtensionLess<N>(Iterable<N> files) satisfies Iterable<N> given N satisfies Named {

	Boolean isExtensionLess(Named file) => !file.name.contains('.');

	shared actual Iterator<N> iterator() => files.filter(isExtensionLess).iterator();
}

class OpenSongSongSerializerException(String message, Exception cause) extends Exception(message, cause) {
}

class XmlFileOpenSongSongProvider(JAXBContext jaxbContext, FileOnPath file) satisfies Provider<OpenSongSong> {
	shared actual OpenSongSong get() {
		Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
		JFile jFile = JFile(file.path);
		try {
			Object openSongSong = jaxbUnmarshaller.unmarshal(jFile);
			assert (is OpenSongSong openSongSong);
			return openSongSong;
		} catch (UnmarshalException e) {
			//			log.log("WARNING", "Súbor nemá štruktúru OpenSong piesne.");
			throw OpenSongSongSerializerException("Súbor ``file.name`` nemá štruktúru OpenSong piesne.", e);
		}
	}
}

shared interface RenamingListener {
	shared formal void onRename(String newName);
}
