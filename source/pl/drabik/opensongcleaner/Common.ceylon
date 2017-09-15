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
	variable T? cached = null;
	shared actual T get() => cached else (cached = provider.get());
	// compiler backend error:
	//late value element = provider.get();
	//shared actual T get() => element;
}

class ChainedIterables<out Element>({Element*}* iterables) satisfies {Element*} {
	shared actual Iterator<Element> iterator() => iterables
			.fold<{Element*}>({})((result, iterable) => result.chain(iterable))
			.iterator();
}
