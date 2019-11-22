param
(
   [string]$url,
   [string]$poolName,
   [string]$pat
)

$errorActionPreference = 'Stop'

if ([string]::IsNullOrEmpty($url))
{
   Write-Error "URL is null"
}

if ([string]::IsNullOrEmpty($poolName))
{
   Write-Error "PoolName is null"
}

if ([string]::IsNullOrEmpty($pat))
{
   Write-Error "PAT is null"
}

Write-Host "AccountName: " $accountName
Write-Host "PoolName:" $poolName
Write-Host "PAT: " $pat

Write-Host "Running windows_startup.ps1"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$cwd = Convert-Path .
Write-Host "Current folder:" $cwd

$agentDir = "\agent"
$agentExe = Join-Path -Path $agentDir -ChildPath "bin\Agent.Listener.exe"
$agentZip = Get-ChildItem -Path .\* -File -Include vsts-agent*.zip
$agentConfig = Join-Path -Path $agentDir -ChildPath "config.cmd"
$agentRun = Join-Path -Path $agentDir -ChildPath "run.cmd"

$provisionerDir = "\provisioner"
$provisionerExe = Join-Path -Path $provisionerDir -ChildPath "provisioner.exe"
$provisionerZip = Get-ChildItem -Path .\* -File -Include vsts-provisioner*.zip

#
# install the build agent if necessary
#
if (!(Test-Path -Path $agentDir))
{
   Write-Host "Creating agent folder"
   New-Item -ItemType directory -Path $agentDir
}

if (!(Test-Path -Path $agentExe))
{
   Write-Host "Unzipping agent"
   [System.IO.Compression.ZipFile]::ExtractToDirectory($agentZip, $agentDir)
}
Get-Item $agentExe

#
# install the provisioner if necessary
#
if (!(Test-Path -Path $provisionerDir))
{
   Write-Host "Creating provisioner folder"
   New-Item -ItemType directory -Path $provisionerDir
}

if (!(Test-Path -Path $provisionerExe))
{
   Write-Host "Unzipping Provisioner"
   [System.IO.Compression.ZipFile]::ExtractToDirectory($provisionerZip, $provisionerDir)
}
Get-Item $provisionerExe

# configure the build agent
$configParameters = " --unattended --url $url --auth $pat --pool $poolName"
$config = $agentConfig + $configParameters
Write-Host "Running " $config
Invoke-Expression $config

# run the build agent
Write-Host "Running " $agentRun
Invoke-Expression $agentRun
