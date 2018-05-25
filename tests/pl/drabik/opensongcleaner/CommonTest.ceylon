import ceylon.test {
	test,
	assertEquals
}

import java.lang {
	Types
}

import org.mockito {
	Mockito {
		verify,
		when,
		mock
	}
}

class CommonTest() {

	test
	shared void containsItemsOfGivenIterablesInOrder() {
		// exercise
		value sut = ChainedIterables("a", "bc", "def");
		// verify
		assertIterable(sut).containsExactly("abcdef");
	}

	test
	shared void cachesProvidedValue() {
		value provider = when(mock(Types.classForType<Provider<String>>()).get()).thenReturn("value").getMock<Provider<String>>();
		value sut = SingleCache<String>(provider);
		// exercise
		sut.get();
		sut.get();
		sut.get();
		// verify
		verify(provider).get();
	}

	test
	shared void joinedText() {
		// exercise
		value sut = JoinedText(";", {"a", "b", "c"});
		// verify
		assertEquals("a;b;c", sut.string);
	}
}