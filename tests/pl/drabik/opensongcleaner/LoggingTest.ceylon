import ceylon.test {
	test,
	parameters
}

import org.mockito {
	Mockito {
		verify,
		verifyZeroInteractions
	}
}

{[Anything(LoggingPresentationListener), LogLevel, String]*} logLevelAndMessages => {
	[(LoggingPresentationListener sut) => sut.onNew(), 					info, 		"Prezentácia bola nastavená."],
	[(LoggingPresentationListener sut) => sut.onDifferent(), 			warning, 	"Prezentácia sa nezhoduje!"],
	[(LoggingPresentationListener sut) => sut.onRename("newFileName"), 	info, 		"súbor piesne premenovaný na 'newFileName'."]
};


class LoggingPresentationListenerTest() {

	test
	parameters(`value logLevelAndMessages`)
	shared void logsMessageToLoggerInLevel(Anything(LoggingPresentationListener) exercise, LogLevel logLevel, String logMessageSuffix) {
		value subject = "name";
		value logger = mock(`Logger`);
		value sut = LoggingPresentationListener(FakeNamed(subject), logger);
		// exercise
		exercise(sut);
		// verify
		verify(logger).log(logLevel, "name - " + logMessageSuffix);
	}

	test
	shared void nothingWhenOnSame() {
		value logger = mock(`Logger`);
		value sut = LoggingPresentationListener(FakeNamed(), logger);
		// exercise
		sut.onSame();
		// verify
		verifyZeroInteractions(logger);
	}
}

shared class FakeNamed(shared actual String name = "nn") satisfies Named {}
