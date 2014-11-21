shared class VypocetPrezentacie() {
	
	shared variable String textPiesne = "";
	
	shared String prezentacia() {
		return "TODO";
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
		return "TODO";
	}
}