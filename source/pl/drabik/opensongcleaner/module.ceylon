"The best OpenSongCleaner module"
by("Peter Drabik and Ivan Kohut")
license("http://www.apache.org/licenses/LICENSE-2.0")
native("jvm")
module pl.drabik.opensongcleaner "1.0.0" {
	import javax.xml "8";
	import javax.jaxws "8";
	shared import java.base "8";
	shared import ceylon.test "1.3.3.1";
	//shared import com.athaydes.specks "0.7.1";
	shared import ceylon.file "1.3.3";
	import ceylon.interop.java "1.3.3";
	//import "org.apache.commons:commons-lang3" "3.3.2";
	import maven:"commons-io:commons-io" "2.4";
	import maven:"org.fitnesse:fitnesse" "20160618";
	import maven:"org.mockito:mockito-core" "2.16.0";
}
