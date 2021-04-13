package org.opencv;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * A class that enable to check OpenCV binary libraries load.
 * @author Julien Seinturier
 */
public class OpenCVNativesCheck {
	
  public static void main(String[] args) {
	
	Logger logger = Logger.getLogger(OpenCVNatives.class.getName());
	logger.setLevel(Level.ALL);
	
	logger.info("Checking OpenCV native");
	logger.info("            OS: "+System.getProperty("os.name"));
	logger.info("  Architecture: "+System.getProperty("os.arch"));
	logger.info("      Temp dir: "+System.getProperty("java.io.tmpdir"));

	boolean available = OpenCVNatives.isAvailable();
	
	logger.info(available?"OpenCV native implementation is available.":"OpenCV native implementation is not available.");
  }
}
