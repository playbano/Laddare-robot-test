*** Settings ***
Library    ../../main.py
Library    SerialLibrary
Library    Process
Library    OperatingSystem
Library    String
Resource   ../../Resources/Config_Loader.resource
Resource   ../../Resources/State_Cycle_Test_Port_1.resource
Resource   ../../Resources/State_Cycle_Test_Port_2.resource
Resource   ../Relay Card Tests/Power_Board_Relay_Control_Port_1.resource

#Documentation  Tests full charging cycle on connector 2 from cable plugin to charging state. LED functionality, CP/PP values, states and voltage throughput are verified.
#...            \n\nMacAddress: ${mac_adress}
#...            \n\nSoftware Version: ${sw_version}


Suite Setup  Open Serial Port  ${port} 
Suite Teardown  Close Serial  ${ser} 


*** Variables ***
${port}        ${PORT_GLOBAL}
${url}
${transaction}
${tag}
${connector_2}   1
${chargepoint}
${data}
${ser}
${sw_version}  ${SW_GLOBAL}
${mac_adress}  ${MAC_GLOBAL}

*** Test Cases ***

Set Suite Documentation
    ${MAC}     Run Keyword    Get MAC-Address From Config File
    ${SW}    Run Keyword    Get Software Version From Config File
    Set Suite Documentation    Tests full charging cycle on connector 2 from cable plugin to charging state. LED functionality, CP/PP values, states and voltage throughput are verified.\n\nMAC-Address: ${MAC} \n\nSoftware Version: ${SW}

# Startar alla relän, och skickar begäran att ladda till cloud.
Start Charging Cycle
    [Documentation]    Validates states from idle to charging on Connector 1.
    ${data}  State_Cycle_Test_Port_1.Simulate Cable Plugin  ${relay_0}  ${ser}
    Sleep    1s
    ${data}  State_Cycle_Test_Port_2.Simulate Cable Plugin  ${relay_4}  ${ser}
    Sleep    1s
    ${data}  State_Cycle_Test_Port_1.Simulate Cable Plugin  ${relay_1}  ${ser}
    Sleep    1s
    ${data}  State_Cycle_Test_Port_2.Simulate Cable Plugin  ${relay_5}  ${ser}
    Log To Console    PRESS 15s
    Sleep    15s
    ${data}  State_Cycle_Test_Port_1.Simulate Cable Plugin  ${relay_2}  ${ser}   
    Sleep    1s 
    ${data}  State_Cycle_Test_Port_2.Simulate Cable Plugin  ${relay_6}  ${ser}
    Sleep    1s
    ${data}  State_Cycle_Test_Port_1.Simulate Cable Plugin  ${relay_3}  ${ser}
    Sleep    1s
    ${data}  State_Cycle_Test_Port_2.Simulate Cable Plugin  ${relay_7}  ${ser}
Error Log Cycle
    [Documentation]    Checks Right L1 and Left L1 and Logs
    ${Content}    Error Log    ${ser}
    ${Lines}=  Split String    ${Content}    Error
    FOR  ${item}  IN  @{Lines}
        Log    ${item}
    END


Shut Down 
    Close All Relays



*** Keywords ***
Open Serial Port
    [Documentation]    Opens up a serial COM-port and is able to pass it between test to avoid reboot of device.
    [Arguments]  ${port}
    ${ser}  Open Serial  ${port} 
    Set Suite Variable  ${ser}
    sleep  2s
