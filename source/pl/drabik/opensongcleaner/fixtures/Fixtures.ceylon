import ceylon.collection {
	ArrayList
}
import ceylon.interop.java {
	CeylonIterable
}

import java.lang {
	JString=String
}
import java.util {
	JList=List,
	JArrayList=ArrayList
}

import pl.drabik.opensongcleaner {
	OpenSongSongProcessor,
	OpenSongPresentationComputer,
	ConstantPresentationComputer,
	createOpenSongSong,
	SongFileName,
	OpenSongCleaner,
	PrinterLog,
	SongFiles,
	oscFileUtils,
	TestDir,
	Named
}
import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
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
		value pickedFiles = SongFiles({file});

		return pickedFiles.contains(file);
	}
}

shared class VypocetPrezentacie() {

	shared variable String textPiesne = "";

	shared String prezentacia() {
		value song = OpenSongSong();
		song.lyrics =  textPiesne;
		song.presentation = "";

		value songProcessor = OpenSongSongProcessor(OpenSongPresentationComputer(),PrinterLog());
		songProcessor.computeAndReplacePresentation(song);

		return song.presentation;
	}
}

shared class NaplneniePrezentacie() {
	registerConverters();

	shared variable String? staraHodnota = "";
	shared variable String vypocitanaHodnota = "";

	variable PrinterLog log = PrinterLog();


	shared String novaHodnota() {

		value presentationComputer = ConstantPresentationComputer(vypocitanaHodnota);
		value openSongSongProcessor = OpenSongSongProcessor(presentationComputer,log);

		value song = createOpenSongSong(staraHodnota else "");

		try {
			openSongSongProcessor.computeAndReplacePresentation(song);
			return song.presentation;
		} catch (Exception e) {
			return "chyba[``e.message``]";
		}
	}

	shared String spravaVLogu(){
		return log.lastMessage();
	}
}

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

	shared void compute(){
		kontext.riadky.add(Riadok(nazovSuboru,typVysledku,spravaSpracovania,premenovany));
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
				list("zaznam v logu","Spracúvam súbor 'piesen':")
			),
			list(
				list("zaznam v logu","- Prezentácia nastavená.")
			)
		);
	}
}