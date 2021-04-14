package org.opencv;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.invoke.MethodHandles;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * This class provide embedded OpenCV wrappers for Windows, Linux on x32, x64 and ARM architectures.<br><br>
 * By default, this class detect the current system and load the appropriated native library. 
 * It is also possible to indicates a specific OpenCV native library by setting the <code>org.opencv.natives</code> system property to point a specific file.
 * 
 * @author Julien Seinturier, JOrigin, http://www.github.com/jorigin
 * @version 4.4.0
 */
public class OpenCVNatives {

	/**
	 * The name of the property that enables to specify external OpenCV native library.
	 */
	public static final String OPENCV_NATIVES_PROPERTY_NAME = "org.opencv.natives";
	
	private static boolean available = false;

	private static String dllName  = "opencv_java451.dll";
	private static String soName   = "libopencv_java451.so";

	{init();}

	private static void init(){

		Logger log = Logger.getLogger(MethodHandles.lookup().lookupClass().getName());
		
		// Check if the natives libraries path is explicitely given
		String nativeLibrariesPath = System.getProperty(OPENCV_NATIVES_PROPERTY_NAME);
		
		String osArch    = System.getProperty("os.arch");    // Operating system architecture
		String osName    = System.getProperty("os.name");    // Operating system name
		
		if (nativeLibrariesPath != null) {
			
			log.log(Level.INFO, "Using OpenCV natives at "+nativeLibrariesPath+" (from "+OPENCV_NATIVES_PROPERTY_NAME+" property).");
			
			File f = new File(nativeLibrariesPath);
			
			if (f.canRead()) {

				try {
					System.load(f.getAbsolutePath());
					log.log(Level.CONFIG, "Loaded "+nativeLibrariesPath+" library");
					available = true;
				} catch (Error e) {
					log.log(Level.SEVERE, "Cannot load OpenCV library from "+nativeLibrariesPath+": "+e.getMessage(), e);
					available = false;
				} catch (Exception e) {
					log.log(Level.SEVERE, "Cannot load OpenCV library from "+nativeLibrariesPath+": "+e.getMessage(), e);
					available = false;
				}
				
			} else {
				log.log(Level.INFO, "Cannot read file \""+nativeLibrariesPath+"\".");
			}
			
		} else {

			String nativeLibraryResource = null;

			String library = null;
			
			
			
			if (osName != null){
				if (osName.toUpperCase().contains("WINDOWS")){
					nativeLibraryResource = "/windows";

					if (osArch != null){

						if (osArch.toUpperCase().contains("64")){

							library = dllName;
							
							nativeLibraryResource += "/x64/"+library;

						} else if (osArch.toUpperCase().contains("86")){

							library = dllName;
							nativeLibraryResource += "/x32/"+library;

						} else {
							log.log(Level.WARNING, "Cannot load OpenCV libraries (unknonwn system architecture "+osArch);
							available = false;
							return;
						}

					} 

				} else  if (osName.toUpperCase().indexOf("NIS") >= 0 || osName.toUpperCase().indexOf("NUX") >= 0 || osName.toUpperCase().indexOf("AIX") > 0 ) {

					nativeLibraryResource = "/linux";

					if (osArch != null){
						if (osArch.toUpperCase().contains("AMD64")){
							library = soName;
							nativeLibraryResource += "/x64/"+library;

						} else if (osArch.toUpperCase().contains("X86")){
							library = soName;
							nativeLibraryResource += "/x86/"+library;
						} else if (osArch.toUpperCase().contains("AARCH64")){
							library = soName;
							nativeLibraryResource += "/aarch64/"+library;
						}
					} else {
						log.log(Level.WARNING, "Cannot load OpenCV libraries (no system architecture os.arch available");
						available = false;
						return;
					}
				} else {
					log.log(Level.WARNING, "Cannot load OpenCV libraries (no system architecture os.arch available");
					available = false;
					return;
				} 
			} else {
				log.log(Level.WARNING, "Cannot load OpenCV libraries os \""+osName+"\" is not supported.");
				available = false;
				return;
			}


			if (nativeLibraryResource != null) {
				InputStream inputStream = OpenCVNatives.class.getResourceAsStream(nativeLibraryResource);

				OutputStream output = null;

				if (inputStream != null) {

					//Copy the dll to the tmp folder
					String tmpLibraryPath = System.getProperty("java.io.tmpdir")+File.separator+library;

					try{

						output = new BufferedOutputStream(new FileOutputStream(tmpLibraryPath));

						byte[] buffer = new byte[1024];
						int lengthRead;
						while ((lengthRead = inputStream.read(buffer)) > 0) {
							output.write(buffer, 0, lengthRead);
							output.flush();
						}

					} catch(Exception e) {
						log.log(Level.SEVERE, "Cannot extract OpenCV resource library "+nativeLibraryResource+" to "+tmpLibraryPath);
						log.log(Level.SEVERE, e.getMessage(), e);	
					} finally {

						try {
							if (inputStream != null) {
								inputStream.close();
							}

							if (output != null) {
								output.close();
							}
						} catch (IOException e) {
							log.log(Level.WARNING, "Resource closing error.");
						}
					}



					try {

						System.load(tmpLibraryPath);
						log.log(Level.CONFIG, "Loaded "+tmpLibraryPath+" library");
						available = true;
					} catch (Error e) {
						log.log(Level.SEVERE, "Cannot load OpenCV library from "+tmpLibraryPath+": "+e.getMessage(), e);
						available = false;
					} catch (Exception e) {
						log.log(Level.SEVERE, "Cannot load OpenCV library from "+tmpLibraryPath+": "+e.getMessage(), e);
						available = false;
					}

				} else {
					log.log(Level.SEVERE, "Cannot extract OpenCV library from "+nativeLibraryResource);
					available = false;
				}
			}
		}
	}

	/**
	 * Check if the openCV native library is available and accessible from Java.
	 * @return <code>true</code> if OpenCV native bindings is available for this system and <code>false</code> otherwise
	 */
	public static boolean isAvailable(){
		if (!available){
			init();
		}

		return available;
	}

}
