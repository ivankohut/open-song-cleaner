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
