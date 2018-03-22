import ceylon.test {
	test
}

class SongFileNameTest() {

	test
	shared void shouldRemoveAccentsFromString() {
		// exercise
		value sut = AccentsLess("ľščťžýáíéúäôň");
		// verify
		assertIterable(sut).containsExactly("lsctzyaieuaon");
	}

	test
	shared void doesNotContainIgnoredCharacters() {
		// exercise
		value sut = FilteredOut("abcdabcd", "bd");
		// verify
		assertIterable(sut).containsExactly("acac");
	}

	test
	shared void doesNotContainTrailingIgnoredCharacters() {
		// exercise
		value sut = TrimmedTrailing("abxabab", "ba");
		// verify
		assertIterable(sut).containsExactly("abx");
	}

	test
	shared void leftPadsGivenObjectStringRepresentation() {
		// exercise
		value sut = LeftPadded("AB", 4, 'x');
		// verify
		assertIterable(sut).containsExactly("xxAB");
	}
}
