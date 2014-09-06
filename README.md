SCLogger
========

SCLogger is a debugging console created by developer for developers, easy integration with your project.



Getting Started
=================
Just drag the two classes into your project. Also you need to import MessageUI framework. Go to frameworks-> add existing framework-> MessageUI.framework

Added the import in your project file YourProject-Prefix.pch 

#import "SCLogger.h"

or

Using CocoaPods to get start, you can add following line to your Podfile:

	pod 'SCLogger'

Example Usage
=============

To use the component is very easy, if your project has already added the import on PCH, just call the method [SCLogger showDebug]; 

For all **NSLog** used in the project will be recorded in SCLogger also is recorded in a log file. 
In the debug screen it is possible to send the log via email with the gesture. 

	tapReconEmail.numberOfTapsRequired = 2; 
	tapReconEmail.numberOfTouchesRequired = 2;


License
=============

SCLogger is licensed under the MIT License:

Copyright (c) 2014 Lucas Correa (http://www.lucascorrea.com/)

Permission is hereby-granted, free of charge, to any person Obtaining a copy of this software and Associated documentation files (the "Software"), to deal in the Software without restriction, including without Limitation the rights to use, copy, modify, merge , publish, distribute, sublicense, and / or sell copies of the Software, and to permit persons to Whom the Software is furnished to the so, subject to the Following conditions:

The above copyright notice and this permission notice Shall be included in all copies or Substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE Warranties OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE Liable FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, Whether IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, Arising FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR THE OTHER IN Dealings SOFTWARE.
