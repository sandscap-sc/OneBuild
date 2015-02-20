function New-SolutionConfigFiles{
<#
 
.SYNOPSIS
    Identifies all _config paths under the given solution path.
.DESCRIPTION
    Identifies all _config paths under the given solution path
.PARAMETER path
	Optional. The full path to the Visual Studio Solution parent folder to look for _config folders in.  Defaults to the calling scripts path.	
.EXAMPLE 
	Import-Module New-SolutionConfigFiles
	Import the module
.EXAMPLE	
	Get-Command -Module New-SolutionConfigFiles
	List available functions
.EXAMPLE
	New-SolutionConfigFiles -basePath AssemblyInfo.cs
	Execute the module
#>
	[cmdletbinding()]
		Param(
			[Parameter(Mandatory = $False)]
				[string]
				$path					
			)
	Begin {
			$DebugPreference = "Continue"
			if (-not $PSBoundParameters.ContainsKey('Verbose'))
			{
				$VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
			}
		}	
	Process {
				Try {
						$basePath = Confirm-Path -path $path

				 		$configPaths = Get-ChildConfigFolders -path $basePath
						#Write-Host $configPaths.GetType()
						$numberOfConfigPaths = $configPaths.Count 
						Write-Verbose "New-SolutionConfigFiles: Found $numberOfConfigPaths _config path(s)."
						
						ForEach ($configPath in $configPaths)
						{
							New-ConfigTransformsForConfigPath -path $configPath							
						}
					
				} catch [Exception] {
					throw "An error occurred generating config files under path: $basePath. `r`n $_"
				}
				
			}
}

function Confirm-Path {
	Param(			
			[Parameter(
				Mandatory = $False )]
				[string]$path			
		)	
	Import-Module "$PSScriptRoot\Get-Path.psm1"
	Try {
		$path = Get-Path -path $path
		return $path
	}
	Catch {
		throw $_
	}
	Finally {
		Remove-Module Get-Path
	}
}

function Get-ChildConfigFolders {
	Param(			
			[Parameter(
				Mandatory = $False )]
				[string]$path			
		)	
	#Convention: Get the full path to all _config folders under the supplied path. 
	return Get-ChildItem $path -recurse | Where-Object {$_.Name -eq '_config'} |Sort-Object $_.FullName -Descending | foreach {$_.FullName}
}

function New-ConfigTransformsForConfigPath {
	Param(			
			[Parameter(
				Mandatory = $False )]
				[string]$path			
		)	
	Write-Verbose "New-SolutionConfigFiles: Processing config transformations for $path."	
	$baseConfigFile = Confirm-BaseConfigFileExistsForConfigPath -path $path
	
	
	
}

function Confirm-BaseConfigFileExistsForConfigPath {
	Param(			
			[Parameter(
				Mandatory = $False )]
				[string]$path			
		)	
	
	if (-not(Test-Path "$path\application"))
	{
		throw "No 'application' folder found under path: $path, please remove the _config folder or add a child 'application' folder."
	}
	
	#Convention: Get the first XML file we find (ordered alphabetically) in the application folder. 
	$baseConfigFile = Get-ChildItem "$path\application" | Where-Object {$_.Extension -eq '.xml'} |Sort-Object $_.FullName -Descending | foreach {$_.FullName} | Select-Object -First 1
	
	if ($baseConfigFile -eq $null)
	{
		throw "No XML base config file found under path: $path\application, please remove the '_config\application' folder or add a base XML config file."
	}	
	
	return $baseConfigFile
}

Export-ModuleMember -Function New-SolutionConfigFiles