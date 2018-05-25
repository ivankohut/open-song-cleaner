import ceylon.collection {
	ArrayList
}
import ceylon.file {
	temporaryDirectory,
	Directory,
	parsePath
}

import java.lang {
	JString=String
}
import java.nio.charset {
	StandardCharsets
}
import java.util {
	JList=List,
	JArrayList=ArrayList
}

import pl.drabik.opensongcleaner {
	ExtensionLess,
	Named,
	runCleaner,
	Logger,
	LogLevel,
	CleaningOptions,
	TextFile,
	FileOnPath,
	NamedText
}

shared class SpustenieVSystemeSAdresarovouStrukturou(String path) {

	shared variable JList<JString> argumenty = JArrayList<JString>();

	//	shared String sprava() {
	//		//TODO: prva sprava v logu
	//		value argumentyList = CeylonIterable<JString>(argumenty).map((str) => str.string).sequence();
	//
	//		try {
	//			value log = PrinterLog();
	//			value openSongCleaner = OpenSongCleaner(argumentyList,log);
	//			return openSongCleaner.log.lastMessage();
	//		} catch (Exception e) {
	//			return "chyba[``e.message``]";
	//		}
	//		//TODO: use existingDirectory instead of a particular one
	//	}
}

shared class VyberSuborovNaSpracovanie() {

	shared variable String nazovSuboru = "";

	class SimpleNamed(shared actual String name) satisfies Named {}

	shared Boolean vybranyNaSpracovanie() {
		value file = SimpleNamed(nazovSuboru);
		// exercise
		value pickedFiles = ExtensionLess({ file });

		return pickedFiles.contains(file);
	}
}

object nullLogger satisfies Logger {
	shared actual void log(LogLevel logLevel, String message) {}
}

class SimpleCleaningOptions(
	shared actual Boolean fileName,
	shared actual Boolean presentation,
	shared actual Boolean lyrics,
	String directory) satisfies CleaningOptions & {Character*} {
	shared actual Iterator<Character> iterator() => directory.iterator();
}

shared class VypocetPrezentacie() {

	shared variable String textPiesne = "";

	function firstElementText(String xml, String element) {
		value startIndex = xml.indexOf("<``element``>") + element.size + 2;
		value endIndex = xml.indexOf("</``element``>", startIndex);
		if (endIndex >= 0) {
			return xml.substring(startIndex, endIndex);
		} else {
			throw Exception("XML without '``element``' element.");
		}
	}

	NamedText newFileContaining(Directory directory, String content) {
		String tempFilePath = directory.TemporaryFile(null, null).path.string.removeTerminal(".tmp");
		assert (is String tempFileName = parsePath(tempFilePath).elements.last);

		value songFile = TextFile(
			object satisfies FileOnPath {
				shared actual String name => tempFileName;
				shared actual String path => tempFilePath;
			},
			StandardCharsets.utf8
		);
		songFile.replaceContent(content);
		return songFile;
	}

	shared String prezentacia() {
		value lyrics = textPiesne.removeInitial("<pre>").removeTerminal("</pre>");
		value directory= temporaryDirectory.TemporaryDirectory("osc");
		value songFile = newFileContaining(directory, "<song><lyrics>``lyrics``</lyrics><presentation></presentation></song>");
		// exercise
		runCleaner(SimpleCleaningOptions(false, true, false, directory.path.string), nullLogger);
		// response
		return firstElementText(songFile.content(), "presentation");
	}
}

//shared class NaplneniePrezentacie() {
//	registerConverters();
//
//	shared variable String? staraHodnota = "";
//	shared variable String vypocitanaHodnota = "";
//
//	variable CliLogger log = CliLogger();
//
//
//	shared String novaHodnota() {
//
//		value presentationComputer = ConstantPresentationComputer(vypocitanaHodnota);
//		value openSongSongProcessor = OpenSongSongProcessor(presentationComputer,log);
//
//		value song = createOpenSongSong(staraHodnota else "");
//
//		try {
//			openSongSongProcessor.computeAndReplacePresentation(song);
//			return song.presentation;
//		} catch (Exception e) {
//			return "chyba[``e.message``]";
//		}
//	}
//
//	shared String spravaVLogu(){
//		return log.lastMessage();
//	}
//}

shared class NazovSuboruPiesne() {

	variable Integer cislo = 0;
	variable String nazov = "";

	shared void piesenSCislomANazvom(Integer cislo, String nazov) {
		this.cislo = cislo;
		this.nazov = nazov;
	}

	//shared String nazovSuboru() {
	//	return String(SongFileName(nazov, cislo));
	//}
}

shared class VysledkySpracovaniaSuborov() {

	shared variable String nazovSuboru = "";
	shared variable String typVysledku = "";
	shared variable String spravaSpracovania = "";
	shared variable Boolean premenovany = false;

	shared void compute() {
		kontext.riadky.add(Riadok(nazovSuboru, typVysledku, spravaSpracovania, premenovany));
	}
}

shared class Riadok(shared String nazovSuboru, shared String typVysledku, shared String spravaSpracovania, shared Boolean premenovany) {
}

object kontext {
	shared ArrayList<Riadok> riadky = ArrayList<Riadok>();
}

shared class SpravyVAplikacnomLogu() {

	JList<Object> list(Object* objects) {
		value jArrayList = JArrayList<Object>();
		for (myObject in objects) {
			jArrayList.add(myObject);
		}
		return jArrayList;
		//TODO: testovacia implementacia logu
	}

	shared JList<Object> query() {

		return
			list(
				list(
					list("zaznam v logu", "Spracúvam súbor 'piesen':")
				),
				list(
					list("zaznam v logu", "- Prezentácia nastavená.")
				)
			);
	}
}
