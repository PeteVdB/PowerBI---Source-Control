param([String]$Path)

#Specify files with json data
$jsonFileNames = "DataModelSchema", "DiagramState", "Report\Layout"

#Get all .pbit files for a folder/repository
$pbitFiles = Get-ChildItem -Path $Path -Filter *.pbit -Recurse

#Rename and format files for each .pbit files
foreach ($pbitFile in $pbitFiles)
{  
    $location = "$($pbitFile.DirectoryName)\$($pbitFile.BaseName)"

    Copy-Item $pbitFile.FullName -Destination "$($location).zip"
    Expand-Archive -Path "$($location).zip" -DestinationPath "$($location)" -Force

    $text = Get-Content "$($location)\DataMashup"
    $string = $text[4].ToString()
    $len = $string.IndexOf("/LocalPackageMetadataFile") - $string.IndexOf("LocalPackageMetadataFile")
    $string.Substring($string.IndexOf("LocalPackageMetadataFile") -1, $len + 27) | Out-File -FilePath "$($location)\DataMashup.xml" -Encoding utf8

    foreach($jsonFileName in $jsonFileNames)
    {
        $file = Get-ItemProperty -Path "$($location)\$($jsonFileName)"

        $text = Get-Content "$($location)\$($jsonFileName)" -Encoding Unknown
        if(Test-Path -Path "$($location)\$($jsonFileName).json")
        {
            Set-Content -Path "$($location)\$($jsonFileName).json" -Value $text -Encoding utf8 -Force
            Remove-Item -Path "$($location)\$($jsonFileName)"
        }

        else
        {
            Set-Content -Path "$($location)\$($jsonFileName)" -Value $text -Encoding utf8 -Force
            Rename-Item -Path "$($location)\$($jsonFileName)" -NewName "$($file.BaseName).json"
        }

    }

    #Remove unnecessary files
    Remove-Item -Path "$($location).zip"
    Remove-Item -Path "$($location)\DataMashup"
    Remove-Item -Path "$($location)\Metadata"
    Remove-Item -Path "$($location)\SecurityBindings"
    Remove-Item -Path "$($location)\Settings"
    Remove-Item -Path "$($location)\Version"
}
