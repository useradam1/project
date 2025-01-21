@echo off
setlocal EnableDelayedExpansion

rem Check if version.txt exists
if not exist version.txt (
    echo File version.txt not found!
    exit /b 1
)
rem Check if changelog.txt exists
if not exist changelog.txt (
    echo File changelog.txt not found!
    exit /b 1
)

rem Read version.txt contents
set lineNum=0
for /f "tokens=*" %%a in (version.txt) do (
    set /a lineNum+=1
    if !lineNum!==1 (
        set projectName=%%a
    )
    if !lineNum!==2 (
        set version=%%a
    )
)

rem Split version into parts
for /f "tokens=1,2,3 delims=." %%a in ("!version!") do (
    set major=%%a
    set minor=%%b
    set patch=%%c
)

rem Increment patch version
set /a patch+=1

rem Create new version string
set newVersion=%major%.%minor%.%patch%





rem Display project information
echo =====================================
echo Project Information:
echo -------------------------------------
echo Project name: %projectName%
echo Current version: %version%
echo Updated version: %newVersion%
echo -------------------------------------
echo Changelog:
for /f "tokens=*" %%a in (changelog.txt) do (
    echo %%a
)
echo =====================================


:: Read the contents of changelog.txt into a variable
set "commitDescription="
for /f "tokens=*" %%a in (changelog.txt) do (
    set "commitDescription=!commitDescription!%%a\n"
)

:: Remove the trailing \n from the commitDescription
set "commitDescription=%commitDescription:~0,-2%"

echo %commitDescription%



:: Создание новой ветки с именем проект-версия (например, project-0.0.1)
set BRANCH_NAME=%projectName%-%version%
git rev-parse --verify %BRANCH_NAME% >nul 2>&1
if not errorlevel 1 (
    echo Branch %BRANCH_NAME% already exists.
    git checkout %BRANCH_NAME%
) else (
    git checkout -b %BRANCH_NAME%
)

:: Добавление всех изменений в индекс
git add .



:: Коммит с сообщением
git commit -m "Update: %projectName%-%version% ChangeLog: !commitDescription!"

:: Пуш изменений в удалённый репозиторий
git push -u origin %BRANCH_NAME%
if errorlevel 1 (
    echo Failed to push changes. Please check your Git authentication or branch settings.
    exit /b 1
)

:: Уведомление об успешной отправке
echo Changes successfully uploaded to the new branch %BRANCH_NAME%!

echo "Press enter to continue..."
pause
rem Clear changelog.txt contents
echo. > changelog.txt
rem Write updated content back to version.txt
(
    echo %projectName%
    echo %newVersion%
) > version.txt
echo "Done"
pause
