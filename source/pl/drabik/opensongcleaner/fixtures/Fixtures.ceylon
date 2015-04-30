import ceylon.collection {
	ArrayList
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
	SongFilenameProcessor,
	OpenSongCleaner,
	OpenSongCleanerLog,
	FilenamePicker,
	oscFileUtils
}
import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}
import ceylon.interop.java {
	CeylonIterable
}


shared class SpustenieVSystemeSAdresarovouStrukturou(String path) {
	
	shared variable JList<JString> argumenty = JArrayList<JString>();

	shared String sprava() {
		value argumentyList = CeylonIterable<JString>(argumenty).map((str) => str.string).sequence();

		try {
			value log = OpenSongCleanerLog();
			value openSongCleaner = OpenSongCleaner(argumentyList,log);	
			return openSongCleaner.log.lastMessage();
		} catch (Exception e) {
			return "chyba[``e.message``]";
		}
	}
}

shared class VyberSuborovNaSpracovanie() {
	
	shared variable String nazovSuboru = "";
	
	shared Boolean vybranyNaSpracovanie() {
		value testDir = oscFileUtils.createNewDir("fixtureTestDir");
		value file = oscFileUtils.createFileInDir(testDir, nazovSuboru);
		// exercise
		value pickedFiles = FilenamePicker(testDir);
		value filenamePicked = oscFileUtils.containsFile(pickedFiles, file);
		// cleanup
		oscFileUtils.deleteRecursively(testDir);

		return filenamePicked;
	}
}

shared class VypocetPrezentacie() {
	
	shared variable String textPiesne = "";
	
	shared String prezentacia() {
		value song = OpenSongSong();
		song.lyrics =  textPiesne;
		song.presentation = "";
		
		value songProcessor = OpenSongSongProcessor(OpenSongPresentationComputer(),OpenSongCleanerLog());
		songProcessor.computeAndReplacePresentation(song);
		
		return song.presentation;
	}
}

shared class NaplneniePrezentacie() {
	registerConverters();
	
	shared variable String? staraHodnota = "";
	shared variable String vypocitanaHodnota = "";
	
	variable OpenSongCleanerLog log = OpenSongCleanerLog();

	
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
	
	shared String nazovSuboru() {
		value songFilenameProcessor = SongFilenameProcessor();
		return songFilenameProcessor.createSongFilename(nazov,cislo);
	}
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