*** Settings ***
Library   ../../main.py
Resource  ../../Resources/Config_Loader.resource
Resource  ../../Resources/State_Cycle_Test_Port_1.resource
Suite Setup  Open Serial Port  ${port}
Suite Teardown  Close Serial  ${ser}

*** Variables ***
${relay_8}    8
${port}        ${PORT_GLOBAL}
${data}
${ser}  
${mac_adress}
${sw_version}

*** Test Cases ***

Set Suite Documentation
    ${MAC}     Run Keyword    Get MAC
    ${SW}    Run Keyword    Get Software Version
    Set Suite Documentation    MAC-Address: ${MAC} \n\nSoftware Version: ${SW}

Start Control Board
    [Documentation]     Powers up the RIG and creates a log of initiation routine and config.
    ${data}   Start PCB Power Delivery
    

Validate Software Version
    [Documentation]     Validates software version.
    ${sw}  Get Software Version
    Log    ${sw}
    

# Validates Wifi Connection
Validate Wifi Connection
    [Documentation]     Validates if wifi is connected.
    ${wifi_status}  Get Wifi Status From Config File
    Should Contain  ${wifi_status}    ${wifi}

Validate MAC Adress
    ${mac}    Get MAC
    Log    MAC:${mac}
    ${lenght}=    Get Length    ${mac}
    Should Be Equal As Integers    ${lenght}    12
    


*** Keywords ***

Open Serial Port
    [Documentation]    Opens up a serial COM-port and is able to pass it between test to avoid reboot of device.
    [Arguments]  ${port}
    ${ser}  Open Serial  ${port} 
    Set Suite Variable  ${ser}

Start PCB Power Delivery
    ${data}   Initial Log    ${ser}
    Save List to File  ${data} 
    Set Suite Variable  ${data}       
    Run Keyword If    '${data[0]}' == 'None'    Fail    Timeout occurred while collecting UART data
    Sleep    1s
    Return From Keyword  ${data}

Save List to File
    [Arguments]  ${data}
        Create Log  ${data}

Get Software Version
    ${sw}  Get Software Version From Config File
    Return From Keyword  ${sw}

Get MAC
    ${MAC}    Get MAC-Address From Config File
    Return From Keyword    ${MAC}