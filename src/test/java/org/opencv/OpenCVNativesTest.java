package org.opencv;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.core.Point3;

/**
 * A class that enable to test OpenCV binary libraries load.
 * @author Julien Seinturier, JOrigin, http://www.github.com/jorigin
 */
public class OpenCVNativesTest {
	
    
  /**
   * Initialize the tests.
   */
  @BeforeAll
  public static void initClass() {
      
      boolean available = OpenCVNatives.isAvailable();
      
      if (! available){
	    fail("OpenCV natives libraries are not available.");
      } else {
        try {
			String version = Core.VERSION;
			System.out.println("OpenCV Version: "+version);
	        System.out.println("            OS: "+System.getProperty("os.name"));
	        System.out.println("  Architecture: "+System.getProperty("os.arch"));
	        System.out.println("      Temp dir: "+System.getProperty("java.io.tmpdir"));
		} catch (Throwable  t) {
			System.err.println("  Cannot determine OpenCV version: "+t.getMessage());
			t.printStackTrace(System.err);
			available = false;
            fail("Cannot determine OpenCV version.");
		}
      }
  }
    
    
  @Test
  public void openCVMatAvailabilityTest(){
      try {
			Mat m = new Mat();
            assertNotNull(m, "Cannot instantiate Mat object.");
		} catch (Throwable  t) {
			fail("Cannot instanciate OpenCV Mat: "+t.getMessage());
		}
  }
   
  @Test
  public void openCVPointAvailabilityTest(){
      try {
			Point p = new Point();
            assertNotNull(p, "Cannot instantiate Point object.");
		} catch (Throwable  t) {
			fail("Cannot instanciate OpenCV Point: "+t.getMessage());
		}
  }
 
  @Test
  public void openCVPoint3AvailabilityTest(){
      try {
			Point3 p = new Point3();
            assertNotNull(p, "Cannot instantiate Point3 object.");
		} catch (Throwable  t) {
			fail("Cannot instanciate OpenCV Point3: "+t.getMessage());
		}
  }
}
