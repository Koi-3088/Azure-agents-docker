# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2025

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# ------------------------------------------------------------
# 1. Visual Studio Build Tools 2022 (MSVC + ClangCL)
# ------------------------------------------------------------
RUN Write-Host 'Installing Visual Studio Build Tools (MSVC + ClangCL)...'; `
    setx VSINSTALL_SKIP_HARDLINKS 1; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_buildtools.exe -OutFile vs_buildtools.exe; `
    Start-Process -FilePath .\vs_buildtools.exe -Wait -ArgumentList `
        '--quiet', '--wait', '--norestart', `
        '--add', 'Microsoft.VisualStudio.Workload.VCTools', `
        '--add', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64', `
        '--add', 'Microsoft.VisualStudio.Component.VC.Llvm.Clang', `
        '--add', 'Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset', `
        '--add', 'Microsoft.VisualStudio.Component.Windows10SDK.22621', `
        '--includeRecommended'; `
    Remove-Item vs_buildtools.exe -Force; `
    Write-Host 'Visual Studio Build Tools installation complete.'

# ------------------------------------------------------------
# 2. LLVM / Clang
# ------------------------------------------------------------
RUN Write-Host 'Installing LLVM / Clang 18.1.8...'; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    $url = 'https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/LLVM-18.1.8-win64.exe'; `
    $out = 'C:\llvm-installer.exe'; `
    Invoke-WebRequest -Uri $url -OutFile $out; `
    Start-Process -FilePath $out -ArgumentList '/S','/D=C:\Program Files\LLVM' -Wait; `
    Remove-Item $out -Force; `
    Write-Host 'LLVM installation complete.'

# ------------------------------------------------------------
# 3. Python 3.11.9
# ------------------------------------------------------------
RUN Write-Host 'Installing Python 3.11.9...'; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    $url = 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe'; `
    $out = 'C:\python-installer.exe'; `
    Invoke-WebRequest -Uri $url -OutFile $out; `
    Start-Process -FilePath $out -ArgumentList '/quiet','InstallAllUsers=1','PrependPath=1','Include_pip=1' -Wait; `
    Remove-Item $out -Force; `
    Write-Host 'Python installation complete.'

# ------------------------------------------------------------
# 4. Qt 6.10.2 via aqtinstall (Full install: QtMultimedia + QtSerialPort)
# ------------------------------------------------------------
RUN Write-Host 'Installing Qt 6.10.2 with aqtinstall...'; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    $python = 'C:\Program Files\Python311\python.exe'; `
    & "$python" -m pip install --upgrade pip; `
    & "$python" -m pip install aqtinstall; `
    & "$python" -m aqt install-qt --outputdir C:\Qt windows desktop 6.10.2 win64_msvc2022_64 -m all; `
    Write-Host 'Qt installation complete.'

# ------------------------------------------------------------
# 5. Install CMake and Git
# ------------------------------------------------------------
RUN powershell -Command `
    Write-Host 'Installing CMake and Git...'; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri 'https://github.com/Kitware/CMake/releases/download/v4.1.2/cmake-4.1.2-windows-x86_64.msi' -OutFile cmake.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I', 'cmake.msi', '/quiet', '/norestart', 'ADD_CMAKE_TO_PATH=System'; `
    Remove-Item cmake.msi -Force; `
    Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.50.1.windows.1/Git-2.50.1-64-bit.exe' -OutFile git-installer.exe; `
    Start-Process -FilePath git-installer.exe -ArgumentList '/VERYSILENT', '/NORESTART' -Wait; `
    Remove-Item git-installer.exe -Force; `
    Write-Host 'CMake and Git installation complete.'

# ------------------------------------------------------------
# 6. Install Ninja build tools
# ------------------------------------------------------------
RUN powershell -Command `
    Write-Host 'Installing Ninja build tools...'; `
    $ninjaUrl = 'https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip'; `
    $ninjaZip = 'C:\ninja.zip'; `
    $ninjaDir = 'C:\ninja'; `
    Invoke-WebRequest -Uri $ninjaUrl -OutFile $ninjaZip; `
    Expand-Archive -Path $ninjaZip -DestinationPath $ninjaDir -Force; `
    Remove-Item $ninjaZip -Force; `
    Write-Host 'Ninja installation complete.'

# ------------------------------------------------------------
# 7. Install 7zip
# ------------------------------------------------------------
RUN powershell -Command `
    Write-Host 'Installing 7zip...'; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    $7zipUrl = 'https://www.7-zip.org/a/7z2600-x64.msi'; `
    $7zipInstaller = 'C:\7zip-installer.msi'; `
    Invoke-WebRequest -Uri $7zipUrl -OutFile $7zipInstaller; `
    Start-Process msiexec.exe -ArgumentList '/I', $7zipInstaller, '/quiet', '/norestart' -Wait; `
    Remove-Item $7zipInstaller -Force; `
    Write-Host '7zip installation complete.'

# ------------------------------------------------------------
# 8. Set Application Control Policy
# ------------------------------------------------------------
RUN powershell -Command `
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' `
    -Name 'VerifiedAndReputablePolicyState' -Value 0 -ErrorAction SilentlyContinue;

# ------------------------------------------------------------
# 9. Verify major toolchains
# ------------------------------------------------------------
RUN powershell -Command `
    Write-Host 'Verifying toolchain setup...'; `
    & 'C:\Program Files\LLVM\bin\clang.exe' --version; `
    & 'C:\Program Files\Python311\python.exe' --version; `
    & 'cmake.exe' --version; `
    & 'git.exe' --version; `
    & 'C:\ninja\ninja.exe' --version; `
    & 'C:\Program Files\7-Zip\7z.exe' i; `
    Write-Host 'Toolchain verification complete.'

# ------------------------------------------------------------
# 10. Azure DevOps Agent
# ------------------------------------------------------------
WORKDIR C:\azp
RUN Invoke-WebRequest https://download.agent.dev.azure.com/agent/5.277.0/vsts-agent-win-x64-5.277.0.zip -OutFile agent.zip; `
    Expand-Archive agent.zip -DestinationPath .; Remove-Item agent.zip
COPY start.ps1 .
ENTRYPOINT ["powershell.exe","-File","start.ps1"]
