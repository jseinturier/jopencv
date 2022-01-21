# Distibrution upgrade
In order to upgrade a distribution to OpenCV X.Y.Z the following actions are required:

## 1. Update OpenCV build scripts
The scripts have to be edited to integrate new version.

Within the file ``scripts/build_opencv_java.sh``, update the variables ``opencvtag`` and ``opencvcontribtag`` respectively to ``opencvtag="X.Y.Z"`` and ``opencvcontribtag="X.Y.Z"``

Within the files ``scripts\build_opencv_java-x32.bat`` and ``scripts\build_opencv_java-x64.bat``, update the variables ``opencvtag`` and ``opencvcontribtag`` respectively to ``opencvtag="X.Y.Z"`` and ``opencvcontribtag="X.Y.Z"``

## 2. Build OpenCV native java wrappers
OpenCV native java wrappers can be build using the scripts that are available within the ``scripts`` directory. At this time, 4 platforms are supported:
 - Windows x86_32 (``build_opencv_java-x32.bat``)
 - Windows x86_64 (``build_opencv_java-x64.bat``)
 - Linux  x86_64 / AMD64 (``build_opencv_java.sh``)
 - Linux  ARM64 (``build_opencv_java.sh``)

Running adapted script on the specific platform will provide two files: the OpenCV Java Wrapper and the OpenCV native library.

The directory where the build script has been run is called ``<BUILD_DIR>``

## 3. OpenCV native libraries integration
Each platform build will produce a native library that has to be copied to their specific location within the ``resource`` folder:
 - From Windows x86_32 build, copy ``<BUILD_DIR>\install\opencv\java\opencv_java453.dll`` within ``src/main/resources/windows/x86`` folder
 - From Windows x86_64 build, copy ``<BUILD_DIR>\install\opencv\java\opencv_java453.dll`` within ``src/main/resources/windows/x64`` folder
 - from Linux x86_64 / AMD64 build, copy ``<BUILD_DIR>/install/opencv/share/java/opencvX/libopencv_java-XYZ.so`` within ``src/main/resources/linux/x64`` folder
 - from Linux ARM64 build, copy ``<BUILD_DIR>/install/opencv/share/java/opencvX/libopencv_java-XYZ.so`` within ``src/main/resources/linux/aarch64`` folder

## 4. OpenCV Java wrapper JAR integration
Each platform build will produce a JAR that contains OpenCV / Java wrappers. The JAR location is as follows:
 - Windows x86_32 (``<BUILD_DIR>\install\opencv\java\opencv-XYZ.jar``)
 - Linux  x86_64 / AMD64 (``<BUILD_DIR>/install\opencv/share/java/opencvX/opencv-XYZ.jar``)
 
The produces JAR is the same for all platforms.
 
Integrating the ``opencv-XYZ.jar`` requires the following actions:
 
 - Copy the ``opencv-XYZ.jar`` from a platform build to ``repository/org/opencv/opencv/X.Y.Z/opencv-X.Y.Z.jar``
 - Create a file ``opencv-X.Y.Z.pom`` within the ``repository/org/opencv/opencv/X.Y.Z`` folder
 - Set the content of the ``opencv-X.Y.Z.pom`` with: 
 ```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.opencv</groupId>
  <artifactId>opencv</artifactId>
  <version>X.Y.Z</version>
  <packaging>jar</packaging>

  <name>OpenCV</name>
  <description>OpenCV java implementation</description>
  <url>http://www.opencv.org</url>

  <licenses>
    <license>
      <name>The GNU Lesser General Public License, Version 3.0</name>
      <url>http://www.gnu.org/licenses/lgpl-3.0.txt</url>
      <distribution>repo</distribution>
    </license>
  </licenses>

</project>
```

Optionnaly, the JAR and POM files can be signed using [SHA1](https://emn178.github.io/online-tools/sha1_checksum.html) and [MD5](https://emn178.github.io/online-tools/sha1_checksum.html) (signature files have to be added to the ``repository/org/opencv/opencv/X.Y.Z`` folder). 
Signature files has the same name as the original file appended with the checksum extension. For example, MD5 checksum of the ``opencv-X.Y.Z.pom`` as to be named ``opencv-X.Y.Z.pom.md5``.

## 5. Update OpenCV natives java sources
The file ``src/main/java/org/opencv/OpenCVNatives.java`` has to be updated by:

- Setting the variable ``dllName`` such as ```private static String dllName  = "opencv_javaXYZ.dll";```
- Setting the variable ``soName`` such as ```private static String soName   = "libopencv_javaXYZ.so";```

## 6. Update OpenCV natives POM file
The file ``pom.xml`` has to be updated by:

- Setting the project ``version`` to ```<version>X.Y.Z</version>```
- Within the ``dependencies`` section, setting the opencv dependency ``version`` to ```<version>X.Y.Z</version>```

## 7. Build the new release
The new release is build by entering the following commands:

- mvn clean
- mvn install



