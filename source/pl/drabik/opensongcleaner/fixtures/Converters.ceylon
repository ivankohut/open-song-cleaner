import ceylon.interop.java {
	javaClass
}
import ceylon.language {
	CString=String
}

import fitnesse.slim {
	Converter
}
import fitnesse.slim.converters {
	ConverterRegistry
}

class CeylonStringConverter() satisfies Converter<CString> {
	shared actual CString? fromString(String? javaString) => javaString;
	shared actual String? toString(CString? ceylonString) => ceylonString;
}

void registerConverters() {
	ConverterRegistry.addConverter(
		javaClass<CString>(), 
		CeylonStringConverter()
	);
}