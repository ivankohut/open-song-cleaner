import pl.drabik.opensongcleaner {
	OpenSongSongProcessor,
	OpenSongPresentationComputer,
	ConstantPresentationComputer,
	createOpenSongSong,
	SongFilenameProcessor,
	OpenSongCleaner,
	OpenSongCleanerLog
}

import pl.drabik.opensongcleaner.opensong {
	OpenSongSong
}

import java.util {
	JList = List,
	JArrayList = ArrayList,
	Iterator
}

import ceylon.collection {
	ArrayList
}

import java.lang {
	JString = String
}


shared class SpustenieVSystemeSAdresarovouStrukturou(String path) {
	
	String[] ceylonList(JArrayList<JString> jArrayList) {
		variable ArrayList<JString> arrayList = ArrayList<JString>();
		
		Iterator<JString> iterator = jArrayList.iterator();
		while (iterator.hasNext()) {
			arrayList.add(iterator.next());
		}
		
		String[] list = [ for (jString in arrayList) "``jString``"];

		return list;
	}
	
	shared variable JArrayList<JString> argumenty = JArrayList<JString>();

	shared String sprava() {
		value openSongCleaner = OpenSongCleaner();	
		
		String[] argumentyList = ceylonList(argumenty);
		
		openSongCleaner.run(argumentyList);
		return openSongCleaner.lastLogMessage();
	}
}

shared class VyberSuborovNaSpracovanie() {
	
	shared variable String nazovSuboru = "";
	
	shared Boolean vybranyNaSpracovanie() {
		return true;
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
	shared variable String premenovany = "";
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