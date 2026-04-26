# Setup and Run Script for KharchaBook

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " KharchaBook Setup and Run Script " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Ask for MySQL Password
$mysqlPassword = Read-Host "Please enter your MySQL 'root' password (typing will be visible)"

# 2. Update db.properties
$dbPropsPath = "src\main\resources\db.properties"
If (Test-Path $dbPropsPath) {
    $content = Get-Content $dbPropsPath
    $content = $content -replace "db\.password=.*", "db.password=$mysqlPassword"
    $content | Set-Content $dbPropsPath
    Write-Host "Updated db.properties with your password." -ForegroundColor Green
} Else {
    Write-Host "Could not find db.properties at $dbPropsPath" -ForegroundColor Red
}

# 3. Initialize Database
$mysqlExe = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
If (Test-Path $mysqlExe) {
    Write-Host "Initializing database from schema.sql..." -ForegroundColor Yellow
    
    # We will pass the password via command line just for this setup
    $cmdArgs = "-u", "root", "-p$mysqlPassword", "-e", "source sql/schema.sql"
    & $mysqlExe $cmdArgs
    If ($LASTEXITCODE -eq 0) {
        Write-Host "Database successfully initialized!" -ForegroundColor Green
    } Else {
        Write-Host "There was an issue initializing the database. Please check your password." -ForegroundColor Red
        Exit
    }
} Else {
    Write-Host "Could not find MySQL at $mysqlExe. Make sure MySQL 8.0 is installed." -ForegroundColor Red
    Exit
}

# 4. Use Maven Wrapper if possible, or Download Maven
Write-Host "Checking for Maven..." -ForegroundColor Yellow
$mavenDir = ".\apache-maven-3.9.6"
If (-Not (Test-Path "$mavenDir\bin\mvn.cmd")) {
    Write-Host "Downloading Maven..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip" -OutFile "maven.zip"
    Write-Host "Extracting Maven..." -ForegroundColor Yellow
    Expand-Archive -Path "maven.zip" -DestinationPath "." -Force
    Remove-Item "maven.zip"
}

$env:PATH += ";$PWD\apache-maven-3.9.6\bin"
Write-Host "Maven is ready." -ForegroundColor Green

# 5. Build and Run Application
Write-Host "Building and starting Tomcat/Jetty server..." -ForegroundColor Cyan

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
Write-Host "The application will be available at http://localhost:$port/" -ForegroundColor Cyan
$mvnArgs = @("-Djetty.http.port=$port", "install", "jetty:run")
& mvn @mvnArgs
