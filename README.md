secret-archer
=============

You are expected to have a working version of [msys, mingw](http://sourceforge.net/projects/mingw/files/latest/download?source=files), [cmake](http://www.cmake.org/files/v2.8/cmake-2.8.10.2-win32-x86.exe) and [git](https://msysgit.googlecode.com/files/Git-1.8.1.2-preview20130201.exe) installed.

Just click on the links and run the appropriate installers.

Two words of warning that you can find [here](http://www.mingw.org/wiki/Getting_Started) as well:

You must prepend the `bin`-directory of your `mingw`- and `msys`-installation  to your path: If you installed mingw to C:\MinGW, add `C:\MinGW\bin;C:\MinGW\msys\1.0\bin` to your __user__ path (not to your __system__ path).

After the installation, open up the MinGW Shell (Start>All Programs>MinGW>MinGW Shell) and enter `/postinstall/pi.bat`.
Now you should be ready to use mingw from the windows command line as well.



On linux, run `sudo apt-get install cmake git` as you don't need mingw and msys.

Compilers other than `g++` are currently not supported. They may or may not work.

How to install sfml:
--------------------

In a shell with __adminstrative priviledges__, run:
```
$ cd C:\Windows\Temp # any directory
$ git clone git@github.com:LaurentGomila/SFML
$ cd SFML
$ git checkout 2.0
$ cmake -G "MSYS Makefiles"
$ cmake -DSFML_BUILD_DOC=TRUE # Only if doxygen is installed.
$ make install
$ cmake -DSFML_BUILD_TYPE=Debug
$ make install
```
For linux, use the `Unix Makefiles`-generator instead of `MSYS Makefiles`.

You're done! The libraries are located in the `C:\Program Files(x86)\SFML` and `/usr/local/lib` respectively.

