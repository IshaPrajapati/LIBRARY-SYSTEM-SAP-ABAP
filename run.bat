@echo off
title SAP GUI Live Runner - ZA16_LIBRARY_MANAGEMENT
echo ========================================================
echo   Launching SAP GUI Simulator (ZA16_LIBRARY_MANAGEMENT)
echo ========================================================
python server.py
if %ERRORLEVEL% NEQ 0 (
    echo Python server failed. Opening index.html directly...
    start "" index.html
)
pause
