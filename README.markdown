SCLogger
========

SCLogger is a debugging console created by developer for developers, easy integration with your project.

**Supported iPhone and iPad**

**Supported Landscape and Portrait**

![SCLogger](http://www.lucascorrea.com/images/SCLoggerDemo1.gif)
![SCLogger2](http://www.lucascorrea.com/images/SCLoggerDemo2.gif)


Getting Started
=================
Just drag the two classes into your project. Also you need to import MessageUI framework. Go to frameworks-> add existing framework-> MessageUI.framework

Added the import in your project file YourProject-Prefix.pch

    #import "SCLogger.h"

**or**

Using [CocoaPods](http://cocoapods.org) to get start, you can add following line to your Podfile:

    pod 'SCLogger'

Add in what settings you want the log is active in your Podfile.
For example Debug or Release.

    post_install do |installer|
          installer.pods_project.targets.each do |target|
              target.build_configurations.each do |config|
                  if config.name == 'Debug'
                      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=1', 'SCLOGGER_DEBUG=1']
                  end
              end
          end
      end


Added the import in your project file YourProject-Prefix.pch

    #import <SCLogger/SCLogger.h>

If **Xcode 6 or higher** is required to create a PCH file, add the path of the PCH in the bundle settings and allow `Precompile Prefix Header = YES`

Create File PCH
![SCLogger](http://www.lucascorrea.com/images/sclogger_create_pch.png)

Build Settings Prefix Header
![SCLogger](http://www.lucascorrea.com/images/sclogger_prefix_header_config.png)

Example Usage
=============

To use the component is very easy, if your project has already added the import on PCH, just **three-finger long press** on debug or call the method

    [SCLogger showDebug];

For all **NSLog** or **NSLogv** used in the project will be recorded in SCLogger also is recorded in a log file.
In the debug screen it is possible to send the log via email with the gesture.

    tapReconEmail.numberOfTapsRequired = 1;
    tapReconEmail.numberOfTouchesRequired = 2;


License
=============

SCLogger is licensed under the MIT License:

Copyright (c) 2011-2016 Lucas Correa (http://www.lucascorrea.com/)

Permission is hereby-granted, free of charge, to any person Obtaining a copy of this software and Associated documentation files (the "Software"), to deal in the Software without restriction, including without Limitation the rights to use, copy, modify, merge , publish, distribute, sublicense, and / or sell copies of the Software, and to permit persons to Whom the Software is furnished to the so, subject to the Following conditions:

The above copyright notice and this permission notice Shall be included in all copies or Substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE Warranties OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE Liable FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, Whether IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, Arising FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR THE OTHER IN Dealings SOFTWARE.
