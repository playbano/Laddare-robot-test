*** Settings ***
Library    ../../main.py
Library    Process
Library    OperatingSystem
Resource   ../../Resources/State_Cycle_Test_Port_1.resource
Resource   ../../Resources/State_Cycle_Test_Port_2.resource

Suite Setup  Open Serial Port  ${port} 
Suite Teardown  Close Serial  ${ser}

Documentation  Tests full charging cycle from cable plugin to allowance to charge connector 1 and 2 from cloud using StartTransaction and StopTransaction on rest api. LED functionality, CP/PP values, charging states and voltage throughput are verified.
...            \n\nMacAddress: ${mac_adress}
...            \n\nSoftware Version: ${sw_version}

*** Variables ***
${port}        ${PORT_GLOBAL}
${url}
${transaction}
${tag}
${connector_1}   1
${connector_2}   2
${chargepoint}
${data}
${ser}
${sw_version}      ${SW_GLOBAL}
${mac_adress}      ${MAC_GLOBAL}



# Relay_4 Starts the circuit



*** Test Cases ***

# Startar alla relän, och skickar begäran att ladda till cloud.
Start Charging Cycle On Port 1 Using Cloud Allowance
    [Documentation]    Validates states from idle to charging and using RemoteStartTransaction to allow charging on Connector 1.
    State_Cycle_Test_Port_1.Check State Cable Connected      ${ser}
    State_Cycle_Test_Port_1.Check State Car Connected        ${ser}
    State_Cycle_Test_Port_1.Check State Car Requiring Power  ${ser}
    Start RemoteTransaction  ${connector_1}
    State_Cycle_Test_Port_1.Check State Car Charging         ${ser}
    Sleep    1s

Start Charging Cycle On Port 2 Using Cloud Allowance
    [Documentation]    Validates states from idle to charging and using RemoteStartTransaction to allow charging on Connector 2.
    State_Cycle_Test_Port_2.Check State Cable Connected      ${ser}
    State_Cycle_Test_Port_2.Check State Car Connected        ${ser}
    State_Cycle_Test_Port_2.Check State Car Requiring Power  ${ser}
    Start RemoteTransaction  ${connector_2}
    State_Cycle_Test_Port_2.Check State Car Charging         ${ser}
    Sleep    1s

Check Duty Cycle and Fuse
    State_Cycle_Test_Port_1.Check Duty Cycle both Ports
    
    
Stop Charging Cycle On Port 1 Using Cloud Allowance
    [Documentation]    Validates states from charging to idle and using RemoteStopTransaction to end charging on Connector 1.
    Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Previous test case failed.
    Stop RemoteTransaction  ${connector_1}
    State_Cycle_Test_Port_1.Close State Car Charging         ${ser}
    State_Cycle_Test_Port_1.Close State Car Requiring Power  ${ser}
    State_Cycle_Test_Port_1.Close State Car Connected        ${ser}
    State_Cycle_Test_Port_1.Close State Cable Connected      ${ser}

Stop Charging Cycle On Port 2 Using Cloud Allowance
    [Documentation]    Validates states from charging to idle and using RemoteStopTransaction to end charging on Connector 2.
    Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Previous test case failed.
    Stop RemoteTransaction  ${connector_2}
    State_Cycle_Test_Port_2.Close State Car Charging         ${ser}
    State_Cycle_Test_Port_2.Close State Car Requiring Power  ${ser}
    State_Cycle_Test_Port_2.Close State Car Connected        ${ser}
    State_Cycle_Test_Port_2.Close State Cable Connected      ${ser}

*** Keywords ***

Open Serial Port
    [Documentation]    Opens up a serial COM-port and is able to pass it between test to avoid reboot of device.
    [Arguments]  ${port}
    ${ser}  Open Serial  ${port} 
    Set Suite Variable  ${ser}
    sleep  2s

Start RemoteTransaction
    [Arguments]  ${connector}
    sleep  2s
    ${StartResult}    Start Transaction      ${connector}  ${mac_adress}
    sleep  6s
    Should Contain    ${StartResult}     Accepted     msg=RemoteStartTransaction failed. 

Stop RemoteTransaction
    [Arguments]  ${connector}
    ${StopResult}     Stop Transaction      ${connector}  ${mac_adress}
    sleep  2s
    Should Contain    ${StopResult}     Accepted      msg=RemoteStopTransaction failed.
    sleep  6s