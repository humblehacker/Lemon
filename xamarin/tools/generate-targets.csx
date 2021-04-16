#! /usr/bin/env dotnet script
#r "nuget: CommandLineParser, 2.8.0"

using System;
using System.Xml.Linq;
using CommandLine;

class Options 
{
    [Option(Required = false, Default = "monoandroid10", HelpText = "monoandroid version directory")]
    public string targetFramework { get; set; }
}

var targetFramework = "monoandroid10.0";
Parser.Default.ParseArguments<Options>(Args)
    .WithParsed<Options>(o =>
    {
        targetFramework = o.targetFramework;
    })
    .WithNotParsed<Options>(e => 
    {
        System.Environment.Exit(1);  
    });

var aars = new List<String>();
string s;
while ((s = Console.ReadLine()) != null)
{
    aars.Add(s);
}

XNamespace xmlns = "http://schemas.microsoft.com/developer/msbuild/2003";

var itemGroup = new XElement(xmlns + "ItemGroup");
foreach(var aar in aars) 
{
    itemGroup.Add(
            new XElement(xmlns + "AndroidAarLibrary",
                new XAttribute("Include", $"$(MSBuildThisFileDirectory)..\\..\\build\\{targetFramework}\\{aar}")
                )
    );
}

var doc = new XDocument(
    new XElement(xmlns + "Project",
        new XAttribute("ToolsVersion", "4.0"),
        itemGroup
    )
);

class Utf8StringWriter: StringWriter
{
    public override Encoding Encoding {
        get { return new UTF8Encoding(); }
    }
}

var sw = new Utf8StringWriter();
doc.Save(sw);
Console.WriteLine(sw);