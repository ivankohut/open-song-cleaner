import java.lang {
	Types {
		nativeString
	}
}
import java.text {
	Normalizer
}

class AccentsLess({Character*} input) satisfies {Character*} {
	shared actual Iterator<Character> iterator() {
		value normalizedString = Normalizer.normalize(nativeString(String(input)), Normalizer.Form.\iNFD);
		return nativeString(normalizedString).replaceAll("[^\\p{ASCII}]", "").iterator();
	}
}

class LeftPadded(Object obj, Integer size, Character character) satisfies {Character*} {
	shared actual Iterator<Character> iterator() => obj.string.padLeading(size, character).iterator();
}