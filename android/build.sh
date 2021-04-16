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
# Main
###############################################################################

# Build native Android library 

if [[ $configuration == debug ]]; then
  assemble=assembleDebug
else
  assemble=assemble
fi

./gradlew \
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
