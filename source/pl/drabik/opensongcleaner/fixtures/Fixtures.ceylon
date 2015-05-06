import pl.drabik.opensongcleaner {
	OpenSongSongProcessor,
	OpenSongPresentationComputer,
	ConstantPresentationComputer,
	createOpenSongSong,
	SongFilenameProcessor,
	OpenSongCleaner,
	OpenSongCleanerLog,
	FilenamePicker,
	FilenamePickerTest
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
import ceylon.file {
	Directory
}


shared class SpustenieVSystemeSAdresarovouStrukturou(String path) {
	
	String[] ceylonList(JArrayList<JString> jArrayList) {
		variable ArrayList<JString> arrayList = ArrayList<JString>();
		
		Iterator<JString> iterator = jArrayList.iterator();
		while (iterator.hasNext()) {
			arrayList.add(iterator.next());
		}
		
		return [for (jString in arrayList) "``jString``"];
	}
	
	shared variable JArrayList<JString> argumenty = JArrayList<JString>();

	shared String sprava() {
		//TODO: prva sprava v logu
		String[] argumentyList = ceylonList(argumenty);
		//TODO: simplify by using CeylonList (Cmd-shift-T)

		try {
			value log = OpenSongCleanerLog();
			value openSongCleaner = OpenSongCleaner(argumentyList,log);	
			return openSongCleaner.log.lastMessage();
		} catch (Exception e) {
			return "chyba[``e.message``]";
		}
		//TODO: use existingDirectory instead of a particular one
	}
}

shared class VyberSuborovNaSpracovanie() {
	
	shared variable String nazovSuboru = "";
	value filenamePickerTest = FilenamePickerTest();
		
	class FilenameAndDirSetter(shared variable Directory dir, shared variable String filename){
		//if filename is in form subdir/file then dir and filename are updated
		
		value filenameSplit = filename.split(
			(char) => {'/'}.contains(char)
		);
		if (filenameSplit.size>1) {
			value filenameSplitSeq = filenameSplit.sequence();
			
			assert(is String subdirString = filenameSplitSeq[0]);
			dir = filenamePickerTest.createSubdirectory(dir, subdirString);
			
			assert(is String filenameParsed = filenameSplitSeq[1]);
			filename = filenameParsed;
		}		
	}
	
	shared Boolean vybranyNaSpracovanie() {
		
		variable Directory testDir = filenamePickerTest.returnTestDir();
		value filenameAndDirSetter = FilenameAndDirSetter(testDir, nazovSuboru);
		
		value filename = filenameAndDirSetter.filename;
		value realDir = filenameAndDirSetter.dir;
		
		value file = filenamePickerTest.createFile(realDir,filename);

		value filenamePicker = FilenamePicker(testDir);
		value filenamePicked = filenamePickerTest.checkThatFilenameIsPicked(filenamePicker,filename);
		file.delete();
		if (!realDir==testDir) {realDir.delete();}

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