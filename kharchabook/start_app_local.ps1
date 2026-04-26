# Helper Script to Start XAMPP MySQL on 3307 and Run App
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "Starting XAMPP MySQL..."
Start-Process -FilePath "C:\xampp\mysql\bin\mysqld.exe" -ArgumentList "--defaults-file=C:\xampp\mysql\bin\my.ini" -WindowStyle Hidden

Write-Host "Waiting for MySQL to start..."
Start-Sleep -Seconds 3



function Get-FreePort {
    param(
        [int[]]$Candidates = @(8080, 8081, 8082, 8090)
    )
    foreach ($p in $Candidates) {
        $inUse = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
        if (-not $inUse) { return $p }
    }
    throw "No free port found in candidates: $($Candidates -join ', ')"
}

$port = Get-FreePort
Write-Host "Using port $port (8080 may already be in use)."

Write-Host "Checking for Maven..."
$mavenDir = ".\apache-maven-3.9.6"
If (-Not (Test-Path "$mavenDir\bin\mvn.cmd")) {
    Write-Host "Downloading Maven..."
    Invoke-WebRequest -Uri "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip" -OutFile "maven.zip"
    Write-Host "Extracting Maven..."
    Expand-Archive -Path "maven.zip" -DestinationPath "." -Force
    Remove-Item "maven.zip"
}

Write-Host "Adding Maven to Path..."
$env:PATH += ";$(Convert-Path .)\apache-maven-3.9.6\bin"
$env:PATH += ";$PWD\apache-maven-3.9.6\bin"

Write-Host "Starting Jetty server..."
Write-Host "App URL: http://localhost:$port/"
$mvnArgs = @("-Djetty.http.port=$port", "install", "jetty:run")
& mvn @mvnArgs
