#!/bin/zsh

source ../lib.sh

progname=$(basename $0)
basedir=$(realpath "$(dirname "${BASH_SOURCE[0]}")") # directory containing this file

###############################################################################
# Command-line parsing
###############################################################################

usage()
{
cat << USAGE
$progname [--config (debug|release)] [--copypath PATH] [--help]"

$progname builds and optionally copies the native Android AAR library.

options:
-c|--config   Build configuration to produce. Must be 'debug' or 'release' (default: debug)
-p|--copypath Resulting AAR will be copied to PATH.
-h|--help     Display this message.
USAGE
}

while [ "$#" -gt 0 ]; do
    case $1 in
        -c|--config )        
          shift
          configuration=$1
          ;;
        -p|--copypath )        
          shift
          copypath=$(realpath $1)
          ;;
        -h|--help )           
          usage $0
          exit
          ;;
        * )
          ERROR Unknown argument $1
          usage
          exit 1
          ;;
    esac
    shift
done

if [[ -z "$configuration" ]]; then
  configuration=debug
fi

if [[ "$configuration:l" != "debug" && "$configuration:l" != "release" ]]; then
  ERROR Invalid option for --config. Expected debug or release, got $configuration.
  exit 1
fi

###############################################################################
# Setup
###############################################################################

# Version 7 of the Android Gradle Plugin requires Java 11, so we have to let gradle know
# where to find it.  GitHub actions macos 10.15 virtual environment defines the following
# environment variable.  Otherwise, we use a local install. Make sure you have adoptopenjdk-11
# installed in the following location.
if [ -z "$JAVA_HOME_11_X64" ]; then
  JAVA_HOME_11_X64=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home/
fi

###############################################################################
# Main
###############################################################################

# Build native Android library 

# We'd like to run `:lemonlib:build` to assemble, lint, and test the Collection SDK, but 
# Version 7 of Android Gradle Plugin has a bug in the `lint` task resulting in the error
# "lateinit property variantName has not been intialized".  So we skip the `lint` task and 
# run `assemble` and `test` separately.

if [[ $configuration == debug ]]; then
  assemble=assembleDebug
else
  assemble=assemble
fi

./gradlew \
  -Dorg.gradle.java.home=$JAVA_HOME_11_X64 \
  :clean \
  :lemonlib:$assemble \
  :lemonlib:test \
  :lemonlib:xamarin \
  || exit 1


if [[ ! -z $copypath ]]; then
  H2 Copying AARs and JARs to ${copypath}
  if [[ ! -d $copypath/aar ]]; then
    mkdir -p $copypath/aar 
  fi
  if [[ ! -d $copypath/jar ]]; then
    mkdir -p $copypath/jar
  fi
  cp lemonlib/build/outputs/aar/lemonlib-$configuration.aar $copypath || exit 1
  cp lemonlib/xamarin/*.aar $copypath/aar || exit 1
  cp lemonlib/xamarin/*.jar $copypath/jar || exit 1
fi
