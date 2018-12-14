FROM microsoft/windowsservercore:10.0.14393.1884
LABEL Description="Windows development environment for Synaps with Qt 5.11.1 using msvc2017 compiler, Chocolatey and various dependencies for optional configuration"

RUN reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
RUN reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v DontShowUI /t REG_DWORD /d 1 /f

COPY qtifwsilent.qs C:\\qtifwsilent.qs
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    $ErrorActionPreference = 'Stop'; \
    $Wc = New-Object System.Net.WebClient ; \
    $Wc.DownloadFile('https://download.qt.io/archive/qt/5.11/5.11.1/qt-opensource-windows-x86-5.11.1.exe', 'C:\qt.exe') ; \
    Echo 'Downloaded qt-opensource-windows-x86-5.11.1.exe' ; \
    $Env:QT_INSTALL_DIR = 'C:\\Qt' ; \
    Start-Process C:\qt.exe -ArgumentList '--verbose --script C:/qtifwsilent.qs' -NoNewWindow -Wait ; \
    Remove-Item C:\qt.exe -Force ; \
    Remove-Item C:\qtifwsilent.qs -Force
ENV QTDIR64 C:\\Qt\\Qt5.11.1\\5.11.1\\msvc2017_64
RUN dir "%QTDIR64%" && dir "%QTDIR64%\bin\Qt5Script.dll"
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command \
    $Env:chocolateyVersion = '0.10.8' ; \
    $Env:chocolateyUseWindowsCompression = 'false' ; \
    "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
RUN choco install -y python2 --version 2.7.14 && refreshenv && python --version && pip --version
RUN choco install -y qbs --version 1.9.1 && qbs --version 
RUN choco install -y unzip --version 6.0 && unzip -v
RUN choco install -y visualcpp-build-tools
RUN choco install -y zip --version 3.0 && zip -v