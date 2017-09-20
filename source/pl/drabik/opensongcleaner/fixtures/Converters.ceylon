import ceylon.language {
	CString=String
}

import fitnesse.slim {
	Converter
}
import fitnesse.slim.converters {
	ConverterRegistry
}

import java.lang {
	Types
}

class CeylonStringConverter() satisfies Converter<CString> {
	shared actual CString? fromString(String? javaString) => javaString;
	shared actual String? toString(CString? ceylonString) => ceylonString;
}

void registerConverters() {
	ConverterRegistry.addConverter(
		Types.classForType<CString>(), 
		CeylonStringConverter()
	);
}