"The best OpenSongCleaner module"
by("Peter Drabik and Ivan Kohut")
license("http://www.apache.org/licenses/LICENSE-2.0")
native("jvm")
module pl.drabik.opensongcleaner "1.0.0" {
	import javax.xml "8";
	import javax.jaxws "8";
	import java.base "8";
	import ceylon.test "1.2.1";
	shared import ceylon.file "1.2.1";
	import ceylon.interop.java "1.2.1";
	//import "org.apache.commons:commons-lang3" "3.3.2";
	import "commons-io:commons-io" "2.4";
	import "org.fitnesse:fitnesse" "20150814";
}
