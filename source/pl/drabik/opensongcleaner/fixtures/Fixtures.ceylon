import pl.drabik.opensongcleaner {
	createSongFilename,
	PartCodes,
	Presentation
}
shared class VypocetPrezentacie() {
	
	shared variable String textPiesne = "";
	
	shared String prezentacia() {
		value partCodes = PartCodes(textPiesne);
		value presentation = Presentation(partCodes);
		return presentation.computePresentation();
		//TODO simplify
	}
}

shared class NaplneniePrezentacie() {
	shared variable String staraHodnota = "";
	shared variable String vypocitanaHodnota = "";
	
	shared String novaHodnota() {
		return "TODO";
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
		return createSongFilename(nazov,cislo);
	}
}