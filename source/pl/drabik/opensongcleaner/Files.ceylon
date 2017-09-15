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

shared interface MyFile satisfies Named {
	shared formal String path;
	shared actual default String name => parsePath(path).normalizedPath.elementPaths.last?.string else "";
}

shared class FileMyFile(File file) satisfies MyFile {
	shared actual String name => file.name;
	shared actual String path => file.path.string;
}

class DirectoryOfFiles(MyFile directory) satisfies Iterable<MyFile> {

	Directory fsDirectory() {
		if (is Directory dir = parsePath(directory.path).resource) {
			return dir;
		} else {
			throw Exception("Adresár '``directory.path``' neexistuje.");
		}
	}

	shared actual Iterator<MyFile> iterator() => fsDirectory().files()
			.sort((File x, File y) => x.name.compare(y.name))
			.map((file) => FileMyFile(file)).iterator();
}


class FileNameCorrecting(MyFile file, {Character*} newName, RenamingListener listener) satisfies Cleanable {
	shared actual void clean() {
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


shared interface TextFile satisfies Named {
	shared formal String content();
	shared formal void replaceContent(String newContent);
}

class UTF8TextFile(MyFile myFile) satisfies TextFile {
	value fileEncoding = "UTF-8";
	value file = JFile(myFile.path);

	shared actual String name => file.name;

	shared actual String content() {
		return FileUtils.readFileToString(file, fileEncoding);
	}

	shared actual void replaceContent(String newContent) {
		FileUtils.writeStringToFile(file, newContent, fileEncoding);
	}
}