;  Copyright (c) 2016 Engimusing LLC.  All right reserved.
;
;  This library is free software; you can redistribute it and/or
;  modify it under the terms of the GNU Lesser General Public
;  License as published by the Free Software Foundation; either
;  version 2.1 of the License, or (at your option) any later version.
;
;  This library is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;  See the GNU Lesser General Public License for more details.
;
;  You should have received a copy of the GNU Lesser General Public
;  License along with this library; if not, write to the Free Software
;  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
;Application information settings
AppId={{7A382C93-F240-445E-9A4B-2D7738A15A7A}
AppName=Engimusing Tools
AppVersion=1.0
AppVerName=Engimusing Tools 1.0
AppPublisher=Engimusing
AppPublisherURL=https://www.engimusing.com/
AppSupportURL=https://www.engimusing.com/
AppUpdatesURL=https://www.engimusing.com/

;setup configuration 
OutputDir=.\
OutputBaseFilename=EngimusingToolsSetup
SetupIconFile=.\favicon.ico
WizardImageFile=.\LargerIcon.bmp
WizardSmallImageFile=.\logo.bmp
WizardImageStretch=yes
Compression=lzma
SolidCompression=yes
ChangesEnvironment=yes
DisableProgramGroupPage=yes
CreateAppDir=no

;include for file download support
#include <idp.iss>

;defines to build for testing. Both should be defined for installers that are to be distributed
#define USE_TEMP_FOLDER
#define DOWNLOAD_FILES


[Components]
;these components are not user changable on the components page but setup based on user choices before the components page
Name: mosquitto;  Description: "mosquitto (Download Required)"; Flags: disablenouninstallwarning; ExtraDiskSpaceRequired: 600000; 
Name: openhab; Description: "openHAB (Download Required)"; Flags: disablenouninstallwarning; ExtraDiskSpaceRequired: 58720256
Name: smarthomedesigner;  Description: "SmartHome Designer (Download Required)"; Flags: disablenouninstallwarning; ExtraDiskSpaceRequired: 122667965 
Name: serial2mqtt;  Description: "Engimusing Tools"; Flags: disablenouninstallwarning; 
 
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
;task for the desktop icon folder
Name: desktopicon; Description: "Create Engimusing Tools Folder on Desktop"; GroupDescription: "Desktop icons:"; 

[Dirs]
;desktop folder and engimusing tools folder setup
Name: "{commondesktop}\Engimusing Tools"; Tasks: desktopicon; Permissions: everyone-full
Name: "{code:GetEmusToolsDir}\Serial2Mqtt"; Permissions: everyone-full

[Icons]
;icons which will be created if the desktopicon task is enabled
Name: "{commondesktop}\Engimusing Tools\Mosquitto"; Filename: "{code:GetMosquittoDir}\Mosquitto.exe"; Parameters: "-c emus_mosquitto.conf"; WorkingDir: "{code:GetMosquittoDir}"; Tasks: desktopicon; IconFilename: "{code:GetMosquittoDir}\MosquittoIcon.ico"
Name: "{commondesktop}\Engimusing Tools\OpenHab"; Filename: "{code:GetOpenHabDir}\Start.bat"; WorkingDir: "{code:GetOpenHabDir}"; Tasks: desktopicon; IconFilename: "{code:GetOpenHabDir}\openHab.ico"
Name: "{commondesktop}\Engimusing Tools\SmartHome"; Filename: "{code:GetSmartHomeDir}\SmartHome-Designer.exe"; WorkingDir: "{code:GetSmartHomeDir}"; Tasks: desktopicon
Name: "{commondesktop}\Engimusing Tools\Serial2MqttSetup"; Filename: "{code:GetEmusToolsDir}\Serial2Mqtt\EFM_Serial2Mqtt_Setup.bat"; WorkingDir: "{code:GetEmusToolsDir}\Serial2Mqtt"; Tasks: desktopicon; IconFilename: "{code:GetEmusToolsDir}\favicon.ico"
Name: "{commondesktop}\Engimusing Tools\Serial2MqttRun"; Filename: "{code:GetEmusToolsDir}\Serial2Mqtt\EFM_Serial2Mqtt_Saved.bat"; WorkingDir: "{code:GetEmusToolsDir}\Serial2Mqtt"; Tasks: desktopicon; IconFilename: "{code:GetEmusToolsDir}\favicon.ico"


[Run]
;open the engimusing tools folder at the end of the installer if the user wants to
FileName: "explorer.exe"; Description: "Open Engimusing Tools Folder"; Parameters: "{commondesktop}\Engimusing Tools"; Tasks: desktopicon; Flags: postinstall


[Files]
;icon files for the shortcuts
Source: "favicon.ico"; DestDir: "{code:GetEmusToolsDir}"; 
Source: "MosquittoIcon.ico"; DestDir: "{code:GetMosquittoDir}";
Source: "openHab.ico"; DestDir: "{code:GetOpenHabDir}";

;dummy files to run installers for the components
Source: "favicon.ico"; DestDir: "{tmp}"; BeforeInstall: updateEnvironmentVars(); 
Source: "favicon.ico"; DestDir: "{tmp}"; BeforeInstall: InstallMosquitto(); Components: mosquitto
Source: "favicon.ico"; DestDir: "{tmp}"; BeforeInstall: InstallOpenHab(); Components: openhab
Source: "favicon.ico"; DestDir: "{tmp}"; BeforeInstall: InstallEclipseSmartHome(); Components: smarthomedesigner


;OpenHab configuration files.
Source: "openhabConfig\services\*"; DestDir: "{code:GetOpenHabDir}\conf\services"; Components: openhab; Permissions: everyone-full

;Mosquitto configuration files.
Source: "mosquittoConfig\*"; DestDir: "{code:GetMosquittoDir}\"; Permissions: everyone-full

;Serial2MQTT files
Source: "..\..\arduinoIDE\tools\EFM_Serial2Mqtt\windows\*"; DestDir: "{code:GetEmusToolsDir}\Serial2Mqtt\"; Flags: recursesubdirs; Components: serial2mqtt; Permissions: everyone-full

[Messages]
;custom versions of the messages to improve how the setup works
WizardSelectComponents=Components to Install
SelectComponentsDesc=
SelectComponentsLabel2=The checked items below will be installed. If you would like to change which items are installed go back. 
ComponentsDiskSpaceMBLabel=
InstallingLabel=Now installing [name] on your computer.

[Code]
//Code for setting up the custom pages in the Setup GUI and the downloads
// There are 5 custom pages in order to setup the directories for:
//  Mosquitto
//  OpenHAB
//  SmartHome
//  EngimusingTools
//  Java
// The Mosquitto page allows the user to specify where mosquitto is already installed or 
//    the option to have this installer download and install mosquitto
// The OpenHAB page allows the user to specify where openHAB is already installed or 
//    to specify a directory for this installer to install OpenHAB
// The SmartHome page allows the user to specify where SmartHome is already installed or 
//    to specify a directory for this installer to install SmartHome
// The EngimusingTools page allows the user to specify where the Engimusing tools are already installed or 
//    to specify a directory for this installer to install the Engimusing tools
// The JAVA page allows the user to point to a JAVA installation with instructions on where to find it if they don't 
//    already have it installed

//There is also code here to setup a welcome page and to setup the download links and mirrors for Mosquitto, OpenHAB, and SmartHome
var
  //Variables for everything

  // used on the install page to let the users know what is being unzipped
  UnzippingLabel: TNewStaticText; 
  //Page for welcoming the user and explaining what this will install
  WelcomeMessagePage:  TOutputMsgWizardPage;
  
  //mosquitto page related variables
  MosquittoPage: TInputDirWizardPage;
  MosquittoUsePreviousInstall: Boolean;
  MosquittoInstalledAndFoundDirectory: Boolean;
  MosquittoInstallDirectory: String;
  MosquittoIsDirEmpty: Boolean;
  MosquittoOptionCheckBox: TNewCheckBox;
  
  //openHab page related variables
  OpenHabPage: TInputDirWizardPage;
  OpenHabUsePreviousInstall: Boolean;
  OpenHabInstalledAndFoundDirectory: Boolean;
  OpenHabInstallDirectory: String;
  OpenHabIsDirEmpty: Boolean;
  OpenHabOptionCheckBox: TNewCheckBox;
  
  //Smarthome page related variables
  SmartHomePage: TInputDirWizardPage;
  SmartHomeUsePreviousInstall: Boolean;
  SmartHomeInstalledAndFoundDirectory: Boolean;
  SmartHomeInstallDirectory: String;
  SmartHomeIsDirEmpty: Boolean;
  SmartHomeOptionCheckBox: TNewCheckBox;
  
  //Engimusing tools page related variables
  EmusToolsPage: TInputDirWizardPage;
  EmusToolsUsePreviousInstall: Boolean;
  EmusToolsInstalledAndFoundDirectory: Boolean;
  EmusToolsInstallDirectory: String;
  EmusToolsIsDirEmpty: Boolean;
  EmusToolsOptionCheckBox: TNewCheckBox;

  //JavaPage related variables
  JavaPage: TInputDirWizardPage;
  JavaHomeAlreadySetup: Boolean;
  JavaHomeSetup: Boolean;
  JavaHomeDirectory: String;
  JavaOptionCheckBox: TNewCheckBox;
  
  //used to hold the original next button event
  Old_WizardForm_NextButton_OnClick: TNotifyEvent;

const
  //constants for windows copy function
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_RESPONDYESTOALL = 16;

  //constants for component arrays
  MOSQUITTO_COMPONENT = 0;
  OPENHAB_COMPONENT = 1;
  SMARTHOME_COMPONENT = 2;
  EMUSTOOLS_COMPONENT = 3;

//procedure for unzipping a file into the targetPath
procedure UnZip(ZipPath, TargetPath: string); 
var
   ShellObj, SrcFile, DestFolder: Variant;
begin
  ShellObj := CreateOleObject('Shell.Application');

  SrcFile := ShellObj.NameSpace(ExpandConstant(ZipPath));
  CreateDir(ExpandConstant(TargetPath));
  DestFolder := ShellObj.NameSpace(ExpandConstant(TargetPath));
  
  //This will pause the installer until it finishes
  // use the unzipping label to let users know it may be a few minutes before the installer finishes.
  //The reason this is so slow is because of the Windows Defender (or other antivirus) scan of the results of the unzip 
  DestFolder.CopyHere(SrcFile.Items, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
end;

//Hack to get around next button validation for dir pages
procedure WizardForm_NextButton_OnClick(Sender: TObject);
var 
  MosquittoPreviousDirEntry: String;
begin
    MosquittoIsDirEmpty := False;
    //An empty directory is fine for the Mosquitto Page so lets get it to pass validation
    if (WizardForm.CurPageID = MosquittoPage.ID) and not DirExists(MosquittoPage.Values[0]) then
    begin
        MosquittoIsDirEmpty := True;
        MosquittoPreviousDirEntry := MosquittoPage.Values[0];
        MosquittoPage.Values[0] := ExpandConstant('{sd}\'); // Force value to pass validation
    end;

    Old_WizardForm_NextButton_OnClick(Sender);

    if MosquittoIsDirEmpty then
        MosquittoPage.Values[0] := MosquittoPreviousDirEntry;

end;

//Event for checkbox on mosquitto page
// sets up the enable state for the components based on the checkbox
procedure onClickMosquitto(Sender: TObject);
begin
      MosquittoPage.Edits[0].Enabled := MosquittoOptionCheckBox.Checked;
      MosquittoPage.Buttons[0].Enabled := MosquittoOptionCheckBox.Checked;
end;

//setup the initial state for the mosquitto page
procedure onActivateMosquittoPage(Sender: TWizardPage);
begin
   MosquittoOptionCheckBox.Visible := true;
   MosquittoOptionCheckBox.Caption := 'Use Mosquitto Install Specified Above';
   MosquittoOptionCheckBox.OnClick := @onClickMosquitto;
end;

//hide the mosquitto checkbox if we go back
function onBackMosquittoPage(Sender: TWizardPage): Boolean;
begin
   MosquittoOptionCheckBox.Visible := false;
   Result := True;
end;

//hide the mosquitto checkbox if we go forward 
// and validate the Mosquitto installation directory
function onNextMosquittoPage(Sender: TWizardPage): Boolean;
begin
  MosquittoUsePreviousInstall := False;
  MosquittoInstallDirectory := '';
  if(MosquittoOptionCheckBox.Checked and not FileExists(MosquittoPage.Values[0] + '\mosquitto.exe'))then
  begin
      Result := False;
      if(MosquittoIsDirEmpty) then
      begin 
        MosquittoPage.Values[0] := '';
      end
      MsgBox('Specified folder is not a valid mosquitto installation.' + #13'Please specify valid mosquitto install or uncheck checkbox.' , mbError, MB_OK);
  end
  else
  begin
    
    if(MosquittoOptionCheckBox.Checked)then
    begin
      WizardForm.ComponentsList.ItemEnabled[MOSQUITTO_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[MOSQUITTO_COMPONENT] := false;
      MosquittoUsePreviousInstall := True;
      MosquittoInstallDirectory := MosquittoPage.Values[0];
    end
    else
    begin
      WizardForm.ComponentsList.ItemEnabled[MOSQUITTO_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[MOSQUITTO_COMPONENT] := true;
    end
    MosquittoOptionCheckBox.Visible := false;
    MosquittoOptionCheckBox.OnClick := nil;
    Result := True;
  end; 
end;

//setup the mosquitto build page which includes checking for a previously installed mosquitto installation
procedure BuildMosquittoSetupPage();
var
  ErrorCode: Integer;
  VersionString: TArrayOfString; 
  SubCaptionString: String;
  MosquittoDir: String;
begin
      if(FileExists(ExpandConstant('{%MOSQUITTO_DIR}\mosquitto.exe'))) then
      begin
         MosquittoDir := ExpandConstant('{%MOSQUITTO_DIR}');
         ShellExec('', 'cmd.exe','/c ' + ExpandConstant('{%MOSQUITTO_DIR}\mosquitto.exe') + ' -h > ' + ExpandConstant('{tmp}') + '\mosquittoVersion.txt','', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
         if(LoadStringsFromFile(ExpandConstant('{tmp}') + '\mosquittoVersion.txt', VersionString))then
         begin
              SubCaptionString := 'Found Mosquitto Installation Here:'#13 + ExpandConstant('{%MOSQUITTO_DIR}') + #13'Version:' + VersionString[0] + #13'This Installer will install version 1.4.10';
              MosquittoOptionCheckBox.Checked := True;
         end
         else
         begin
            SubCaptionString := 'Found Mosquitto Installation Here:'#13 + ExpandConstant('{%MOSQUITTO_DIR}') + #13'But unable to verify version, we suggest installing version 1.4.10 which is included in this installer.'#13;
            MosquittoOptionCheckBox.Checked := False;
         end;
      end
      else 
      begin
          MosquittoDir := '';
          SubCaptionString := 'No Mosquitto Installation found.' + #13'Specify mosquitto installation or continue to install version 1.4.10.'#13#13;
          MosquittoOptionCheckBox.Checked := False;
      end;

      MosquittoPage := CreateInputDirPage(WelcomeMessagePage.ID,
          'Mosquitto Installation', '',
          SubCaptionString,
          False, '');
      MosquittoPage.Add('Currently Installed Mosquitto Directory:');
      MosquittoPage.Values[0] := MosquittoDir;
      MosquittoPage.OnActivate := @onActivateMosquittoPage;
      MosquittoPage.OnNextButtonClick := @onNextMosquittoPage;
      MosquittoPage.OnBackButtonClick := @onBackMosquittoPage;

      MosquittoPage.Edits[0].Enabled := MosquittoOptionCheckBox.Checked;
      MosquittoPage.Buttons[0].Enabled := MosquittoOptionCheckBox.Checked;

      MosquittoInstalledAndFoundDirectory := False;
end;

//install mosquitto by running the downloaded installer
procedure InstallMosquitto();
var
  ErrorCode: Integer;
begin
UnzippingLabel.Visible := True;
UnzippingLabel.Caption := 'Running mosquitto-1.4.10-install-win32.exe installer.'#13 + 'Please finish the mosquitto installer.'; 
    
#ifdef USE_TEMP_FOLDER    
ShellExec('',ExpandConstant('{tmp}\mosquitto-1.4.10-install-win32.exe'),'', '', SW_SHOW, ewWaitUntilTerminated, ErrorCode);
#else
ShellExec('','D:\emus2016\EngimusingInstaller\mosquitto-1.4.10-install-win32.exe','', '', SW_SHOW, ewWaitUntilTerminated, ErrorCode);
#endif

UnzippingLabel.Visible := False;   


if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
     'MOSQUITTO_DIR', MosquittoInstallDirectory) then
begin
    // Failed to find MOSQUITTO_DIR variable
    MsgBox('Moquitto Install May Have Failed.'#13 + 'Unable to find MOQUITTO_DIR system variable.', mbInformation, MB_OK);
end
else
begin
  MosquittoInstalledAndFoundDirectory := True;
end;

end;

//event for openhab checkbox page
// sets up the Directory selection text box label
procedure onClickOpenHab(Sender: TObject);
begin
   if(OpenHabOptionCheckBox.Checked)then
    begin
      OpenHabPage.PromptLabels[0].Caption := 'Currently Installed OpenHab Directory:';
    end
    else
    begin
      OpenHabPage.PromptLabels[0].Caption := 'Install OpenHab Here:';
    end
end;

//initial setup of open hab page
procedure onActivateOpenHabPage(Sender: TWizardPage);
begin
   OpenHabOptionCheckBox.Visible := true;
   OpenHabOptionCheckBox.Caption := 'Skip Install and Use Directory Above';
   OpenHabOptionCheckBox.OnClick := @onClickOpenHab;
end;

//hide the checkbox if we go back
function onBackOpenHabPage(Sender: TWizardPage): Boolean;
begin
   OpenHabOptionCheckBox.Visible := false;
   Result := True;
end;

//validate the results of the openHab page
function onNextOpenHabPage(Sender: TWizardPage): Boolean;
begin
  OpenHabUsePreviousInstall := False;
  OpenHabInstallDirectory := '';
  if(OpenHabOptionCheckBox.Checked and not FileExists(OpenHabPage.Values[0] + '\start.bat'))then
  begin
      Result := False;
      if(OpenHabIsDirEmpty) then
      begin 
        OpenHabPage.Values[0] := '';
      end
      MsgBox('Specified folder is not a valid OpenHab installation.' + #13'Please specify valid OpenHab install or uncheck checkbox.' , mbError, MB_OK);
  end
  else
  begin
    
    if(OpenHabOptionCheckBox.Checked)then
    begin
      WizardForm.ComponentsList.ItemEnabled[OPENHAB_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[OPENHAB_COMPONENT] := false;
      OpenHabUsePreviousInstall := True;
      OpenHabInstallDirectory := OpenHabPage.Values[0];
    end
    else
    begin
      WizardForm.ComponentsList.ItemEnabled[OPENHAB_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[OPENHAB_COMPONENT] := true;
      OpenHabInstallDirectory := OpenHabPage.Values[0];
    end
    OpenHabOptionCheckBox.Visible := false;
    OpenHabOptionCheckBox.OnClick := nil;
    Result := True;
  end; 
end;

//check for a previous install of openHAB and create the page accordingly
procedure BuildOpenHabSetupPage();
var
  ErrorCode: Integer;
  VersionString: TArrayOfString; 
  SubCaptionString: String;
  OpenHabDir: String;
begin
      if(FileExists(ExpandConstant('{%EMUS_OPENHAB_DIR}\start.bat'))) then
      begin
         OpenHabDir := ExpandConstant('{%EMUS_OPENHAB_DIR}');
         if(LoadStringsFromFile(ExpandConstant('{%EMUS_OPENHAB_DIR}\userdata\etc\version.properties'), VersionString) and (GetArrayLength(VersionString) > 7))then
         begin
              SubCaptionString := 'Found OpenHab Installation Here:'#13 + ExpandConstant('{%EMUS_OPENHAB_DIR}') + #13'Version:' + VersionString[7] + #13'This Installer will install version 2.0.0 ';
              OpenHabOptionCheckBox.Checked := True;                                                                                                                                           
         end
         else
         begin
            SubCaptionString := 'Found OpenHab Installation Here:'#13 + ExpandConstant('{%EMUS_OPENHAB_DIR}') + #13'But unable to verify version, we suggest installing version 2.0.0 which is included in this installer.'#13;
            OpenHabOptionCheckBox.Checked := False;
         end;
      end
      else 
      begin
          SubCaptionString := 'No OpenHab Installation found.'#13 + 'Specify previous OpenHab installation directory or path to install version 2.0.0.'#13#13;
          OpenHabOptionCheckBox.Checked := False;
          OpenHabDir := ExpandConstant('{pf}\openHab');
      end;

      OpenHabPage := CreateInputDirPage(MosquittoPage.ID,
          'OpenHab Installation', '',
          SubCaptionString,
          False, '');
      if(OpenHabOptionCheckBox.Checked)then
      begin
        OpenHabPage.Add('Currently Installed OpenHab Directory:');
      end
      else
      begin
        OpenHabPage.Add('Install OpenHab Here:');
      end
      OpenHabPage.Values[0] := OpenHabDir;
      OpenHabPage.OnActivate := @onActivateOpenHabPage;
      OpenHabPage.OnNextButtonClick := @onNextOpenHabPage;
      OpenHabPage.OnBackButtonClick := @onBackOpenHabPage;


      OpenHabInstalledAndFoundDirectory := False;
end;


//install openhab by unzipping the downloaded zip file
procedure InstallOpenHAB();
begin
UnzippingLabel.Visible := True;
UnzippingLabel.Caption := 'Unzipping openhab-2.0.0.zip into:'#13 + OpenHabInstallDirectory + #13'Be patient as this can take up to 10 minutes'; 
    

#ifdef USE_TEMP_FOLDER    
      UnZip('{tmp}\openhab-2.0.0.zip', OpenHabInstallDirectory);
#else
      UnZip('D:\emus2016\EngimusingInstaller\openhab-2.0.0.zip', OpenHabInstallDirectory);
#endif


UnzippingLabel.Visible := False;     
end;

//functions for getting the final values for the install directories
function GetOpenHabDir(Dummy: string): string;
begin
   Result := OpenHabInstallDirectory;
end;

function GetMosquittoDir(Dummy: string): string;
begin
   Result := MosquittoInstallDirectory;
end;

function GetSmartHomeDir(Dummy: string): string;
begin
   Result := SmartHomeInstallDirectory;
end;


//setup the caption based on the checkbox value
procedure onClickSmartHome(Sender: TObject);
begin  
    if(SmartHomeOptionCheckBox.Checked)then
    begin
      SmartHomePage.PromptLabels[0].Caption := 'Currently Installed SmartHome Directory:';
    end
    else
    begin
      SmartHomePage.PromptLabels[0].Caption := 'Install SmartHome Here:';
    end
end;

//intial page setup
procedure onActivateSmartHomePage(Sender: TWizardPage);
begin
   SmartHomeOptionCheckBox.Visible := true;
   SmartHomeOptionCheckBox.Caption := 'Skip Install and Use Directory Above';
   SmartHomeOptionCheckBox.OnClick := @onClickSmartHome;
end;

//hide the checkbox on back
function onBackSmartHomePage(Sender: TWizardPage): Boolean;
begin
   SmartHomeOptionCheckBox.Visible := false;
   Result := True;
end;

//validate the results of the page
function onNextSmartHomePage(Sender: TWizardPage): Boolean;
begin
  SmartHomeUsePreviousInstall := False;
  SmartHomeInstallDirectory := '';
  if(SmartHomeOptionCheckBox.Checked and not FileExists(SmartHomePage.Values[0] + '\SmartHome-Designer.exe'))then
  begin
      Result := False;
      if(SmartHomeIsDirEmpty) then
      begin 
        SmartHomePage.Values[0] := '';
      end
      MsgBox('Specified folder is not a valid SmartHome installation.' + #13'Please specify valid SmartHome install or uncheck checkbox.' , mbError, MB_OK);
  end
  else
  begin  
    
    if(SmartHomeOptionCheckBox.Checked)then
    begin
      WizardForm.ComponentsList.ItemEnabled[SMARTHOME_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[SMARTHOME_COMPONENT] := false;
      SmartHomeUsePreviousInstall := True;
      SmartHomeInstallDirectory := SmartHomePage.Values[0];
    end
    else
    begin
      WizardForm.ComponentsList.ItemEnabled[SMARTHOME_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[SMARTHOME_COMPONENT] := true;
      SmartHomeInstallDirectory := SmartHomePage.Values[0];
    end
    SmartHomeOptionCheckBox.Visible := false;
    SmartHomeOptionCheckBox.OnClick := nil;
    Result := True;
  end; 
end;


//find the smart home install and build the page based on what we find.
procedure BuildSmartHomeSetupPage();
var
  ErrorCode: Integer;
  VersionString: TArrayOfString; 
  SubCaptionString: String;
  SmartHomeDir: String;
begin
      if(FileExists(ExpandConstant('{%EMUS_SMARTHOME_DIR}\SmartHome-Designer.exe'))) then
      begin
         SmartHomeDir := ExpandConstant('{%EMUS_SMARTHOME_DIR}');
         SubCaptionString := 'Found SmartHome Installation Here:'#13 + ExpandConstant('{%EMUS_SMARTHOME_DIR}') + #13'Check box to use this installation otherwise provide path to install version 0.8.0.'#13;
         SmartHomeOptionCheckBox.Checked := True;
      end
      else 
      begin
          SubCaptionString := 'No SmartHome Installation found.'#13 + 'Specify previous SmartHome installation directory or path to install version 0.8.0.'#13#13;
          SmartHomeOptionCheckBox.Checked := False;
          SmartHomeDir := ExpandConstant('{pf}\SmartHome');
      end;

      SmartHomePage := CreateInputDirPage(OpenHabPage.ID,
          'SmartHome Installation', '',
          SubCaptionString,
          False, '');
      if(SmartHomeOptionCheckBox.Checked)then
      begin
        SmartHomePage.Add('Currently Installed SmartHome Directory:');
      end
      else
      begin
        SmartHomePage.Add('Install SmartHome Here:');
      end
      SmartHomePage.Values[0] := SmartHomeDir;
      SmartHomePage.OnActivate := @onActivateSmartHomePage;
      SmartHomePage.OnNextButtonClick := @onNextSmartHomePage;
      SmartHomePage.OnBackButtonClick := @onBackSmartHomePage;

      SmartHomeInstalledAndFoundDirectory := False;
end;


//install smart home by unzipping the downloaded zip file
procedure InstallEclipseSmartHome();
begin
UnzippingLabel.Visible := True;
UnzippingLabel.Caption := 'Unzipping eclipsesmarthome-incubation-0.8.0-designer-win.zip into:'#13 + SmartHomeInstallDirectory + #13'Be patient as this can take up to 10 minutes'; 
    
#ifdef USE_TEMP_FOLDER    
      UnZip('{tmp}\eclipsesmarthome-incubation-0.8.0-designer-win.zip', SmartHomeInstallDirectory);
#else
      UnZip('D:\emus2016\EngimusingInstaller\eclipsesmarthome-incubation-0.8.0-designer-win.zip', SmartHomeInstallDirectory);
#endif 


UnzippingLabel.Visible := False;

end;



//get the final emus tools directory
function GetEmusToolsDir(Dummy: string): string;
begin
   Result := EmusToolsInstallDirectory;
end;


//change the caption based on the checkbox value
procedure onClickEmusTools(Sender: TObject);
begin  
    if(EmusToolsOptionCheckBox.Checked)then
    begin
      EmusToolsPage.PromptLabels[0].Caption := 'Currently Installed Engimusing Tools Directory:';
    end
    else
    begin
      EmusToolsPage.PromptLabels[0].Caption := 'Install Engimusing Tools Here:';
    end
end;

//initial page setup
procedure onActivateEmusToolsPage(Sender: TWizardPage);
begin
   EmusToolsOptionCheckBox.Visible := true;
   EmusToolsOptionCheckBox.Caption := 'Skip Install and Use Directory Above';
   EmusToolsOptionCheckBox.OnClick := @onClickEmusTools;
end;

//hide the checkbox on back
function onBackEmusToolsPage(Sender: TWizardPage): Boolean;
begin
   EmusToolsOptionCheckBox.Visible := false;
   Result := True;
end;

//validate the page result before moving on
function onNextEmusToolsPage(Sender: TWizardPage): Boolean;
begin
  EmusToolsUsePreviousInstall := False;
  EmusToolsInstallDirectory := '';
  if(EmusToolsOptionCheckBox.Checked and not FileExists(EmusToolsPage.Values[0] + '\Serial2Mqtt\EFM_Serial2Mqtt.exe'))then
  begin
      Result := False;
      if(EmusToolsIsDirEmpty) then
      begin 
        EmusToolsPage.Values[0] := '';
      end
      MsgBox('Specified folder is not a valid Engimusing Tools installation.' + #13'Please specify valid Engimusing Tools install or uncheck checkbox.' , mbError, MB_OK);
  end
  else
  begin  
    
    if(EmusToolsOptionCheckBox.Checked)then
    begin
      WizardForm.ComponentsList.ItemEnabled[EMUSTOOLS_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[EMUSTOOLS_COMPONENT] := false;
      EmusToolsUsePreviousInstall := True;
      EmusToolsInstallDirectory := EmusToolsPage.Values[0];
    end
    else
    begin
      WizardForm.ComponentsList.ItemEnabled[EMUSTOOLS_COMPONENT] := false;
      WizardForm.ComponentsList.Checked[EMUSTOOLS_COMPONENT] := true;
      EmusToolsInstallDirectory := EmusToolsPage.Values[0];
    end
    EmusToolsOptionCheckBox.Visible := false;
    EmusToolsOptionCheckBox.OnClick := nil;
    Result := True;
  end; 
end;

//find previous enigmusing tools install and build page based on what we find.
procedure BuildEmusToolsSetupPage();
var
  ErrorCode: Integer;
  VersionString: TArrayOfString; 
  SubCaptionString: String;
  EmusToolsDir: String;
begin
      if(FileExists(ExpandConstant('{%EMUS_EMUSTOOLS_DIR}\Serial2Mqtt\EFM_Serial2Mqtt.exe'))) then
      begin
         EmusToolsDir := ExpandConstant('{%EMUS_EMUSTOOLS_DIR}');
         SubCaptionString := 'Found Engimusing Tools Installation Here:'#13 + ExpandConstant('{%EMUS_EMUSTOOLS_DIR}') + #13'Check box to use this installation otherwise provide path to install version 1.0.'#13;
         EmusToolsOptionCheckBox.Checked := True;
      end
      else 
      begin
          SubCaptionString := 'No Engimusing Tools Installation found.'#13 + 'Specify previous Engimusing Tools installation directory or path to install version 1.0.'#13#13;
          EmusToolsOptionCheckBox.Checked := False;
          EmusToolsDir := ExpandConstant('{pf}\EngimusingTools');
      end;

      EmusToolsPage := CreateInputDirPage(SmartHomePage.ID,
          'Engimusing Tools Installation', '',
          SubCaptionString,
          False, '');
      if(EmusToolsOptionCheckBox.Checked)then
      begin
        EmusToolsPage.Add('Currently Installed Engimusing Tools Directory:');
      end
      else
      begin
        EmusToolsPage.Add('Install Engimusing Tools Here:');
      end
      EmusToolsPage.Values[0] := EmusToolsDir;
      EmusToolsPage.OnActivate := @onActivateEmusToolsPage;
      EmusToolsPage.OnNextButtonClick := @onNextEmusToolsPage;
      EmusToolsPage.OnBackButtonClick := @onBackEmusToolsPage;

      EmusToolsInstalledAndFoundDirectory := False;
end;
 
//update the environment variables based on the setup install directories
procedure updateEnvironmentVars();
begin

  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
       'EMUS_OPENHAB_DIR', OpenHabInstallDirectory)

  if(not JavaHomeAlreadySetup and JavaHomeSetup)then
  begin
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
     'JAVA_HOME', JavaHomeDirectory)
  end;


  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
       'EMUS_SMARTHOME_DIR', SmartHomeInstallDirectory)

  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
       'EMUS_EMUSTOOLS_DIR', EmusToolsInstallDirectory)


end;
      
//enable the directory picker based on the checkbox
procedure onClickJava(Sender: TObject);
begin  
  JavaPage.Edits[0].Enabled := JavaOptionCheckBox.Checked;
  JavaPage.Buttons[0].Enabled := JavaOptionCheckBox.Checked;
end;

//initial page setup
procedure onActivateJavaPage(Sender: TWizardPage);
begin
   JavaOptionCheckBox.Visible := true;
   JavaOptionCheckBox.Caption := 'Update JAVA_HOME to directory specified above.';
   JavaOptionCheckBox.OnClick := @onClickJava;
end;

//hide the checkbox on back
function onBackJavaPage(Sender: TWizardPage): Boolean;
begin
   JavaOptionCheckBox.Visible := false;
   Result := True;
end;

//validate the page on forward
function onNextJavaPage(Sender: TWizardPage): Boolean;
begin

  JavaHomeDirectory := '';
  if(JavaOptionCheckBox.Checked and not FileExists(JavaPage.Values[0] + '\bin\java.exe'))then
  begin
      Result := False;
      MsgBox('Specified folder is not a valid Java installation.' + #13'Please specify valid Java install or uncheck checkbox.' , mbError, MB_OK);
  end
  else
  begin  
    
    if(JavaOptionCheckBox.Checked)then
    begin
      JavaHomeDirectory := JavaPage.Values[0];
    end
    JavaHomeSetup := JavaOptionCheckBox.Checked;
    JavaOptionCheckBox.Visible := false;
    JavaOptionCheckBox.OnClick := nil;
    Result := True;
  end; 
end;

//build the page based on if we found a valid JAVA_HOME or not
procedure BuildJavaCheckPage();
var
  ErrorCode: Integer;
  VersionString: TArrayOfString; 
  SubCaptionString: String;
begin
      if(FileExists(ExpandConstant('{%JAVA_HOME}\bin\java.exe'))) then
      begin
         JavaOptionCheckBox.Checked := False;
         JavaHomeAlreadySetup := True;
      end
      else 
      begin
          SubCaptionString := 'No JAVA Installation found.' + #13'Specify JAVA installation directory or check the box to skip JAVA_HOME setup.'#13 + 'JAVA_HOME setup is required for OpenHAB to run.'#13 + 'See: http://docs.openhab.org/installation/index.html#prerequisites for more info.';
          JavaOptionCheckBox.Checked := True;
          JavaHomeAlreadySetup := False;
      end;

      JavaPage := CreateInputDirPage(wpSelectComponents,
          'JAVA_HOME Setup', '',
          SubCaptionString,
          False, '');
      JavaPage.Add('Current Java Installation Directory:');
      JavaPage.Values[0] := '';
      JavaPage.OnActivate := @onActivateJavaPage;
      JavaPage.OnNextButtonClick := @onNextJavaPage;
      JavaPage.OnBackButtonClick := @onBackJavaPage;

      JavaPage.Edits[0].Enabled := JavaOptionCheckBox.Checked;
      JavaPage.Buttons[0].Enabled := JavaOptionCheckBox.Checked;

end;

//check to see if we should skip the JAVA page
function ShouldSkipPage(PageID : Integer) : Boolean;
begin
   WizardForm.WizardSmallBitmapImage.SendToBack();
   if( (PageID = JavaPage.ID) and (JavaHomeAlreadySetup or (not WizardForm.ComponentsList.Checked[1]))) then
   begin
      Result := True;
   end; 
end;

procedure InitializeWizard();
var i: Integer;
begin

    //create a checkbox as an extra input
    JavaOptionCheckBox := TNewCheckBox.Create(WizardForm);
    JavaOptionCheckBox.Parent := WizardForm.MainPanel.Parent;
    JavaOptionCheckBox.Left :=59;
    JavaOptionCheckBox.Height := JavaOptionCheckBox.Height + 3;
    JavaOptionCheckBox.Width := JavaOptionCheckBox.Width + 300;
    JavaOptionCheckBox.Top := WizardForm.MainPanel.Top +
      WizardForm.MainPanel.Height + 170;
    JavaOptionCheckBox.Visible := False;

    BuildJavaCheckPage();

    //setup download links and mirrors
#ifdef DOWNLOAD_FILES
#ifdef USE_TEMP_FOLDER    
    idpAddFileComp('http://mirrors.xmission.com/eclipse/mosquitto/binary/win32/mosquitto-1.4.10-install-win32.exe', ExpandConstant('{tmp}\mosquitto-1.4.10-install-win32.exe'),  'mosquitto');
#else
    idpAddFileComp('http://mirrors.xmission.com/eclipse/mosquitto/binary/win32/mosquitto-1.4.10-install-win32.exe', ExpandConstant('D:\emus2016\EngimusingInstaller\mosquitto-1.4.10-install-win32.exe'),  'mosquitto');
#endif
       //Secondary mirror for moquitto setup file.
       idpAddMirror('http://mirrors.xmission.com/eclipse/mosquitto/binary/win32/mosquitto-1.4.10-install-win32.exe', 'http://engimusing.github.io/install/windows/mosquitto-1.4.10-install-win32.exe');
 
#ifdef USE_TEMP_FOLDER    
    idpAddFileComp('https://bintray.com/openhab/mvn/download_file?file_path=org%2Fopenhab%2Fdistro%2Fopenhab%2F2.0.0%2Fopenhab-2.0.0.zip', ExpandConstant('{tmp}\openhab-2.0.0.zip'),  'openhab');
#else
    idpAddFileComp('https://bintray.com/openhab/mvn/download_file?file_path=org%2Fopenhab%2Fdistro%2Fopenhab%2F2.0.0%2Fopenhab-2.0.0.zip', ExpandConstant('D:\emus2016\EngimusingInstaller\openhab-2.0.0.zip'),  'openhab');
#endif
       //Secondary mirror for openhab zip file.
       idpAddMirror('https://bintray.com/openhab/mvn/download_file?file_path=org%2Fopenhab%2Fdistro%2Fopenhab%2F2.0.0%2Fopenhab-2.0.0.zip', 'http://engimusing.github.io/install/windows/openhab-2.0.0.zip');
 
#ifdef USE_TEMP_FOLDER    
    idpAddFileComp('http://mirrors.xmission.com/eclipse/smarthome/releases/0.8.0/eclipsesmarthome-incubation-0.8.0-designer-win.zip', ExpandConstant('{tmp}\eclipsesmarthome-incubation-0.8.0-designer-win.zip'),  'smarthomedesigner');
#else
    idpAddFileComp('http://mirrors.xmission.com/eclipse/smarthome/releases/0.8.0/eclipsesmarthome-incubation-0.8.0-designer-win.zip', ExpandConstant('D:\emus2016\EngimusingInstaller\eclipsesmarthome-incubation-0.8.0-designer-win.zip'),  'smarthomedesigner');
#endif
       //Secondary mirror for smarthome zip file but it is too big for github so it can't be uploaded
       //idpAddMirror('http://mirrors.xmission.com/eclipse/smarthome/releases/0.8.0/eclipsesmarthome-incubation-0.8.0-designer-win.zip', 'http://engimusing.github.io/install/windows/eclipsesmarthome-incubation-0.8.0-designer-win.zip');
 
    idpDownloadAfter(JavaPage.ID);
#endif

    //Create custom pages
    WelcomeMessagePage := CreateOutputMsgPage(wpWelcome,
    '', 'Welcome to the Engimusing MQTT and openHAB setup.',
#ifndef USE_TEMP_FOLDER
    '!!!!!!!Installer build without USE_TEMP_FOLDER defined DO NOT DISTRIBUTE!!!!!!'#13#13 +
#endif
#ifndef DOWNLOAD_FILES
    '!!!!!!!Installer build without DOWNLOAD_FILES defined DO NOT DISTRIBUTE!!!!!!'#13#13 +
#endif
    'This installer will walk through the installation of four applications useful for using with Engimusing''s devices.'#13#13 +
    'Mosquitto - MQTT server used to route communication between devices and openHAB. https://mosquitto.org/'#13#13 +
    'OpenHAB 2 - smart home server which provides a web interface for controlling and displaying information about devices. http://www.openhab.org/'#13#13 +
    'Smart Home Designer - Eclipse based IDE used for editing openHAB configuration files. http://www.openhab.org/'#13#13 +
    'EFM_Serial2MQTT - Engimusing custom application which provides communication between an Engimusing boards connected via Serial to a MQTT server. https://www.engimusing.com/'#13#13 +
    'Note: This installer requires an internet connection and will download between 0MB and 200MB of data depending on the options selected.');


    //create a status label for the install page
    UnzippingLabel := TNewStaticText.Create(WizardForm);
    UnzippingLabel.Parent := WizardForm.ProgressGauge.Parent;
    UnzippingLabel.Left := 0;
    UnzippingLabel.Top := WizardForm.ProgressGauge.Top +
      WizardForm.ProgressGauge.Height + 12;
    UnzippingLabel.Width := WizardForm.ProgressGauge.Width;
    UnzippingLabel.Visible := False;

    //setup the custom input pages
    MosquittoOptionCheckBox := TNewCheckBox.Create(WizardForm);
    MosquittoOptionCheckBox.Parent := WizardForm.MainPanel.Parent;
    MosquittoOptionCheckBox.Left :=59;
    MosquittoOptionCheckBox.Height := MosquittoOptionCheckBox.Height + 3;
    MosquittoOptionCheckBox.Width := MosquittoOptionCheckBox.Width + 300;
    MosquittoOptionCheckBox.Top := WizardForm.MainPanel.Top +
      WizardForm.MainPanel.Height + 170;
    MosquittoOptionCheckBox.Visible := False;
    
    OpenHabOptionCheckBox := TNewCheckBox.Create(WizardForm);
    OpenHabOptionCheckBox.Parent := WizardForm.MainPanel.Parent;
    OpenHabOptionCheckBox.Left :=59;
    OpenHabOptionCheckBox.Height := OpenHabOptionCheckBox.Height + 3;
    OpenHabOptionCheckBox.Width := OpenHabOptionCheckBox.Width + 300;
    OpenHabOptionCheckBox.Top := WizardForm.MainPanel.Top +
      WizardForm.MainPanel.Height + 170;
    OpenHabOptionCheckBox.Visible := False;

    SmartHomeOptionCheckBox := TNewCheckBox.Create(WizardForm);
    SmartHomeOptionCheckBox.Parent := WizardForm.MainPanel.Parent;
    SmartHomeOptionCheckBox.Left :=59;
    SmartHomeOptionCheckBox.Height := SmartHomeOptionCheckBox.Height + 3;
    SmartHomeOptionCheckBox.Width := SmartHomeOptionCheckBox.Width + 300;
    SmartHomeOptionCheckBox.Top := WizardForm.MainPanel.Top +
      WizardForm.MainPanel.Height + 170;
    SmartHomeOptionCheckBox.Visible := False;

    EmusToolsOptionCheckBox := TNewCheckBox.Create(WizardForm);
    EmusToolsOptionCheckBox.Parent := WizardForm.MainPanel.Parent;
    EmusToolsOptionCheckBox.Left :=59;
    EmusToolsOptionCheckBox.Height := EmusToolsOptionCheckBox.Height + 3;
    EmusToolsOptionCheckBox.Width := EmusToolsOptionCheckBox.Width + 300;
    EmusToolsOptionCheckBox.Top := WizardForm.MainPanel.Top +
      WizardForm.MainPanel.Height + 170;
    EmusToolsOptionCheckBox.Visible := False;

    // override wizard NextButton click to work around Directory Validaiton.
    Old_WizardForm_NextButton_OnClick := WizardForm.NextButton.OnClick;
    WizardForm.NextButton.OnClick := @WizardForm_NextButton_OnClick;

    //minor changes to the Wizard's components to work correctly for our images and setup
    WizardForm.TypesCombo.Visible := False;

    WizardForm.WizardSmallBitmapImage.Width := 162;
    WizardForm.WizardSmallBitmapImage.Height := 65;
    WizardForm.WizardSmallBitmapImage.Left := WizardForm.WizardSmallBitmapImage.Left - 100;
    WizardForm.WizardSmallBitmapImage.SendToBack();

    WizardForm.WizardBitmapImage2.Width := 240;
    WizardForm.WizardBitmapImage2.Height := 250;

    WizardForm.PageNameLabel.Width := WizardForm.PageNameLabel.Width - 100;
    WizardForm.PageDescriptionLabel.Width := WizardForm.PageDescriptionLabel.Width - 100;
    
    BuildMosquittoSetupPage();
    BuildOpenHabSetupPage();
    BuildSmartHomeSetupPage();
    BuildEmusToolsSetupPage();
end;









