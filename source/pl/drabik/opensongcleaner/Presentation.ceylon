"Part codes extracted from lyrics."
class ExtractedPartCodes(SongLyrics song) satisfies {String*} {

	{String*} partAndContentToSections({String+} partAndContent) {
		value content = partAndContent.rest.first;
		assert (exists content);
		return content.lines
			.map((line) => line.first)
			.coalesced
			.distinct
			.map((section) => partAndContent.first + section.string.trimmed);
	}

	shared actual Iterator<String> iterator() =>
		"\n".join(song.lyrics.lines.filter((line) => !line.startsWith(";") && !line.startsWith(".") && !line.trimmed.empty))
			.split((char) => { '[', ']' }.contains(char))
			.filter((item) => !item.trimmed.empty)
			.partition(2)
			.flatMap(partAndContentToSections)
			.iterator();
}

"Song parts ordered for presentation, i.e. verses interleaved with chorus."
class PartsPresentation({String*} parts, String chorusCode) satisfies {String*} {
	shared actual Iterator<String> iterator() {
		value partsSequence = parts.sequence();
		if (partsSequence.contains(chorusCode)) {
			{String*}(String) verseCodeToVerseChorusPair;
			// does not compile when converted to if expression
			if (partsSequence.startsWith([chorusCode])) {
				verseCodeToVerseChorusPair = (String verseCode) => { chorusCode, verseCode };
			} else {
				verseCodeToVerseChorusPair = (String verseCode) => { verseCode, chorusCode };
			}
			return partsSequence.filter((part) => part != chorusCode).flatMap(verseCodeToVerseChorusPair).iterator();
		} else {
			return partsSequence.iterator();
		}
	}
}

