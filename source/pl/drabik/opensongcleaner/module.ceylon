"The best OpenSongCleaner module"
by("Peter Drabik and Ivan Kohut")
license("http://www.apache.org/licenses/LICENSE-2.0")
native("jvm")
module pl.drabik.opensongcleaner "1.0.0" {
	import javax.xml "8";
	import javax.jaxws "8";
	import java.base "8";
	import ceylon.test "1.2.0";
	shared import ceylon.file "1.2.0";
	import ceylon.interop.java "1.2.0";
	import "org.apache.commons:commons-lang3" "3.3.2";
	import "org.fitnesse:fitnesse" "20150814";
}
