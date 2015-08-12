import ceylon.file {
	File
}
shared interface SongsRepository {
	shared formal {Song*} getSongs(String path);
}

shared interface Song {
	shared formal void clean();
}

shared class OpenSongCleaner2(SongsRepository songs) {
	shared void cleanSongs(String path) {
		songs.getSongs(path).each((song) => song.clean());
	}
}

shared interface SongFileSystem {
	shared formal {File*} getFiles(String path);
}

shared class SongFile(File file) satisfies Song {
	shared actual void clean() {
		
	}
}

shared class FileSystemSongsRepository(SongFileSystem fs) satisfies SongsRepository {
	shared actual {Song*} getSongs(String path) {
		return fs.getFiles(path).map((file) => SongFile(file));
	}
}