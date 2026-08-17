@echo off
echo ========================================
echo Service Finder Web - Quick Start
echo ========================================
echo.

echo [1/3] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo Node.js: OK
echo.

echo [2/3] Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies!
    pause
    exit /b 1
)
echo Dependencies installed successfully!
echo.

echo [3/3] Checking environment configuration...
if not exist .env.local (
    echo WARNING: .env.local file not found!
    echo.
    echo Please create .env.local file with your Firebase configuration.
    echo Copy from .env.local.example and fill in your values.
    echo.
    echo Do you want to open the setup guide? (Y/N)
    set /p open_guide=
    if /i "%open_guide%"=="Y" (
        start SETUP_GUIDE.md
    )
    pause
    exit /b 1
)
echo Environment file: OK
echo.

echo ========================================
echo Setup Complete! Starting development server...
echo ========================================
echo.
echo The app will open at: http://localhost:3000
echo Press Ctrl+C to stop the server
echo.

call npm run dev
