# OpenCV Java multiplatform wrapper
This library enable to use OpenCV capabilities from a single jar on various systems (Windows, Linux) on various architectures (x86_32, x86_64, ARM)

## 1. Integration within Maven project
To import the library just add the following dependency to your maven project:
```xml

<!-- JOrigin repository -->      
<repository>
   <id>jorigin</id>
  <name>jorigin-maven</name>
  <url>http://www.seinturier.fr/maven</url>
</repository>

<!-- The OpenCV Java  -->
<dependency>
  <groupId>org.opencv</groupId>
  <artifactId>opencv-natives</artifactId>
  <version>4.4.0</version>
</dependency>
```

## 2. Usage
Integrate the jar to your project and make a call to ``OpenCVNatives.isAvailable()`` to check if the OpenCV native wrapping is enabled.

It is possible to specify a system library to use as OpenCV native by setting the Java system property ``org.opencv.natives`` to toint the library file you want to use.

## 3. Building
If you prefer to build the library, following steps are required:

### 3.1. Build standard OpenCV with Java wrappers
The ``scripts`` directory contains preconfigured scripts that enable to generate OpenCV java wrappers. When the wrappers are generated, the libraries have to be copied within the appropriate directory under ``src/main/resources``.

### 3.2. Build opencv natives
From the main directory:
```batch
make clean
make install
```
