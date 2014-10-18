'----------------------------------------------------------------------------------
' Purpose:      The purpose of this script is create and setup a z-tree development
'               environment.
'
' Requirements: -- Windows XP or greater
'               -- Z-Tree and Z-Leaf binary files.
'
' Folder Structure:
'   -- Z-Tree: The parent development folder
'       -- treatments: Stores the treatment programs
'       -- backups: Stores all of the Z-Tree backup files 
'       -- ztree: Stores Z-Tree.exe and Z-Leaf.exe 
'       -- data: Stores the treatment session data files 
'       -- payoffs: Stores the treatment payoff and address data files 
'
' Author:   Anwar A. Ruff
'
' License:  MIT License 
'----------------------------------------------------------------------------------
Option Explicit
On Error Resume Next


'--
' Copies the source file to the destination folder

' @param sourceFile Source file name
' @param destinationFolder String Absolute path to the destination filder
'
' @return boolean true of file was successfully copied, otherwise false is returned.
'--
Function copyToFolder(sourceFile, destinationFolder)
    Dim FileSystemObject : Set FileSystemObject = CreateObject("Scripting.FileSystemObject")
	FileSystemObject.CopyFile sourceFile, destinationFolder, true
    If Not(FileSystemObject.FileExists(destinationFolder & sourceFile)) Then
        copyToFolder = false
    Else
        copyToFolder = true
    End If
End Function


'--
' Prompts the user to enter their preferred language, for a set of
' supported languages.
'
' @return String The users preferred language
'--
Function getLanguage()
	Const MAX_LANGUAGES = 17
	Const LANGUAGE_OPTION = 0
	Const LANGUAGE = 1
    Dim languages()
	ReDim languages(MAX_LANGUAGES, 1)
	languages(0, LANGUAGE_OPTION) = "en"
	languages(0, LANGUAGE) = "English"
	languages(1, LANGUAGE_OPTION) = "br"
	languages(1, LANGUAGE) = "Brasil"
	languages(2, LANGUAGE_OPTION) = "cat"
	languages(2, LANGUAGE) = "Catalan"
	languages(3, LANGUAGE_OPTION) = "nl"
	languages(3, LANGUAGE) = "Dutch"
	languages(4, LANGUAGE_OPTION) = "fi"
	languages(4, LANGUAGE) = "Finnish"
	languages(5, LANGUAGE_OPTION) = "fr"
	languages(5, LANGUAGE) = "French"
	languages(6, LANGUAGE_OPTION) = "de"
	languages(6, LANGUAGE) = "German"
	languages(7, LANGUAGE_OPTION) = "it"
	languages(7, LANGUAGE) = "Italian"
	languages(8, LANGUAGE_OPTION) = "no"
	languages(8, LANGUAGE) = "Norwegian - Bokmal"
	languages(9, LANGUAGE_OPTION) = "nyno"
	languages(9, LANGUAGE) = "Norwegian - Nynorsk"
	languages(10, LANGUAGE_OPTION) = "pl"
	languages(10, LANGUAGE) = "Polish"
	languages(11, LANGUAGE_OPTION) = "pt"
	languages(11, LANGUAGE) = "Portugues"
	languages(12, LANGUAGE_OPTION) = "ru"
	languages(12, LANGUAGE) = "Russian"
	languages(13, LANGUAGE_OPTION) = "es"
	languages(13, LANGUAGE) = "Spanish"
	languages(14, LANGUAGE_OPTION) = "se"
	languages(14, LANGUAGE) = "Swedish"
	languages(15, LANGUAGE_OPTION) = "zh"
	languages(15, LANGUAGE) = "Swiss German Zurich style"
	languages(16, LANGUAGE_OPTION) = "tr"
	languages(16, LANGUAGE) = "Turkish"
	languages(17, LANGUAGE_OPTION) = "ua"
	languages(17, LANGUAGE) = "Ukraine"

	Dim message, i
    message = "Enter your preferred language from list of languages below:" & vbCrLf
	For i=0 To MAX_LANGUAGES
		message = message & i+1 & ") " & languages(i,1) & vbCrLf
	Next
    message = message & vbCrLf & "The entry must be a number between 1 and 18."

    Dim selectedLanguageId : selectedLanguageId = InputBox(message,"Step 3: Select a Default Language", 1)
     Dim regex : Set regex = New RegExp
	regex.Global = false
	regex.IgnoreCase = true
	regex.Pattern = "([0-9]|1[0-7])"
    If regex.Test(selectedLanguageId) = false Then
        msgbox "You didn't enter a language code, or the one you entered is out of range, so I'll use English as your default language.", vbInformation, "Default Language: English"
        selectedLanguageId = 0
        Exit Function
    End If
    
    getLanguage = languages(CInt(selectedLanguageId)-1, LANGUAGE_OPTION) 
End Function


'--
' Prompts the user to select a file qualified by the file type specified, and returns
' the absolute path to the selected file.
'
' @param defaultDirectory The default directory for the file selector. 
' @param fileTypeFilter The default file filter. String required.
' 
' @return String absolute file path 
'--
Function getPathToSelectedFile( defaultDirectory, fileTypeFilter )
    Dim objDialog
    Set objDialog = CreateObject( "UserAccounts.CommonDialog" )

    If defaultDirectory = "" Then
        objDialog.InitialDir = CreateObject( "WScript.Shell" ).SpecialFolders( "Desktop" )
    Else
        ' Use the specified initial folder
        objDialog.InitialDir = defaultDirectory
    End If

    If fileTypeFilter = "" Then
        ' Default file filter is "All files"
        objDialog.Filter = "All files|*.*"
    Else
        ' Use the specified file filter
        objDialog.Filter = fileTypeFilter
    End If

    If objDialog.ShowOpen Then
        getPathToSelectedFile = objDialog.FileName
    Else
        getPathToSelectedFile = ""
    End If
End Function


'--
' Creates a shortcut from the source file to a specified directory and aliased link name..

' @param sourceFile The source link file 
' @param targetPath The target folder 
' @param linkName The link alias for the source file
' @param shortcutOptions The execution options padded to the source file via the link
' 
' @return boolean true if linked succeeeded, otherwise false is returned 
'--
Function createShortcut(sourceFile, targetPath, linkName, shortcutOptions)
    Dim FileSystemObject : Set FileSystemObject = CreateObject("Scripting.FileSystemObject")
    Dim WSHShell : Set WSHShell = WScript.CreateObject("WScript.Shell")
	
    Dim Shortcut : Set Shortcut = WSHShell.CreateShortcut(targetPath & "\" & linkName)
    Shortcut.TargetPath = sourceFile
    Shortcut.Arguments = shortcutOptions
    Shortcut.WorkingDirectory = targetPath
    Shortcut.WindowStyle = 4
    Shortcut.IconLocation = sourceFile & ", 0"
    Shortcut.Save

    If Not(FileSystemObject.FileExists(targetPath & "\" & linkName)) Then
        createShortcut = false
    Else
        createShortcut = true
    End If
    
End Function


'--
' Returns the absolute path to the selected executable file 

' @param defaultDir The default directory the file selector displays 
' @param fileName The file type to open 
' @param message
' @param messageTitle
' 
' @return boolean true if a file was selected, otherwise false is returned 
'--
Function getExePath(defaultDir, fileName, message, messageTitle)
    msgbox message, vbInformation, messageTitle 
	getExePath = getPathToSelectedFile(defaultDir, fileName & "|*.exe")
End Function


'--
' Creates a folder in the specified directory with the given name. 

' @param path The directory in which to create a new directory 
' @param folderName The name to be used for the newly created folder
' 
' @return boolean true if a folder was created, otherwise false is returned 
'--
Function createFolder(path, folderName)
    Dim FileSystemObject : Set FileSystemObject = CreateObject("Scripting.FileSystemObject")
    ' Create the folder if it doesn't exist
    If Not(FileSystemObject.FolderExists(path & "\" & folderName)) Then
        FileSystemObject.CreateFolder(path & "\" & folderName)
    End If 

    ' Test folder creation
    If Not(FileSystemObject.FolderExists(path & "\" & folderName)) Then
        createFolder = false
    Else
        createFolder = true
    End If 
End Function


'--
' Returns the current folder in which this script is executed 

' @return String The absolute path to the folder in which this script was executed
'--
Function getCurrentPath()
	Dim FileSystemObject : Set FileSystemObject = CreateObject("Scripting.FileSystemObject")
	getCurrentPath = FileSystemObject.GetAbsolutePathName(".") 
End Function

Function generateLeafKillScript(zLeafProgram, zTreeFolder)
    Dim killZLeafScriptName : killZLeafScriptName = "\kill-Zleaves.vbs"
    ' Get the name of the Z-Leaf.exe
    Dim FileSystemObject : Set FileSystemObject = CreateObject("Scripting.FileSystemObject")
    Dim ZLeafFile : set ZLeafFile = FileSystemObject.GetFile(zLeafProgram)
    Dim fileName : fileName = FileSystemObject.GetFileName(ZLeafFile)

    ' Build script to kill leaves
    Dim KillZleafScript : Set KillZleafScript = FileSystemObject.CreateTextFile(zTreeFolder & killZLeafScriptName, True)
    KillZleafScript.WriteLine("Option Explicit")
    KillZleafScript.WriteLine("On Error Resume Next")
    KillZleafScript.WriteLine("Dim wmi : Set wmi = GetObject(""winmgmts:"")")
    KillZleafScript.WriteLine("Dim procs : Set procs= wmi.ExecQuery(""select * from Win32_process where Name='" & fileName & "'"")")
    KillZleafScript.WriteLine("Dim p")
    KillZleafScript.WriteLine("For Each p in procs")
    KillZleafScript.WriteLine("p.Terminate()")
    KillZleafScript.WriteLine("Next")
    KillZleafScript.Close

    If Not(FileSystemObject.FileExists(zTreeFolder & killZLeafScriptName)) Then
        getCurrentPath = false
    Else
        getCurrentPath = true
    End If
End Function


'--
' Executes the build directives requred to create the Z-Tree development environment 
'--
Function main()
	Dim desktopPath : desktopPath = getCurrentPath() 
    ' Get the location of the Z-Tree.exe
    Dim zTreeFileName : zTreeFileName = "Z-Tree.exe"
    Dim zTreeMessage : zTreeMessage = "At the next screen please select the " & zTreeFileName & " program."
    Dim zTreeProgram : zTreeProgram = getExePath(desktopPath, ZTreeFileName, zTreeMessage , "Step 1: Select Z-Tree")
	If zTreeProgram = "" Then
        msgbox "To setup your Z-Tree programming environment I need to know the location of the Z-Tree.exe program, in order to copy it into your development folder." & vbCrLf &_
        " If you don't have Z-Tree you can find out how to get it at www.iew.uzh.ch/ztree/howtoget.php", vbCritical, "Error"
		main = false
        Exit Function
	End If

    ' Get the location of the Z-Tree.exe
    Dim zLeafFileName : zLeafFileName = "Z-Leaf.exe"
    Dim zLeafMessage : zLeafMessage = "At the next screen please select the " & zLeafFileName & " program."
    Dim zLeafProgram : zLeafProgram = getExePath(desktopPath, zLeafFileName, zLeafMessage, "Step 2: Select Z-Leaf") 
	If zLeafProgram = "" Then
        msgbox "To setup your Z-Tree programming environment I need to know the location of the Z-Leaf.exe program, in order to copy it into your development folder." & vbCrLf &_ 
        " If you don't have Z-Tree you can find out how to get it at www.iew.uzh.ch/ztree/howtoget.php", vbCritical, "Error"
		main = false
        Exit Function
	End If

    Dim language : language = getLanguage()

	' Create the Z-Tree Folder on the Desktop
	If Not(createFolder(desktopPath, "Z-Tree")) Then
		msgbox "I wasn't able to create the Z-Tree directory. Please make sure you have permission to modify this directory.", vbCritical, "Error"
		main = false
        Exit Function
    End If

    ' Create Z-Tree sub-folders
    Dim zTreeFolder : zTreeFolder = desktopPath & "\Z-Tree"
    Dim zTreeSubDirectories : zTreeSubDirectories = Array("backups", "treatments", "ztree", "payoffs", "data")
    Dim folder
    For Each folder In zTreeSubDirectories
        If Not(createFolder(zTreeFolder, folder)) Then
            msgbox "I wasn't able to create the Z-Tree directory. Please make sure you have permission to modify that directory.", vbCritical, "Error"
            main = false
            Exit Function
        End If
    Next

	' Copy the Z-Tree ztree folder
	If Not(copyToFolder(zTreeProgram, zTreeFolder & "\ztree\")) Then
        msgbox "I wasn't able to copy " & zTreeProgram & " to " & zTreeFolder & "\ztree\" & ". Please check your directory and file permissions.", vbCritical, "Error"
        main = false
        Exit Function
    End If

	' Copy the Z-Leaf ztree folder
	If Not(copyToFolder(zLeafProgram, zTreeFolder & "\ztree\")) Then
        msgbox "I wasn't able to copy " & zLeafProgram & " to " & zTreeFolder & "\ztree\" & ". Please check your directory and file permissions.", vbCritical, "Error"
        main = false
        Exit Function
    End If

	' Create the Z-Tree shortcut
    Dim zTreeOptions : zTreeOptions =  "/datadir .\data /leafdir .\data /privdir .\payoffs /gsfdir .\backups /tempdir .\backups /language " & language
    If Not(createShortcut(zTreeProgram, zTreeFolder, "tree.lnk", zTreeOptions)) Then
        msgbox "I wasn't able to the Z-Tree shortcut from " & zTreeProgram & " to " & zTreeFolder & "\tree.lnk. Please check your directory and file permissions.", vbCritical, "Error"
        main = false
        Exit Function
    End If

    Dim i, x, y, xIncrement, yIncrement, zLeafOptions
    x = 0
    y = 0
    xIncrement = 640
    yIncrement = 480
    For i = 0 To 3 
        zLeafOptions =  "/name player" & i+1 & " /language " & language & " /size " & xIncrement & "x" & yIncrement & " /position " & x & "," & y
        If Not(createShortcut(zLeafProgram, zTreeFolder, "leaf" & i+1 & ".lnk", zLeafOptions)) Then
            msgbox "I wasn't able to the Z-Leaf shortcut from " & zTreeProgram & " to " & zTreeFolder & "\leaf" & i+1 & ".lnk. Please check your directory and file permissions.", vbCritical, "Error"
            main = false
            Exit Function
        End If

        If (i+1) Mod 2 = 0 Then
            x = 0
            y = y + yIncrement
        Else
            x = x + xIncrement
        End If
    Next
    
    If Not(generateLeafKillScript(zLeafProgram, zTreeFolder)) Then
        msgbox "I wasn't able to create your kill-zleaves script. Please check that your directory and file permission.", vbCritical, "Error"
        main = false
        Exit Function
    End If

    main = true
End Function

Dim result : result = main()

If result Then
    msgbox "I just succesfully setup your Z-Tree development environment for you. A description of the folder layout and how to use it can be found at to www.learnztree.com.", vbInformation, "You're All done!"
Else
    msgbox "Oops! It looks like I couldn't setup your Z-Tree development environment.", vbCritical, "Oops! Something went wrong with the setup."
End If
