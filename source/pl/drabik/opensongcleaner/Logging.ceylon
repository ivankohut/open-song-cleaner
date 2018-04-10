shared abstract class LogLevel(shared String code)
		of info | warning {}

object info extends LogLevel("INFO") {}
object warning extends LogLevel("WARN") {}


shared interface Logger {
	shared formal void log(LogLevel logLevel, String message);
}

shared class CliLogger() satisfies Logger {
	shared actual void log(LogLevel logLevel, String message) {
		print("``logLevel.code``: ``message``");
	}
}

shared class LoggingPresentationListener(Named subject, Logger logger) satisfies ContentChangeListener & RenamingListener {
	shared actual void onDifferent() {
		logger.log(warning, "``subject.name`` - Prezentácia sa nezhoduje!");
	}

	shared actual void onNew() {
		logger.log(info, "``subject.name`` - Prezentácia bola nastavená.");
	}

	shared actual void onSame() {}

	shared actual void onRename(String newName) {
		logger.log(info, "``subject.name`` - súbor piesne premenovaný na '``newName``'.");
	}
}