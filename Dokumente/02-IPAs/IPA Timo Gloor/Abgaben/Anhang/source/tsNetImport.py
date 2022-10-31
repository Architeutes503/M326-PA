# ----------------------------------------------------------------------------------------------------
# Name:         TsNet Import Script 
# File:         tsNetImport.py 
# ----------------------------------------------------------------------------------------------------
# Copyright @2020, SIEMENS Building Technologies 
# ----------------------------------------------------------------------------------------------------
# OS:           Win64 
# Lang:         Python
# ----------------------------------------------------------------------------------------------------
# Project:      TsOpen 
# Author:       Timo Gloor
# Version:      V.1.1
# Date:         31.03.2020 
# ----------------------------------------------------------------------------------------------------
# Description:  The Import-script is used to convert old, Excel based Testsheets to the new JSON-Format 
#
# Parameters:      
#               - First Param:  Inputfile -> Filepath of the Excel-Input-File
#               - Second Param: Destinationfolder -> Path to the directroy, in which the .json-files should be created   
#
#               Example call:
#               python tsNetImport.py "C:\Temp\Input\TsNetV1_Example.xls" "C:\Temp\Output"
# ----------------------------------------------------------------------------------------------------
# History:      24.03.2020 Timo Gloor 
#               Created file 
#               Implemented Meta-Data-Modul
#               
#               25.03.2020 Timo Gloor
#               Implemented Connections-Data-Modul
#               Started with Test-Data-Modul
#
#               26.03.2020 Timo Gloor
#               Finished Test-Data-Modul
#               Errorhandling
#
#               27.03.2020 Timo Gloor
#               Finished Errorhandling
#               Finsihed programming for Version 1.0
#
#               31.03.2020
#               Fixed errors in Test-Data-Modul -> New Version 1.1
# ----------------------------------------------------------------------------------------------------

#----Imports------------------------------------------------------------------------------------------

#Library from https://xlrd.readthedocs.io/en/latest/
#Used to access Excel files and its cell values
import xlrd
from xlrd import open_workbook, cellname

import os.path
from os import path

import sys, string, json, datetime


#----Constants and global variables-------------------------------------------------------------------

#--Constants--
TEST_DESCRIPTION = "Test imported from TsNet" #Pre defined value for the test description

#Entrypoints to read the devices in the Config-Sheet
CONNECTIONS_ENTRYPOINT_X = 0
CONNECTIONS_ENTRYPOINT_Y = 28

#Entrypoints to read the testcase names in the Overview-Sheet
OVERVIEW_ENTRYPOINT_X = 1
OVERVIEW_ENTRYPOINT_Y = 12

#Entrypoints to read the teststeps in the Testcase-Sheet
TEST_ENTRYPOINT_X = 0
TEST_ENTRYPOINT_Y = 17

TESTSTEP_PROPERTIES_Y_VALUE = { "objectName" : 1, "deviceName": 5, "prop" : 6, "writeOperation" : 8, "prio": 7} # Required properties for a step and their y-coordinate in the testcase sheet

#--Global variables--

# Dictionaries with the properties and the coordinates for the excel file
_metaTestdata_PropertyDict = {"projectName": "<manual>", "testName" : "C:4", "testDescription" : "<manual>", "testCaseName" : "<manual>", "testCaseDescription" : "<manual>", "version" : "C:7", "author" : "C:6", "date" : "C:5", "type" : "C:12", "automation" : "C:9"}

_metaTestobject_PropertyDict = {"name": "C:16", "type" : "A:16", "description" : "E:16", "version" : "D:16", "source" : "C:13", "path" : "<manual>"}

_connectionsProperties = [ "deviceNo", "deviceName", "deviceAddress", "deviceType" ]

#Main dictionaries to save the JSON format of each section, so they can later be combined
_metaDict = {} 
_connectionsDict = []
_testDict = []

#Global Objects to access the Excel file
_workBook = None
_workSheet = None

#----Functions----------------------------------------------------------------------------------------

def ConvertCoordinate(coordinate):   
    #---------------------------------------------------
    # Function to convert the Excel coordinates (A:3) to x and y values 
    # Returns the x and y values of the excel coordinates: (A:3) -> x=0;y=2
    # params:
    #   coordinate -> Coordinate of the Excel cell : string
    # V1.0 
    #---------------------------------------------------

    directions = coordinate.split(':')
    x = string.ascii_lowercase.index(directions[0].lower())
    y = int(directions[1]) - 1    
    return x, y

def CreateTestStep(funct, val):
    #---------------------------------------------------
    # Function to create a new teststep with the value and the object-properties for the step 
    # Returns the teststep or False, if an error occures
    # params:
    #   funct -> "Set" or "Verify"
    #   val -> value of the cell
    # V1.2
    #---------------------------------------------------

    writeOperation = _workSheet.cell(TESTSTEP_PROPERTIES_Y_VALUE["writeOperation"], sectionRange_X).value
    if writeOperation == "Handling":
        return({"funct":"suppressFail"})
    else:
        # get property information
        tmpObjectName = _workSheet.cell(TESTSTEP_PROPERTIES_Y_VALUE["objectName"], sectionRange_X).value
        tmpDeviceName = _workSheet.cell(TESTSTEP_PROPERTIES_Y_VALUE["deviceName"], sectionRange_X).value
        tmpObj = tmpDeviceName + "." + tmpObjectName
        tmpProp = _workSheet.cell(TESTSTEP_PROPERTIES_Y_VALUE["prop"], sectionRange_X).value
        tmpPrio = _workSheet.cell(TESTSTEP_PROPERTIES_Y_VALUE["prio"], sectionRange_X).value

        if not tmpObjectName or not tmpDeviceName or not tmpProp:
            return False
        else:
            val = CheckDataType(val)       
            if tmpPrio:
                return({"funct": funct,
                    "obj": tmpObj,
                    "prop": tmpProp,
                    "prio" : tmpPrio,
                    "val":val})
            else:
                # append the teststep to the other steps of the line
                return({"funct": funct,
                        "obj": tmpObj,
                        "prop": tmpProp,
                        "val":val}) 

def CheckDataType(val):
    #---------------------------------------------------
    # Function to check the type of the cell value and change the type if it is necessary
    # Returns value with correct type
    # params:
    #   val -> Value of the cell
    # V1.2 
    #---------------------------------------------------

    # Try to convert the float into an integer if possible
    if type(val) == float:
       if float(val).is_integer():
           val = int(val)
    elif type(val) == str:
        # Struct with ranges -> eg.: ([5,7],[-1,1],[0,0])   
        if ".." in str(val) and "\n" in str(val):
            tmp = val.split("\n")
            tmpRanges = []
            retVal = "("
            for x in tmp:
                tmpRanges = x.split("..")
                retVal += "[" + tmpRanges[0] + "," + tmpRanges[1] + "],"
            retVal = retVal[:-1]
            retVal += ")"
            return retVal
        # Struct -> eg.: (5,6,3)
        if "\n" in str(val):
           tmp = val.split("\n") 
           retVal = "(" + tmp[0] + "," + tmp[1] + "," + tmp[2] + ")"
           val = retVal
        # Range -> eg.: [2,6]
        if ".." in str(val):
            tmp = val.split("..") 
            retVal = "[" + tmp[0] + "," + tmp[1] + "]"
            val = retVal
        
    return val

def CreateJSONFile(outputPath, sheetName, content):
    #---------------------------------------------------
    # Function that creates a JSON-File and writes the content to it 
    # No return value -> Void
    # params:
    #   outputPath -> Directroy in which the file should be created
    #   sheetName -> Name of the sheet
    #   content -> Content which should be written in the JSON-file
    # V1.1
    #---------------------------------------------------

    #Check if output directory exists, if not display an info. The directory will be created 
    jsonFilePath = outputPath + '/' + sheetName + ".json" # create the filepath of the json file
    if not path.exists(outputPath):
        PrintStatusNotification("INFO", "Output Directory doesn't exist", nextStep="Directory will be created")
        #Create directory
        os.makedirs(outputPath)
    else:
        # TODO: Print warning if there are already files
        if path.exists(jsonFilePath):
            PrintStatusNotification("WARING", "A file with the name " + sheetName + " already exists", nextStep="It will be overwritten")
          
    # create json file with the content
    with open(jsonFilePath, "w") as f:
        json.dump(content, f, indent=4)
   
def PrintStatusNotification(notificationType, msg, location = None, nextStep = None):
    #---------------------------------------------------
    # Function to print status notification in the terminal or console
    # No return value -> Void
    # params:
    #   notificationType -> Type of the notification (ERROR, WARNING, INFO)
    #   msg -> The main message that should be displayed
    #   location -> Location where the error or warning occured, eg.: Cell-Coordinate, Sheetname, ...
    #   nextStep -> What is the next step? (Continuing, Terminating program,...)
    # V1.0
    #---------------------------------------------------

    notification = notificationType + ": " + msg
    if not location == None:
        notification += " - at: " + location
    if not nextStep == None:
        notification += " - " + nextStep
    print("\n" + notification)

def PrintSummary(createdTestcases, expectedTestcases):
    #---------------------------------------------------
    # Function that prints a summary overview of the created files
    # No return value -> Void
    # params:
    #   createdTestcases -> Name of the sheets that were created
    #   expectedTestcases -> Name of the sheets that should have been created
    # V1.0
    #---------------------------------------------------

    print("\n\n******** SUMMARY ********\n")
    print("Created " + str(len(createdTestcases)) + " of " + str(len(expectedTestcases)) + " Files:")
    for name in createdTestcases:
        print("\t" + name + ".json")


#----Logic--------------------------------------------------------------------------------------------

# Read passed params from user 
inputPath = ""
outputPath = ""
if len(sys.argv) > 2:
    #first param: <ScriptName>, second param: inputPath, third param: outputPath
    inputPath = sys.argv[1]
    outputPath = sys.argv[2]
else:
    # not all params given -> exit script
    PrintStatusNotification("ERROR", "Expected parameters weren't given", nextStep="Terminating script")
    sys.exit()

#Check if input file exists, if not -> exit script
if not path.exists(inputPath):
    PrintStatusNotification("ERROR", "Inputfile doesn't exist", nextStep="Terminating script")
    sys.exit()


#Create Workbook object and open the Excel-File
try:
    _workBook = open_workbook(inputPath)
except Exception as e:
    PrintStatusNotification("ERROR", "Inputfile can't be opend", nextStep="Terminating script")
    sys.exit()

PrintStatusNotification("*****\nINFO", "Started script. Try to create the testcase sheets\n*****")
#-----------------------------------------------------------------------------------------
#
# Modul: Meta-Data
# Description: Read all data from the excel file which are required in the meta-section of the JSON-file
# V1.0
#

#Open the Config-Sheet
try:
    _workSheet = _workBook.sheet_by_name("Config")
except Exception as e:
    PrintStatusNotification("ERROR", "Config-Sheet wasn't found", nextStep="Terminating script")
    sys.exit()


#-----------
# Range: "testData"
#

# Loop through each property for the testData-Section
for prop in _metaTestdata_PropertyDict:
    
    # If the pre-defined value is "<manual>", then it should not read an excel value
    if not _metaTestdata_PropertyDict[prop] == "<manual>":
        # Convert the Excel Coordinate of the cell to x and y value 
        coordinate = ConvertCoordinate(_metaTestdata_PropertyDict[prop])
        val = _workSheet.cell(coordinate[1], coordinate[0]).value # read cell value       
        
        if prop == "date" and type(val) == float:
            # Excel date converts to an float in python
            # Convert it back to datetime format:
            val = datetime.datetime(*xlrd.xldate_as_tuple(val, _workBook.datemode)) #Solution found at: https://stackoverflow.com/questions/13962837/reading-date-as-a-string-not-float-from-excel-using-python-xlrd , 24.03.2020
            val = val.date().strftime("%d.%m.%Y")
        
        if not val:
            # print WARNING if value has no value
            PrintStatusNotification("WARNING", "Cell has no value", _metaTestdata_PropertyDict[prop], "Leave empty and continuing")
        
        # add the value to the propertyname
        _metaTestdata_PropertyDict[prop] = str(val)

#--Manual values--
baseName = path.basename(inputPath) # get filename
_metaTestdata_PropertyDict["projectName"] = baseName[0 : int(len(baseName) - 4)] # remove ".xls" extension
_metaTestdata_PropertyDict["testDescription"] = TEST_DESCRIPTION

# Add testData-Section to the main dict
_metaDict["testData"] = _metaTestdata_PropertyDict

#-----------
# Range: "testObject"
#

# Loop through each property for the testObject-Section
for prop in _metaTestobject_PropertyDict:

    # If the pre-defined value is "<manual>", then it should not read an excel value
    if not _metaTestobject_PropertyDict[prop] == "<manual>":
        # Convert the Excel Coordinate of the cell to x and y value 
        coordinate = ConvertCoordinate(_metaTestobject_PropertyDict[prop])
        val = _workSheet.cell(coordinate[1], coordinate[0]).value # read cell value       
        
        if not val:
            # print WARNING if value has no value
            PrintStatusNotification("WARNING", "Cell has no value", _metaTestobject_PropertyDict[prop], "Leave empty and continuing")
        
        # add the value to the propertyname
        _metaTestobject_PropertyDict[prop] = str(val)

#--Manual values--

_metaTestobject_PropertyDict["path"] = "" #leave empty

# Add testObject-Section to the main dict
_metaDict["testObject"] = _metaTestobject_PropertyDict

#-----------------------------------------------------------------------------------------
#
# Modul: Connections-Data
# Description: Read all data from the excel file which are required in the connections-section of the JSON-file
# V1.0
#

_workSheet = _workBook.sheet_by_name("Config") #Switch Worksheet

tmpDevice = {} #temporary dictionary for the data of one device
y = CONNECTIONS_ENTRYPOINT_Y # set entrypoint value of the y coordinate
allDevicesRead = False # Bool which turns to True if there are no devices left to read

# Two loops; one for the y-coordinate and the other for the x-coordinate
# Reads all cell values which are required for the connections-section
while not allDevicesRead:
    #Check if there is a device left by reading the first property of the new line
    firstProp = _workSheet.cell(y, CONNECTIONS_ENTRYPOINT_X).value 
    if not firstProp:
        # no device        
        if y <= CONNECTIONS_ENTRYPOINT_Y: #are there devices at all? if not -> ERROR
            PrintStatusNotification("ERROR", "There are no devices to read", "Config-Sheet", "Terminating script")
            sys.exit()
        else:
            # finished reading all devices
            allDevicesRead = True
    else:
        # device to read
        tmpDevice.update({_connectionsProperties[0] : firstProp}) #add the first read value to the temp dict
        #loop through the properties of the device -> inkrement x value while y stays the same
        for x in range(CONNECTIONS_ENTRYPOINT_X + 1, CONNECTIONS_ENTRYPOINT_X + len(_connectionsProperties)): #range from second property to amount of properties to read
            val = _workSheet.cell(y, x).value #read value
            if not val:
                PrintStatusNotification("ERROR", "Cell value for devices is missing", "Config-Sheet: Row: " + str(y), "Terminating script")
                sys.exit()
            else:
                tmpDevice.update({_connectionsProperties[x]: str(val)}) #add value with the propertyname to the temp dict
        _connectionsDict.append(tmpDevice) #add device data to the main connections dict    
    y += 1 #increment y
    
#-----------------------------------------------------------------------------------------
#
# Modul: Test-Data
# Description: Read all data from the excel file which are required in the test-section of the JSON-file
# V1.0
#
try:
    _workSheet = _workBook.sheet_by_name("Overview") # Switch to Overview-Worksheet
except Exception as e:
    PrintStatusNotification("ERROR", "Overview-Sheet wasn't found", nextStep="Terminating script")
    sys.exit()

y = OVERVIEW_ENTRYPOINT_Y
allTestcasesRead = False
testcaseSheets = []
# Read all Testcase names and save it to the array testcaseSheets
while not allTestcasesRead:     
    try:
        #read value of next sheet name
        val = _workSheet.cell(y, 1).value
        if val:
            # add name of sheet to array
            testcaseSheets.append(val)
        else:
            # all Sheets read
            allTestcasesRead = True    
    except:
        # all Sheets read
        allTestcasesRead = True    
    y += 1

# Loop through all names of the testcases in the overview table and check if they exist as a sheet
createdSheets = []
for testCaseSheetName in testcaseSheets:
    foundSheet = False
    for i in range(0, len(_workBook.sheet_names())): # range from 0 to the amount of sheets
        if testCaseSheetName == _workBook.sheet_by_index(i).name: # go through every sheet and compare the name
            # Testcase-Sheet found
            foundSheet = True
            _testDict = []
            _workSheet = _workBook.sheet_by_index(i) # Select testcase sheet                    
            y = TEST_ENTRYPOINT_Y
            allTestsRead = False
            errorInSheet = False
            # Loop trough every testline and read the steps until all test lines got read
            while not allTestsRead and not errorInSheet:      
                try:          
                    tmpTestLine = {} # temporary obejct to which the data of the current testline are being saved to

                    stepName = _workSheet.cell(y, TEST_ENTRYPOINT_X).value # start with reading the stepName
                    if not stepName: # if stepName is empty, there is no test line left               
                        # finished reading all tests
                        allTestsRead = True
                    else:
                        # test line to read

                        tmpTestLine.update({"stepName" : stepName}) #add the stepName to the line dict
                        tmpTestSteps = [] # temporary dict to save all steps of a line

                        #----Dialog----

                        # Check if there is a dialog before the action steps
                        dialog = _workSheet.cell(y, 2).value
                        if dialog:
                            # add the dialog as a teststep
                            tmpTestSteps.append({"funct": "verifyByUser", "message": str(dialog)})
                            
                        #----DataIn----    
                                         
                        # x and y coordiantes to loop through the action steps
                        sectionRange_Y = 1
                        sectionRange_X = 3

                        beginningDataOut_X = 0 # will be needed later in the program to determine where the verfication range starts
                        endDataIn = False
                        # Loop trough the action steps
                        while not endDataIn:
                            val = _workSheet.cell(sectionRange_Y, sectionRange_X).value
                            # If the keyword "Out" is reached, the action steps are completed
                            if val == "Out":
                                endDataIn = True
                                beginningDataOut_X = sectionRange_X
                            else:
                                # Read value of next step and check if the object has a value
                                val = _workSheet.cell(y, sectionRange_X).value
                                if val or val == 0:
                                    retVal = CreateTestStep("Set", val)
                                    if not retVal == False:
                                        tmpTestSteps.append(retVal)                                    
                                    else:
                                        errorInSheet = True
                            sectionRange_X += 1 # increment the x coordinate    
                        if errorInSheet:
                            # Error occured while reading
                            PrintStatusNotification("ERROR", "Cell value is empty. In " + testCaseSheetName + " at X:" + str(sectionRange_X) + "/Y:" + str(sectionRange_Y), nextStep="Skip Testcase and continue with next one")
                            continue          
                        
                        #----Wait----
                        # If there is a wait command, add it to the steps
                        waitTime = _workSheet.cell(y, 1).value 
                        if waitTime:
                            tmpTestSteps.append({"funct": "Wait", "val": CheckDataType(waitTime)})


                        #----DataOut----
                        # x and y coordiantes to loop through the verification steps
                        sectionRange_Y = 1
                        sectionRange_X = beginningDataOut_X + 1

                        endDataOut = False
                        # Loop through the verification steps
                        while not endDataOut:
                            val = _workSheet.cell(sectionRange_Y, sectionRange_X).value
                            # If the keyword "End" is reached, the action steps are completed
                            if val == "End":
                                endDataOut = True
                            else:
                                # Read value of next step and check if the object has a value   
                                val = _workSheet.cell(y, sectionRange_X).value
                                if val or val == 0:
                                    retVal = CreateTestStep("Verify", val)
                                    if not retVal == False:
                                        tmpTestSteps.append(retVal)                                    
                                    else:
                                        errorInSheet = True
                            sectionRange_X += 1 # increment the x coordinate     
                        if errorInSheet:
                            # Error occured while reading
                            PrintStatusNotification("ERROR", "Cell value is empty. In " + testCaseSheetName + " at X:" + str(sectionRange_X) + "/Y:" + str(sectionRange_Y), nextStep="Skip Testcase and continue with next one")
                            continue  
                        
                        tmpTestLine["stepList"] = tmpTestSteps # add all the teststeps of the current line to the dict under the entry "stepList"
                        _testDict.append(tmpTestLine) # append the complete section of the test to the main dict
                        
                except Exception as e:
                    allTestsRead = True
                
                y += 1 #increment for next line

            #---All lines read of the testcase sheet----
            if not errorInSheet: # Create sheet only if there is no error in it
                #Update specific meta-data for the current test case
                testCaseName = _workSheet.cell(1, 0).value
                testCaseDescription = _workSheet.cell(2, 0).value
                _metaDict["testData"]["testCaseName"] = testCaseName
                _metaDict["testData"]["testCaseDescription"] = testCaseDescription 
                
                #----Write Data to JSON-File----
                
                #Combine all data parts (meta, connections, test)                        
                jsonData = {}
                jsonData["meta"] = _metaDict
                jsonData["connections"] = _connectionsDict
                jsonData["test"] = _testDict
                # Add empty sections
                jsonData["simulation"] = {}
                jsonData["log"] = {}            

                # Call function to create the JSON file and print an information
                CreateJSONFile(outputPath, testCaseSheetName, jsonData)
                createdSheets.append(testCaseSheetName)
                PrintStatusNotification("INFO", "Testcasesheet " + testCaseSheetName + ".json created.")

    if not foundSheet:
        #Testcase Sheet not found
        PrintStatusNotification("WARNING", "Testcasesheet: " + testCaseSheetName + " not found.", nextStep="Continue with next Testcasesheet")

# Print summary of the created sheets. Afterwards the script is completed
PrintSummary(createdSheets, testcaseSheets)