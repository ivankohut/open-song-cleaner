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
	shared void leftPadsGivenObjectStringRepresentation() {
		// exercise
		value sut = LeftPadded("AB", 4, 'x');
		// verify
		assertIterable(sut).containsExactly("xxAB");
	}
}
