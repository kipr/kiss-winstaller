; Header for Modern UI
!include "MUI.nsh"

; Header for using RunningX64 macro
!include "x64.nsh"

; Driver installer utility flies
!include "nsis-lib\winver.nsh"
!include "nsis-lib\drvsetup.nsh"
!include "nsis-lib\windrvinstall.nsh"

; Define KISS application name and version number
!define APP_NAME "KISS Platform"
!define APP_MAJOR_VERSION "5"
!define APP_MINOR_VERSION "1"
!define BUILD_NUMBER "5"

; Standard Release app name and version
!define VERSION "${APP_MAJOR_VERSION}.${APP_MINOR_VERSION}.${BUILD_NUMBER}"
!define INSTALLER_FILENAME "KISS-Platform-${VERSION}"
!define APP_NAME_AND_VERSION "${APP_NAME} ${VERSION}"

; Ensure that directories have been defined
!ifndef DEPLOY_DIR
	!error "DEPLOY_DIR must be defined!"
!endif
!ifndef MINGW_DIR
	!error "MINGW_DIR must be defined!"
!endif
!ifndef LIBKOVAN_DOCS_DIR
	!error "LIBKOVAN_DOCS_DIR must be defined!"
!endif
!ifndef LINK_DOCS_DIR
	!error "LINK_DOCS_DIR must be defined!"
!endif
!ifndef XTION_DRIVER_DIR
	!error "XTION_DRIVER_DIR must be defined!"
!endif
!ifndef OUT_DIR
	!error "OUT_DIR must be defined!"
!endif

; Name of the installer
Name "${APP_NAME_AND_VERSION}"

; Path to final install directory
InstallDir "$PROGRAMFILES\${APP_NAME_AND_VERSION}"

; Path to the installer itself
OutFile "${OUT_DIR}\${INSTALLER_FILENAME}.exe"

; Modern interface settings
!define MUI_ICON "windows_icon.ico"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "$INSTDIR\KISS\KISS.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Run KISS IDE now"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "License.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

Section "KISS Platform" KISSPlatform
	; Set Section properties
	SetOverwrite on  ; overwrite existing files
	SectionIn RO     ; cannot be unchecked  
  	
	; Set KISS Platform Files
	SetOutPath "$INSTDIR\KISS\"
	File /r "${DEPLOY_DIR}\*.*"
	File "windows_icon.ico"
	!define KISS_ICON "$INSTDIR\KISS\windows_icon.ico"

	; Set up start menu entry
	CreateDirectory  "$SMPROGRAMS\${APP_NAME_AND_VERSION}"
	CreateShortCut "$SMPROGRAMS\${APP_NAME_AND_VERSION}\KISS IDE ${VERSION}.lnk" "$INSTDIR\kiss\kiss.exe" "" ${KISS_ICON} 0

	; Set up desktop shortcut
	CreateShortCut "$DESKTOP\KISS IDE ${VERSION}.lnk" "$INSTDIR\KISS\kiss.exe" "" ${KISS_ICON} 0
SectionEnd

Section "MinGW" MinGW
	; Set Section properties
	SetOverwrite on  ; overwrite existing files
	SectionIn RO     ; cannot be unchecked  
  	
	; Set MinGW Files	
	SetOutPath "$INSTDIR\MinGW\"
	File /r "${MINGW_DIR}\*.*"
SectionEnd

Section "libkovan Documentation" libkovan_doc
	; Set Section properties
	SetOverwrite on  ; overwrite existing files
  	
	; Set libkovan Documentation Files	
	SetOutPath "$INSTDIR\KISS\docs\libkovan\"
	File /r "${LIBKOVAN_DOCS_DIR}\*.*"
SectionEnd

Section "Link Documentation" link_doc
	; Set Section properties
	SetOverwrite on  ; overwrite existing files
  	
	; Set Link Documentation Files	
	SetOutPath "$INSTDIR\KISS\docs\KIPR Link C Standard Library\"
	File /r "${LINK_DOCS_DIR}\KIPR Link C Standard Library\*.*"
SectionEnd

Section "Link Driver" linkDriver
	SetOutPath "$INSTDIR\LinkDriver"

	File kiprlink.inf

	; The directory of the .inf file
	Push "$INSTDIR\LinkDriver"
	; The filepath of the .inf file
	Push "$INSTDIR\LinkDriver\kiprlink.inf"
	; The HID (Hardware ID) of the device
	Push "USB\VID_0525&PID_A4A7"

	Call InstallUpgradeDriver
SectionEnd

Section "Xtion Driver" xtionDriver
	SetOutPath "$INSTDIR\XtionDriver"
	File /r "${XTION_DRIVER_DIR}\*.*"
	${If} ${RunningX64}
		ExecWait "$INSTDIR\XtionDriver\dpinst-amd64.exe"
	${Else}
		ExecWait "$INSTDIR\XtionDriver\dpinst-x86.exe"
	${EndIf}
SectionEnd

Section "Visual C++ Redistributable 2013" VCRedist2013
	SetOutPath $INSTDIR
    File "vcredist_x86.exe"
    ExecWait "$INSTDIR\vcredist_x86.exe"
SectionEnd

Section "Visual C++ Redistributable 2012" VCRedist2012
	SetOutPath $INSTDIR
    File "vcredist_x86_2012.exe"
    ExecWait "$INSTDIR\vcredist_x86_2012.exe"
SectionEnd

Section "Visual C++ Redistributable 2010" VCRedist2010
	SetOutPath $INSTDIR
    File "vcredist_x86_2010.exe"
    ExecWait "$INSTDIR\vcredist_x86_2010.exe"
SectionEnd

Section -FinishSection
	WriteRegStr HKLM "Software\${APP_NAME_AND_VERSION}" "" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME_AND_VERSION}" "DisplayName" "${APP_NAME_AND_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME_AND_VERSION}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

; Modern install component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${VCRedist2013} "Visual C++ Redistributable for Visual Studio 2013"
!insertmacro MUI_DESCRIPTION_TEXT ${VCRedist2012} "Visual C++ Redistributable for Visual Studio 2012 Update 3"
!insertmacro MUI_DESCRIPTION_TEXT ${VCRedist2010} "Visual C++ Redistributable for Visual Studio 2010"
!insertmacro MUI_DESCRIPTION_TEXT ${KISSPlatform} "KIPR's Instructional Software System IDE and target"
!insertmacro MUI_DESCRIPTION_TEXT ${MinGW} "Minimalist GNU for Windows"
!insertmacro MUI_DESCRIPTION_TEXT ${link_doc} "Documentation for the KIPR Link"
!insertmacro MUI_DESCRIPTION_TEXT ${libkovan_doc} "Documentation for the libkovan standard library"
!insertmacro MUI_DESCRIPTION_TEXT ${linkDriver} "Windows driver for communication with the KIPR Link"
!insertmacro MUI_DESCRIPTION_TEXT ${xtionDriver} "Windows driver for the ASUS Xtion Pro sensor"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstall section
Section Uninstall
	; Remove keys from registry
	DeleteRegKey HKLM "SOFTWARE\${APP_NAME_AND_VERSION}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME_AND_VERSION}"

	; Delete the uninstaller itself
	Delete "$INSTDIR\uninstall.exe"

	; Delete start menu entires and desktop shortcuts
	Delete "$DESKTOP\KISS IDE ${VERSION}.lnk"
	Delete "$SMPROGRAMS\${APP_NAME_AND_VERSION}\KISS IDE ${VERSION}.lnk"
	RMDir  "$SMPROGRAMS\${APP_NAME_AND_VERSION}"

	; Delete the entire install directory
	RMDir /r "$INSTDIR\"
SectionEnd

BrandingText "KISS Institute For Practical Robotics"