## Build Instructions

1. Install prerequisites

        brew install gnu-sed

2. Add `Local` NuGet source

        dotnet nuget add source --name Local ~/.nuget/local
        nuget sources add -Name Local -Source ~/.nuget/local

      **note** `dotnet nuget add source` is for command-line builds, while the `nuget sources add` is for Visual Studio, which you can do via the UI if you prefer.

2. Build native Android library `lemonlib`

        cd xamarin
        ./pre-build.sh --android

3. Build the NuGet package and publish to source `Local`

        ./build.sh --version next

4. Build and run the sample project

    - open `sample/LemonApp/LemonApp.sln` in Visual Studio
    - update the `Humblehacker.Lemon` nuget package
    - build and run
