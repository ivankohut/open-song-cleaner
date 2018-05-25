import ceylon.file {
	File,
	Directory,
	parsePath,
	Nil
}
import java.io {
	JFile=File
}
import org.apache.commons.io {
	FileUtils
}
import java.nio.charset {
	Charset
}

shared interface FileOnPath satisfies Named {
	shared formal String path;
}

shared class FileMyFile(File file) satisfies FileOnPath {
	shared actual String name => file.name;
	shared actual String path => file.path.string;
}


class DirectoryOfFiles({Character*} path) satisfies Iterable<File> {
	Directory fsDirectory() {
		if (is Directory dir = parsePath(String(path)).resource) {
			return dir;
		} else {
			throw Exception("Adresár '``path``' neexistuje.");
		}
	}

	shared actual Iterator<File> iterator() => fsDirectory().files()
			.sort((File x, File y) => x.name.compare(y.name)).iterator();
}

class FileNameCorrecting(RenameableFile file, {Character*} newName) satisfies Cleanable {
	shared actual void clean() {
		file.rename(newName);
	}
}

class RenameableFile(FileOnPath file, RenamingListener listener) {
	shared void rename({Character*} newName) {
		value newFilenameString = String(newName);
		if (newFilenameString != file.name) {
			value filePath = parsePath(file.path);
			value newPath = filePath.siblingPath(newFilenameString);
			if (is Nil loc = newPath.resource) {
				if (is File r = filePath.resource) {
					r.move(loc);
					listener.onRename(newFilenameString);
				} else {
					throw Exception("'``file.name``' nie je súbor.");
				}
			} else {
				throw Exception("Súbor '``file.name``' nemôže byť premenovaný na '``newFilenameString``'. Cieľový súbor už existuje.");
			}
		}
	}
}


shared interface NamedText satisfies Named {
	shared formal String content();
	shared formal void replaceContent(String newContent);
}

shared class TextFile(FileOnPath file, Charset charset) satisfies NamedText {
	value javaFile = JFile(file.path);

	shared actual String name => javaFile.name;

	shared actual String content() {
		return FileUtils.readFileToString(javaFile, charset.name());
	}

	shared actual void replaceContent(String newContent) {
		FileUtils.writeStringToFile(javaFile, newContent, charset.name());
	}
}