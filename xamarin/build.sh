#!/bin/zsh

source ../lib.sh

progname=$(basename $0) 
basedir=$(realpath "$(dirname "${BASH_SOURCE[0]}")") # directory containing this file
nuget_name=Humblehacker.Lemon
source=Local

###############################################################################
# Command-line parsing
###############################################################################

usage()
{
  cat << USAGE
$progname --version VERSION [--config (debug|release)] [--help]"

$progname builds the Xamarin projects, assembles and publishes the NuGet.
All native libraries must be in their proper locations prior to running $progname.

options:
-c|--config  Build configuration to produce. Must be 'debug' or 'release' (default: debug)
-v|--version Specify version of NuGet to publish (major.minor.patch or 'next'). 'next'
             will get the latest version of the Lemon NuGet from the Local source and 
             bump the patch version.
-h|--help    Display this message.
USAGE
}

while [ "$#" -gt 0 ]; do
    case $1 in
        -c|--config )        
          shift
          configuration=$1
          ;;
        -v|--version )        
          shift
          version=$1
          ;;
        -h|--help )           
          usage 
          exit
          ;;
        *)
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

if [[ -z "$version" ]]; then
  ERROR Must specify --version \(major.minor.patch\)
  usage
  exit 1
fi

if [[ "$version:l" = "next" ]]; then
  current_version=$(echo $(nuget list $nuget_name -Source $source) \
    | gsed --regexp-extended --quiet "s/$nuget_name (.*)/\1/gp")
  if [[ -z "$current_version" ]]; then
    current_version="0.0.0"
  fi
  version=$(bumpPatchVersion $current_version)
fi

###############################################################################
# Setup
###############################################################################


build_dir=$basedir/build/$version
package_dir=$build_dir/package

[[ -d $build_dir ]] || mkdir $build_dir

echo Building $build_dir

# Cleaning

find . \( -name obj -o -name bin \) -exec rm -r {} \; >& /dev/null

# Building

nuget restore || exit 1
msbuild \
  -target:clean,build \
  -property:Configuration=$configuration \
  -binaryLogger:$build_dir/build.binlog \
  || exit 1

# Constructing nuget

monoandroid='monoandroid10.0'
#xamarinios='xamarinios10'
#netstandard='netstandard2.1'
externals=$basedir/Lemon.Android.Binding/externals

# Create the nuget package directory structure
#mkdir -p $package_dir/lib/$netstandard 
#mkdir -p $package_dir/lib/$xamarinios 
mkdir -p $package_dir/lib/$monoandroid
mkdir -p $package_dir/build/$monoandroid 
mkdir -p $package_dir/buildTransitive/$monoandroid

# Add nuspec and update the version number
sed "s|<version>.*</version>|<version>$version</version>|" < ./$nuget_name.nuspec > $package_dir/$nuget_name.nuspec

echo ASSEMBLIES
# Copy assemblies to package
#cp ./Lemon.Standard/bin/$configuration/$netstandard/* $package_dir/lib/$netstandard || exit 1
cp ./Lemon.Android.Binding/bin/$configuration/* $package_dir/lib/$monoandroid || exit 1
#cp ./Lemon.iOS/bin/$configuration/* $package_dir/lib/$xamarinios || exit 1

echo AARS
# Copy Android aars to package
cp $externals/aar/* $package_dir/build/$monoandroid || exit 1

echo TARGETS
# Generate targets file and copy to package
ls $package_dir/build/$monoandroid/*.aar \
    | xargs basename \
    | $basedir/tools/generate-targets.csx --targetframework $monoandroid \
    > $package_dir/build/$monoandroid/$nuget_name.targets || exit 1
cp $package_dir/build/$monoandroid/$nuget_name.targets $package_dir/buildTransitive/$monoandroid || exit 1

echo DUMP
# Dump the directory structure if `tree` is available
$(type tree > /dev/null) && tree $package_dir 

echo PACK
# Packing
pushd $build_dir >> /dev/null
nuget pack $package_dir || exit 1

# Publishing to source 
dotnet nuget push $build_dir/$nuget_name.$version.nupkg --source $source || exit 1
