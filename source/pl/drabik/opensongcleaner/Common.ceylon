shared interface Named {
	shared formal String name;
}

shared interface Provider<out Element> {
	shared formal Element get();
}

shared interface Mapping<in Source, out Target> {
	shared formal Target map(Source source);
}

class SingleCache<out T>(Provider<T> provider) satisfies Provider<T> {
	late value element = provider.get();
	shared actual T get() => element;
}

class ChainedIterables<out Element>({Element*}* iterables) satisfies {Element*} {
	shared actual Iterator<Element> iterator() => iterables
		.fold<{Element*}>({})((result, iterable) => result.chain(iterable))
		.iterator();
}

class Mapped<in S, out T>({S*} elements, T(S) transformation) satisfies Iterable<T>
		given S satisfies Object
		given T satisfies Object {
	shared actual Iterator<T> iterator() => elements.map(transformation).iterator();
}

class JoinedText<out Element>(String delimiter, {Element*} parts) satisfies {Character*} given Element satisfies Object {
	shared actual String string {
		return delimiter.join(parts);
	}

	shared actual Iterator<Character> iterator() => string.iterator();
}