import java.io {
	JFile=File
}

import javax.xml.bind {
	JAXBContext,
	UnmarshalException,
	Unmarshaller
}

import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
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

class CleanableSong(CleaningOptions options, Cleanable presentation, Cleanable fileName, Cleanable lyrics) satisfies Cleanable {
	shared actual void clean() {
		if (options.presentation) {
			presentation.clean();
		}
		if (options.fileName) {
			fileName.clean();
		}
		if (options.lyrics) {
			lyrics.clean();
		}
	}
}

shared interface ContentChangeListener {
	shared formal void onSame();
	shared formal void onNew();
	shared formal void onDifferent();
}

shared interface SongLyrics {
	shared formal String lyrics;
}

class OpenSongSongLyrics(Provider<OpenSongSong> song) satisfies {Character*} {
	shared actual Iterator<Character> iterator() => song.get().lyrics.iterator();
}

class OpenSongSongPresentation(Provider<OpenSongSong> song) satisfies {Character*} {
	shared actual Iterator<Character> iterator() => song.get().presentation.iterator();
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

shared interface TextElement {
	shared formal void update({Character*} newContent);
}

shared class TextContentCorrection({Character*} _currentContent, {Character*} _newContent, TextElement element, ContentChangeListener listener, Boolean updateDifferent) satisfies Cleanable {
	shared actual void clean() {
		value currentContent = String(_currentContent);
		value newContent = String(_newContent);

		if (currentContent == newContent) {
			listener.onSame();
		} else if (currentContent.empty) {
			element.update(newContent);
			listener.onNew();
		} else {
			if (updateDifferent) {
				element.update(newContent);
			}
			listener.onDifferent();
		}
	}
}

shared class WhitespaceStrippedLyrics(SongLyrics _existingLyrics) satisfies {Character*} {
	shared actual Iterator<Character> iterator() => "\n".join(
		_existingLyrics.lyrics.lines.map((line) =>
			line.trimTrailing((Character trimming) => trimming == ' ')
		).filter((line) => !line.empty)
	).iterator();
}


class XmlFirstElement(NamedText xml, String elementName) satisfies TextElement {

	shared actual void update({Character*} newContent) {
		value content = xml.content();
		value startIndex = content.indexOf("<``elementName``>") + elementName.size + 2;
		value endIndex = content.indexOf("</``elementName``>", startIndex);
		if (endIndex >= 0) {
			xml.replaceContent(
				content.substring(0, startIndex) + String(newContent) + content.substring(endIndex)
			);
		} else {
			throw Exception("XML without '``elementName``' element: " + xml.name);
		}
	}
}
