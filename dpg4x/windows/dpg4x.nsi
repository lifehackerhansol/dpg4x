# Initially auto-generated by EclipseNSIS Script Wizard
# Manual updates by Tomas Aronsson

!define VERSION 2.3
# Must contain four parts, used for internal comparisons of patch levels
!define  VIProduct_Ver "${VERSION}.0.1.svn92"

Name dpg4x
# Needed because $(^Name) sometimes does not seem to expand correctly
!define NAME dpg4x

# General Symbol Definitions
!define REGKEY "SOFTWARE\${Name}"
!define CLIENT_REGKEY "SOFTWARE\CLIENTS\MEDIA\${Name}"
!define COMPANY "Dpg4x Sourceforge project"
!define URL http://sourceforge.net/projects/dpg4x/

# Dependencies are not installed when updating
Var /GLOBAL Updating
Var /GLOBAL InstalledVersion

# Dependencies: Visual C libraries are installed
!define DLLMSVC dependencies\vcredist_x86.exe

# Dependencies: mplayer and encoder are installed by downloading from the SourceForge
# project: MPlayer for Win32
!define MPLAYER_REV 34401
!define MPLAYER MPlayer-p3-svn-${MPLAYER_REV}
!define MPLAYER7Z dependencies\${MPLAYER}.7z
!define MPLAYER_URL "http://downloads.sourceforge.net/project/mplayer-win32/MPlayer%20and%20MEncoder/revision%20${MPLAYER_REV}/${MPLAYER}.7z"

# MultiUser Symbol Definitions
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${REGKEY}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME MultiUserInstallMode
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_INSTDIR "${Name}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "${REGKEY}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUE "Path"

# MUI Symbol Definitions
!define MUI_ICON ${NAME}.ico
!define MUI_WELCOMEFINISHPAGE_BITMAP "installer_${NAME}.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "installer_${NAME}.bmp"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${Name}"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-colorful.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_LICENSEPAGE_RADIOBUTTONS

!define MUI_FINISHPAGE_NOAUTOCLOSE

!define MUI_FINISHPAGE_LINK "${URL}"
!define MUI_FINISHPAGE_LINK_LOCATION "${URL}"

# Included files
!include MultiUser.nsh
!include Sections.nsh
!include MUI2.nsh
!include WordFunc.nsh

# Reserved Files
ReserveFile "${NSISDIR}\Plugins\BGImage.dll"
ReserveFile "${NSISDIR}\Plugins\AdvSplash.dll"

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE ..\COPYING
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!include nsis_translations\translations.nsh

# Installer attributes
OutFile "${NAME}-${VIProduct_Ver}_setup.exe"
Caption "${NAME} ${VIProduct_Ver}"
InstallDir $PROGRAMFILES\${NAME}
CRCCheck on
XPStyle on
ShowInstDetails show
VIProductVersion "${VIProduct_Ver}"
VIAddVersionKey ProductName "${Name}"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show
# Vista+ XML manifest, does not affect older OSes
RequestExecutionLevel admin

# Installer sections
Section -Main SEC0000
    SetOutPath $INSTDIR
    SetOverwrite on
    File ..\dist\*
    File /r ..\dist\doc
    File /r ..\dist\i18n
    File /r ..\dist\icons
    SetOutPath $INSTDIR\dependencies
    File /r ${MPLAYER7Z}
    File /r ${DLLMSVC}
    File /r dependencies\README.txt
        
    # Do not install dependencies if updating
    StrCmp "$Updating" "Yes" done

    # Download and install mplayer
    Call installMplayer

    # Silent install of visual C libraries:
    # If you would like to install the VC runtime packages in unattended mode (which will 
    # show a small progress bar but not require any user interaction), you can change the 
    # /qn switch below to /qb.  If you would like the progress bar to not show a cancel button, 
    # then you can change the /qn switch to /qb!
    ExecWait '"$INSTDIR\${DLLMSVC}" /q:a /c:"VCREDI~1.EXE /q:a /c:""msiexec /i vcredist.msi /qb!"" "'  
    WriteRegStr HKLM "${REGKEY}\Components" Main 1

    done:
SectionEnd

Section -post SEC0001
    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    WriteRegStr HKLM "${REGKEY}" Version "${VIProduct_Ver}"

    # Default Programs, Vista and later: (possibly more things to explore here...)
    # http://msdn.microsoft.com/en-us/library/cc144154%28v=vs.85%29.aspx
    WriteRegStr HKLM  "${CLIENT_REGKEY}\Capabilities\FileAssociations" ".dpg" "DPG Video"
    WriteRegStr HKLM  "${CLIENT_REGKEY}\Capabilities\FileAssociations" ".avi" "DPG Video"
    WriteRegStr HKLM "${CLIENT_REGKEY}\Capabilities" "ApplicationDescription" $(APPLICATION_DESCRIPTION)
    WriteRegStr HKLM "${CLIENT_REGKEY}\Capabilities" "ApplicationName" "${Name}"
    WriteRegStr HKLM "Software\RegisteredApplications" "${Name}" "${CLIENT_REGKEY}\Capabilities"

    SetOutPath $INSTDIR
    WriteUninstaller $INSTDIR\uninstall.exe

    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\$(UninstallLink).lnk" $INSTDIR\uninstall.exe
    CreateShortCut "$SMPROGRAMS\$StartMenuGroup\${Name} ${VERSION}.lnk" "$INSTDIR\dpg4x.exe" "" "$INSTDIR\dpg4x.exe"
    StrCmp "$Updating" "Yes" 0 +2
      Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${Name} $InstalledVersion.lnk"
    WriteINIStr    "$SMPROGRAMS\$StartMenuGroup\$(WebLink).url" "InternetShortcut" "URL" "${URL}"
    !insertmacro MUI_STARTMENU_WRITE_END

    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" DisplayName "${Name}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" DisplayVersion "${VIProduct_Ver}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" DisplayIcon $INSTDIR\uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}" NoRepair 1

SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section /o -un.Main UNSEC0000
    # Delete directories recursively except for main directory
    # Do not recursively delete $INSTDIR
    RmDir /r /REBOOTOK $INSTDIR\doc
    RmDir /r /REBOOTOK $INSTDIR\i18n
    RmDir /r /REBOOTOK $INSTDIR\icons
    RmDir /r /REBOOTOK $INSTDIR\dependencies    
    Delete /REBOOTOK $INSTDIR\*.dll
    Delete /REBOOTOK $INSTDIR\w9xpopen.exe
    Delete /REBOOTOK $INSTDIR\library.zip
    Delete /REBOOTOK $INSTDIR\Dpg4x.exe
    Delete /REBOOTOK $INSTDIR\Dpg4xConsole.exe
    Delete /REBOOTOK $INSTDIR\Dpg2avi.exe
    Delete /REBOOTOK $INSTDIR\DpgImgInjector.exe
    Delete /REBOOTOK $INSTDIR\*.pyd
    Delete /REBOOTOK $INSTDIR\*.7z
    Delete /REBOOTOK $INSTDIR\*.log    

    RmDir /r /REBOOTOK $INSTDIR\${MPLAYER}

    RmDir /REBOOTOK $INSTDIR
    DeleteRegValue HKLM "${REGKEY}\Components" Main
SectionEnd

Section -un.post UNSEC0001
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${Name}"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\$(UninstallLink).lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${Name} ${VERSION}.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\$(WebLink).url" 
    Delete /REBOOTOK $INSTDIR\uninstall.exe
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    DeleteRegValue HKLM "Software\RegisteredApplications" "${Name}"
    DeleteRegKey HKLM "${REGKEY}"
    DeleteRegKey HKLM "${CLIENT_REGKEY}"
    RmDir /REBOOTOK $SMPROGRAMS\$StartMenuGroup
    RmDir /REBOOTOK $INSTDIR
    Push $R0
    StrCpy $R0 $StartMenuGroup 1
    StrCmp $R0 ">" no_smgroup
no_smgroup:
    Pop $R0
SectionEnd

Function .onGUIEnd
    # empty
FunctionEnd


Function .onInit
    InitPluginsDir

    # Seems to use system language even after MUI_LANGDLL_DISPLAY
    Call CheckPreviousVersion

    !insertmacro MUI_LANGDLL_DISPLAY
    !insertmacro MULTIUSER_INIT    
FunctionEnd

# Uninstaller functions
Function un.onInit
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro MULTIUSER_UNINIT
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd

# Mplayer download functions are based on, incl reusing code, the NSIS installer
# in the SourceForge project: SMPlayer  (Written by redxii, thanks)
Function installMplayer
    retry_mplayer:

    DetailPrint $(MPLAYER_IS_DOWNLOADING)
    inetc::get /timeout 30000 /resume "" /caption $(MPLAYER_IS_DOWNLOADING) /banner "${MPLAYER7Z}" \
    ${MPLAYER_URL} \
    "$INSTDIR\${MPLAYER7Z}" /end
    Pop $R0
    StrCmp $R0 OK 0 check_mplayer

    DetailPrint "Extracting files..."

    SetOutPath $INSTDIR
    # the File command expects the file to be there when building the installer.
    # Solved by including an empty file that is replaced by the download above
    File "${MPLAYER7Z}"
    Nsis7z::Extract ${MPLAYER7Z}
    # Delete ${MPLAYER7Z}

    check_mplayer:
    ;This label does not necessarily mean there was a download error, so check first
    ${If} $R0 != "OK"
      DetailPrint $(MPLAYER_DL_FAILED)
    ${EndIf}

    IfFileExists "$INSTDIR\${MPLAYER}\mplayer.exe" mplayerInstSuccess mplayerInstFailed
      mplayerInstSuccess:
        WriteRegDWORD HKLM "${REGKEY}" Installed_MPlayer 0x1
        Goto done
      mplayerInstFailed:
        MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION $(MPLAYER_DL_RETRY) /SD IDCANCEL IDRETRY retry_mplayer
        WriteRegDWORD HKLM "${REGKEY}" Installed_MPlayer 0x0
        # Allow to continue without this and install mplayer manually later
        # Abort $(MPLAYER_INST_FAILED)
        MessageBox MB_OK  "$(MPLAYER_INST_FAILED)"

    done:
FunctionEnd
  
# Only allow new installs and upgrades
Function CheckPreviousVersion

  ReadRegStr $InstalledVersion HKLM "${REGKEY}" "Version"
  # Not installed, continue with normal installation
  StrCmp "$InstalledVersion" "" 0 +2
      return
        
  /* VersionCompare returns:
  0  This installer is the same version as the installed copy
  1  A newer version than this installer is already installed
  2  An older version than this installer is already installed */
 
  ${VersionCompare} $InstalledVersion ${VIProduct_Ver} $R1
  IntCmp $R1 1 newer same older
  same:
  newer:
    MessageBox MB_OK $(ALREADY_INSTALLED)
    Abort
  older:
    StrCpy $Updating "Yes"   
    
FunctionEnd    
  
