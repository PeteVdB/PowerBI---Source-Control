param([String]$Path)


function Remove-UnusedFiles
{
    Remove-Item -Path "$($location).zip"
    Remove-Item -Path "$($location)\DataMashup"
    Remove-Item -Path "$($location)\Metadata"
    Remove-Item -Path "$($location)\SecurityBindings"
    Remove-Item -Path "$($location)\Settings"
    Remove-Item -Path "$($location)\Version"
}

function Create-JsonFiles
{
    foreach($jsonFileName in $jsonFileNames)
    {
        $file = Get-ItemProperty -Path "$($location)\$($jsonFileName)"

        $text = Get-Content "$($location)\$($jsonFileName)" -Encoding Unknown | Out-File -FilePath "$($location)\$($jsonFileName).json" -Encoding utf8
        Remove-Item -Path "$($location)\$($jsonFileName)"
    }
}

function Create-XmlFiles
{
    $text = Get-Content "$($location)\DataMashup"
    $string = $text[4].ToString()
    $len = $string.IndexOf("/LocalPackageMetadataFile") - $string.IndexOf("LocalPackageMetadataFile")
    $string.Substring($string.IndexOf("LocalPackageMetadataFile") -1, $len + 27) | Out-File -FilePath "$($location)\DataMashup.xml" -Encoding utf8
}


#===================================================
#MAIN SECTION
#===================================================

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

    Create-XmlFiles

    Create-JsonFiles

    Remove-UnusedFiles
}