# Microsoft Developer Studio Project File - Name="cleaner" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=cleaner - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "cleaner.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "cleaner.mak" CFG="cleaner - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "cleaner - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "cleaner - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "cleaner - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x413 /d "NDEBUG"
# ADD RSC /l 0x413 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386 /out:"cleaner.exe"

!ELSEIF  "$(CFG)" == "cleaner - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x413 /d "_DEBUG"
# ADD RSC /l 0x413 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /out:"cleaner.exe" /pdbtype:sept
# SUBTRACT LINK32 /pdb:none
# Begin Custom Build
TargetName=cleaner
InputPath=.\cleaner.exe
InputName=cleaner
SOURCE="$(InputPath)"

"Debug\$(TargetName)" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	\masm32\bin\rc /v $(InputName)rs.rc 
	\masm32\bin\cvtres /machine:ix86 $(InputName)rs.res 
	\masm32\bin\h2inc resource.h 
	\MASM32\BIN\Ml.exe /nologo /c /coff $(InputName).asm 
	\MASM32\BIN\Link.exe /nologo /SUBSYSTEM:WINDOWS /DEBUG $(InputName).obj $(InputName)rs.obj 
	
# End Custom Build

!ENDIF 

# Begin Target

# Name "cleaner - Win32 Release"
# Name "cleaner - Win32 Debug"
# Begin Source File

SOURCE=.\cleaner.asm

!IF  "$(CFG)" == "cleaner - Win32 Release"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
TargetName=cleaner
InputPath=.\cleaner.asm
InputName=cleaner

"Release\$(TargetName)" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	\masm32\bin\rc /v $(InputName)rs.rc 
	\masm32\bin\cvtres /machine:ix86 $(InputName)rs.res 
	\masm32\bin\h2inc resource.h 
	\MASM32\BIN\Ml.exe /nologo /c /coff  $(InputName).asm 
	\MASM32\BIN\Link.exe /nologo /SUBSYSTEM:WINDOWS /OUT:Release\$(TargetName).exe $(InputName).obj $(InputName)rs.res 
	
# End Custom Build

!ELSEIF  "$(CFG)" == "cleaner - Win32 Debug"

# PROP Ignore_Default_Tool 1
# Begin Custom Build
TargetName=cleaner
InputPath=.\cleaner.asm
InputName=cleaner

"Debug\$(TargetName)" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	\masm32\bin\rc /v $(InputName)rs.rc 
	\masm32\bin\cvtres /machine:ix86 $(InputName)rs.res 
	\masm32\bin\h2inc resource.h 
	\MASM32\BIN\Ml.exe /nologo /c /coff $(InputName).asm 
	\MASM32\BIN\Link.exe /nologo /SUBSYSTEM:WINDOWS /DEBUG $(InputName).obj $(InputName)rs.obj 
	
# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\cleanerrs.rc
# PROP Exclude_From_Build 1
# End Source File
# Begin Source File

SOURCE=.\resource.h
# End Source File
# Begin Source File

SOURCE=.\Res\Stop.Ico
# End Source File
# Begin Source File

SOURCE=.\string.inc
# End Source File
# End Target
# End Project
