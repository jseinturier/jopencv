package org.opencv;

import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.core.Point3;

/**
 * A class that enable to check OpenCV binary libraries load.
 * @author Julien Seinturier, JOrigin, http://www.github.com/jorigin
 */
public class OpenCVNativesCheck {
	
  /**
	* The main method. 
	* @param args the main method arguments.
	*/
  public static void main(String[] args) {
	
	System.out.println("Checking OpenCV native");
	System.out.println("            OS: "+System.getProperty("os.name"));
	System.out.println("  Architecture: "+System.getProperty("os.arch"));
	System.out.println("      Temp dir: "+System.getProperty("java.io.tmpdir"));

	boolean available = OpenCVNatives.isAvailable();

	if (available) {
		System.out.println();
		System.out.println("Testing OpenCV objects native binding");
		
		boolean test = true;
		
		try {
			String version = Core.VERSION;
			System.out.println("  OpenCV Version: "+version);
		} catch (Throwable  t) {
			System.err.println("  Cannot determine OpenCV version: "+t.getMessage());
			t.printStackTrace(System.err);
			test = false;
		}
		
		try {
			new Mat();
			System.out.println("  OpenCV Mat    [OK]");
		} catch (Throwable  t) {
			System.err.println("  Cannot instanciate OpenCV Mat: "+t.getMessage());
			t.printStackTrace(System.err);
			test = false;
		}
		
		try {
			new Point();
			System.out.println("  OpenCV Point  [OK]");
		} catch (Throwable  t) {
			System.err.println("  Cannot instanciate OpenCV Mat: "+t.getMessage());
			t.printStackTrace(System.err);
			test = false;
		}
		
		try {
			new Point3();
			System.out.println("  OpenCV Point3 [OK]");
		} catch (Throwable  t) {
			System.err.println("  Cannot instanciate OpenCV Mat: "+t.getMessage());
			t.printStackTrace(System.err);
			test = false;
		}
		
		System.out.println();
		System.out.println(test?"OpenCV native implementation is available.":"OpenCV native implementation is not available.");
	} else {
		System.out.println("OpenCV native implementation is not available.");
	}
  }
}
