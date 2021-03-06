﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".").Replace(".ps1","")
$baseModulePath = "$here\..\tools\powershell\modules"

$module = Get-Module $sut
if ($module -ne $null)
{
	Remove-Module $sut
}

Describe "Set-BuildNumberWithGitCommitDetail" {

	Context "When Git is not in the Windows path" {
		
		Import-Module "$baseModulePath\$sut"
		Mock -ModuleName $sut Get-EnvironmentPath { return "" }

		$result = ""
		try {
			Set-BuildNumberWithGitCommitDetail
		}
		catch {
			$result = $_
		}
		finally {
			Remove-Module $sut
		}
		
		It "Exits the module with a descriptive terminating error" {
			$result | Should Be "Unable to find Git defined within the Windows path environment variable. Either check Git is both installed and included in the Windows path environment (system) variable or provide the full path to 'git.exe' using the '$gitPath' variable and try again." 
        }			
	}	

	Context "When a Git repository is not initiated" {
		
		Import-Module "$baseModulePath\$sut"
		Mock -ModuleName $sut Get-GitStatus { return "fatal: Not a git repository (or any of the parent directories): .git" }

		$result = ""
		try {
			Set-BuildNumberWithGitCommitDetail -verbose
		}
		catch {
			$result = $_
		}
		finally {
			Remove-Module $sut
		}
		
		It "Exits the module with a descriptive terminating error" {
			$result | Should Be "The current path is not a git repository, try using (git init)" 
        }			
	}	


	Context "When a Git repository has no commit history" {
		Import-Module "$baseModulePath\$sut"
		Mock -ModuleName $sut Get-GitLog { return "fatal: bad default revision 'HEAD'" }

		$result = ""
		try {
			Set-BuildNumberWithGitCommitDetail -verbose
		}
		catch {
			$result = $_
		}
		finally {
			Remove-Module $sut
		}
		
		It "Exits the module with a descriptive terminating error" {
			$result | Should Be "Unable to determine revision number as no commits have been made to this Git repository, (use ""git add"" and ""git commit"") and try again." 
        }		
	
	}
	
}


$module = Get-Module $sut
if ($module -ne $null)
{
	Remove-Module $sut
}


