import javax.xml.bind {
	Marshaller,
	JAXBContext,
	Unmarshaller,
	Validator
}

class LazyJaxbContext({Character*} packageName) extends JAXBContext() {

	late value context = JAXBContext.newInstance(String(packageName));

	shared actual Marshaller createMarshaller() => context.createMarshaller();

	shared actual Unmarshaller createUnmarshaller() => context.createUnmarshaller();

	shared actual Validator createValidator() => context.createValidator();
}