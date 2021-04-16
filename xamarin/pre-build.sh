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
$progname [--[no]-android] [--[no]-ios] [--help]"
  
$progname builds native dependencies of the Xamarin Binding libraries and installs the
into the correct locations.  Intended to be run prior to build.sh.

options:
-h|--help         Display this message.
-i|--[no-]ios     Build only iOS dependencies (add 'no' to skip iOS)
-i|--[no-]android Build only Android dependencies (add 'no' to skip Android)
USAGE
}

skip_android=false
skip_ios=false

while [ "$#" -gt 0 ]; do
    case $1 in
        -c|--config )        
          shift
          configuration=$1
          ;;
        -a|--android|--no-ios )
          skip_ios=true
          ;;
        -i|--ios|--no-android )
          skip_android=true
          ;;
        -h|--help )           
          usage
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
# Main
###############################################################################

# Build native iOS framework
if [[ $skip_ios == false ]]; then
  pushd ../ios
  ./build.sh \
    --copypath $basedir/Lemon.iOS.Binding \
    --config $configuration \
    || exit 1
  popd

  # Generate iOS ApiDefinitions
  pushd ./Lemon.iOS.Binding
  ./build.sh
  popd
fi

# Build native Android library
externals=$basedir/Lemon.Android.Binding/externals
if [[ -d $externals ]]; then
  rm -rf $externals || exit 1
fi

mkdir -p $externals || exit 1  

if [[ $skip_android == false ]]; then
  pushd ../android
  ./build.sh \
    --copypath $externals \
    --config $configuration \
    || exit 1
  popd
fi

# extract jars from aars
# ex: foobar.aar/classes.jar => foobar.aar.jar
extracted_jars=$externals/extracted_jars
if [[ ! -d $extracted_jars ]]; then
  mkdir -p $extracted_jars
fi

for aar in $externals/aar/*; do
  filename=$(basename $aar)
  unzip -j $aar classes.jar -d $extracted_jars/$filename > /dev/null || exit 1
  mv $extracted_jars/$filename/classes.jar $extracted_jars/$filename.jar || exit 1
  rm -rf $extracted_jars/$filename || exit 1
done


