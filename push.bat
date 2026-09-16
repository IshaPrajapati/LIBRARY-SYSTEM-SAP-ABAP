@echo off
title Push to GitHub - IshaPrajapati/LIBRARY-SYSTEM-SAP-ABAP
echo ========================================================
echo   Pushing to GitHub: IshaPrajapati/LIBRARY-SYSTEM-SAP-ABAP
echo ========================================================
git push -u origin main
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo   SUCCESS! Pushed to https://github.com/IshaPrajapati/LIBRARY-SYSTEM-SAP-ABAP
    echo ========================================================
) else (
    echo.
    echo ========================================================
    echo   PUSH FAILED: Please make sure the repository
    echo   'LIBRARY-SYSTEM-SAP-ABAP' exists on your GitHub account:
    echo   https://github.com/new?name=LIBRARY-SYSTEM-SAP-ABAP
    echo ========================================================
)
pause
