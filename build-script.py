# requires python3.3

import subprocess
import sys
import shutil
import multiprocessing
from subprocess import call
from functools import reduce

errlog = open('build-script.log', 'w+')

#defaults
DEFAULT_CORE_COUNT = 4

class Settings:
    boost_path = None
    sfml_path = None

settings = Settings

class OS:
    Windows, Linux, NotSupported = range(3)

class OutputColor:
    LIME = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    BLACK = "\033[m"

class Library:
    # true if the library needs to installed, false otherwise.
    needsInstallation = True
    # true if build-dep needs to be installed, false otherwise.
    needBuildDep = True
    # the path where the library is located. Empty if the library should be located in a default path.
    path = ""
    # canonical name of the library
    name = ""
    # name of the package
    pkgname = ""
    # The name variable that has to be set for cmake to find the lib (like BOOST_ROOT for the boost-library).
    cmake_path_variable = ""

# will be a map that maps library names to a Library-objects.
libraries = {}

# will be a map that maps executable names to their path.
executables = {}

# number of CPU-cores
cores = 0

# the machine's operating system.
os = OS.NotSupported

# helpers
def die(msg):
    print(OutputColor.RED+msg)
    sys.stdout.write(OutputColor.BLACK)
    sys.exit(1)


def warn(msg):
    print(OutputColor.YELLOW+msg)
    sys.stdout.write(OutputColor.BLACK)


def good(msg):
    print(OutputColor.LIME+msg)
    sys.stdout.write(OutputColor.BLACK)

def temp_text(text):
    """
    Writes test to stdout. This text will be overwritten by subsequent writes to stdout.
    """
    sys.stdout.write("{}\r".format(text))

# package
def installDeb(packages):
    # empty lists are false
    if not packages:
        return
    print("    Installing build dep dependencies for: {}".format(", ".join(packages)))
    if not locate("apt-get"):
        die("Could not find apt-get. Please install the build-dep manually.")
    #TODO: build-dep it in one step!
    for pkg in packages:
        temp_text("  Installing build dep for: {}...".format(pkg))
        result = call(["apt-get", "build-dep", "-q", "-o" , "APT::Get::Build-Dep-Automatic=true", pkg ,"-y"],
                      stdout=subprocess.DEVNULL)
        if result == 0:
            print("  Installed build dep for: {}!     ".format(pkg))
        else:
            die("   Could not install build dep of {}. Please install manually.".format(pkg))
    
def cmake_configure():
    global cores
    cmake_arguments = []
    make_targets = []
    
    cmake_arguments.append("-DNUM_CORES={}".format(cores))
    
    for lib in libraries.values():
        # Specify the path to the library if it does not need to be installed.
        if not lib.needsInstallation:
            if len(lib.path.strip()) > 0:
                cmake_arguments.append("-D{}={}".format(lib.cmake_path_variable, lib.path))
        else:
            make_targets.append(lib.name)
    for arg in cmake_arguments:
        print(" Running cmake {}".format(arg))
        result = call(["cmake", arg], stdout=subprocess.DEVNULL, stderr=errlog)
        if result != 0:
            die("Could not run cmake. Please run cmake manually. Use the following arguments: {}".format(cmake_arguments))

    print(" Project was successfully configured.")
    
    if(make_targets):
        print(" Installing missing libraries...")
        for make_target in make_targets:
            temp_text("  Installing {}...".format(make_target))
            result = call(["make", make_target], stdout=subprocess.DEVNULL, stderr=errlog)
            if result != 0:
                warn("Failed to install {0}! Skipping {0}, but proceeding with the other libraries...".format(make_target))

        good(" Installed all missing libraries!")

        print(" Running cmake again to make sure it finds the libraries...")
        for lib in libraries.values():
            lib.needsInstallation = False
            lib.path = "extlibs/{}".format(lib.name)

        cmake_configure()    

def installLibs(*libs):
    """
    Attempts to prepare the libs for installation.

    The parameter libs is expected to be a varargs of tuples. These tuples must consist of the lib's canonical-name and
    it's package-name in that order (consider the tuple ("SFML", "libsfml") )
    """
    # step 1: gather information
    for lib in libs:
        libraries[lib[0]] = Library()
        libraries[lib[0]].name = lib[0]
        libraries[lib[0]].pkgname = lib[1]
        libraries[lib[0]].cmake_path_variable = lib[2]
        libraries[lib[0]].needsInstallation = not yes_no_prompt("  Do you have {} installed?".format(lib[0]), 'y', 'n')
        if libraries[lib[0]].needsInstallation:
            # Windows does currently not provide a convenient way to install dependencies, neither does it net such dependencies yet.            
            if os != OS.Windows:
                libraries[lib[0]].needBuildDep = not yes_no_prompt("   Do you have the build dependencies of {} installed?".format(lib[0]), 'y', 'n')
        else:
            libraries[lib[0]].needBuildDep = False
            libraries[lib[0]].path = input("   Where did you install {}? (leave empty if installed in the default path): ".format(lib[0]))
            
    # contains the package names of all libraries that need their build deb installed.
    buildDepPackages = [package.pkgname for package in libraries.values() if package.needBuildDep]
    # install build-dep
    installDeb(buildDepPackages)

    if buildDepPackages:
        good(" build-dep has been installed for the packages.")
        print(" The following libs are scheduled for installation: {}".format(", ".join(buildDepPackages)))
    else:
        print(" No libs are scheduled for installation.")
        print(" Running cmake a first time to create the Makefiles...")

    cmake_configure()

            
def locate(*exes):
    """
    Try to locate all the names in @exes using ``shutil.which``.

    :param exes : the list of executables which should be located
    """
    for exe in exes:
        if exe in executables:
            # executable has already been found!
            continue
        temp_text("  Locating {}...".format(exe))
        path = shutil.which(exe)
        if path is None:
            print("  Could not find {}!".format(exe))
            return False
        else:
            print("  Found {} in {}".format(exe, path))
            executables[exe] = path
    return True


def detectOS():
    global os
    temp_text(" Determining OS...")
    os_as_string = sys.platform
    print(" You are running {}.".format(os_as_string))
    os_as_OS = OS.NotSupported
    if os_as_string.startswith("linux"):
        os_as_OS = OS.Linux
    elif os_as_string.startswith("win32"):
        os_as_OS = OS.Windows

    if os_as_OS == OS.NotSupported:
      warn("  You are using an operating system that is currently not supported.")
      warn("  Configuration and compilation may or may not work.")
    else:
      good("  Your operating system is supported by this script.")

    os = os_as_OS

def detectCores():
    try:
        global cores
        temp_text(" Finding cores...")
        cores = multiprocessing.cpu_count()
        # additional whitespace at the end of the string to overwrite the former buffer.
        print("  Found {} cores. ".format(cores))
    except NotImplementedError:
        warn(" Automatic detection of core count failed.")
        _cores = input(" How many cores are running on your machine? [default={}] ?".format(DEFAULT_CORE_COUNT))
        if cores.isnumeric():
            cores = int(_cores)
            print("  Using {} cores.".format(_cores))
        else:
            warn("  Using default value ({} cores).".format(DEFAULT_CORE_COUNT))
            cores = DEFAULT_CORE_COUNT

def yes_no_prompt(prompt, y, n):
    while True:
        answer = input("{} (y/n):".format(prompt))
        if answer == y:
            return True
        elif answer == n:
            return False


def main():
    print("secret-archer bootstrap script")
    warn("Make sure to run this script with administrator rights if you want to install build dependencies using this script!")
    warn("In any other case (i.e 'normal' installation), do NOT grant this script administrative priviledges!")
    warn("If you configure the project with administrative priviledges, cmake and make will need those as well.")
    print(" Gathering basic system information...")
    detectOS()
    detectCores()
    print(" locating essential executables...")
    if locate("cmake", "git"):
        good(" Found all essential executables!")
    else:
        die("  Please install the missing executable.")

    
    installLibs(("SFML", "libsfml", "SFML_ROOT"), ("Boost", "libboost-all-dev", "BOOST_ROOT"))

    good("Successfully configured the project.")
    good("For further steps, consult `make help`.")
    good("A good start is `make client` !")

if __name__ == "__main__":
    main()

