#Specify files with json data
$jsonFileNames = "DataModelSchema", "DiagramState", "Report\Layout"

#Get all .pbit files for a folder/repository
$pbitFiles = Get-ChildItem -Filter *.pbit -Recurse

#Rename and format files for each .pbit files
foreach ($pbitFile in $pbitFiles)
{  
    $path = "$($pbitFile.DirectoryName)\$($pbitFile.BaseName)"

    Copy-Item $pbitFile.FullName -Destination "$($path).zip"
    Expand-Archive -Path "$($path).zip" -DestinationPath "$($path)" -Force

    $text = Get-Content "$($path)\DataMashup"
    $string = $text[4].ToString()
    $len = $string.IndexOf("/LocalPackageMetadataFile") - $string.IndexOf("LocalPackageMetadataFile")
    $string.Substring($string.IndexOf("LocalPackageMetadataFile") -1, $len + 27) | Out-File -FilePath "$($path)\DataMashup.xml" -Encoding utf8

    foreach($jsonFileName in $jsonFileNames)
    {
        $file = Get-ItemProperty -Path "$($path)\$($jsonFileName)"

        $text = Get-Content "$($path)\$($jsonFileName)" -Encoding Unknown
        if(Test-Path -Path "$($path)\$($jsonFileName).json")
        {
            Set-Content -Path "$($path)\$($jsonFileName).json" -Value $text -Encoding utf8 -Force
            Remove-Item -Path "$($path)\$($jsonFileName)"
        }
        else
        {
            Set-Content -Path "$($path)\$($jsonFileName)" -Value $text -Encoding utf8 -Force
            Rename-Item -Path "$($path)\$($jsonFileName)" -NewName "$($file.BaseName).json"
        }

    }

    #Remove unnecessary files
    Remove-Item -Path "$($path).zip"
    Remove-Item -Path "$($path)\DataMashup"
    Remove-Item -Path "$($path)\Metadata"
    Remove-Item -Path "$($path)\SecurityBindings"
    Remove-Item -Path "$($path)\Settings"
    Remove-Item -Path "$($path)\Version"
}
