import ceylon.language.meta.model {
	ClassOrInterface
}
import ceylon.test {
	assertEquals
}

import java.lang {
	Types
}

import org.mockito {
	Mockito
}
shared interface AssertIterable<in Element> {
	///**
	// * Contains each element of given iterable.
	// */
	//shared formal void contains({Element*} iterable);
	/**
	 * Same elements in same order as in given iterable.
	 */
	shared formal void containsExactly({Element*} iterable);
}

class AssertIterableImpl<in Element>({Element*} iterable) satisfies AssertIterable<Element> {
//	shared actual void contains() {}

	shared actual void containsExactly({Element*} expected) {
		assertEquals(iterable.sequence(), expected.sequence());
	}
}

shared AssertIterable<Element> assertIterable<in Element>({Element*} iterable) {
	return AssertIterableImpl(iterable);
}

shared T mock<T>(ClassOrInterface<T> clazz) given T satisfies Object {
	return Mockito.mock(Types.classForType<T>());
}