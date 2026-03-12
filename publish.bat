@echo off
echo Building HTML...
call make html
if errorlevel 1 (
    echo Build failed. Aborting.
    pause
    exit /b 1
)

echo Copying to repo root...
xcopy /E /Y /I build\html\* .

echo Done. Review changes, then commit and push manually.
pause
