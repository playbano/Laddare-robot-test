*** Settings ***
Library    ../../main.py
Library    Process
Library    OperatingSystem
Resource   ../../Resources/State_Cycle_Test_Port_2.resource

Suite Setup  Open Serial Port  ${port} 
Suite Teardown  Close Serial  ${ser}

Documentation  Tests full charging cycle on connector 2 from cable plugin to allowance to charge from cloud using StartTransaction and StopTransaction on rest api. LED functionality, CP/PP values, charging states and voltage throughput are verified.
...            \n\nMacAddress: ${mac_adress}
...            \n\nSoftware Version: ${sw_version}


*** Variables ***
${port}        ${PORT_GLOBAL}
${url}
${transaction}
${tag}
${connector_2}   2
${chargepoint}
${data}
${ser}
${sw_version}  ${SW_GLOBAL}
${mac_adress}  ${MAC_GLOBAL}
#68B6B33F9B1C



# Relay_4 Starts the circuit



*** Test Cases ***

# Startar alla relän, och skickar begäran att ladda till cloud.
Start Charging Cycle Using Cloud Allowance
    [Documentation]    Validates states from idle to charging and using RemoteStartTransaction to allow charging on Connector 2.
    Check State Cable Connected      ${ser}
    Check State Car Connected        ${ser}
    Log    message=Press     console=${True}
    Check State CH PWR               ${ser}
    Check State Car Requiring Power  ${ser}
    Start RemoteTransaction
    Check State Car Charging         ${ser}


Stop Charging Cycle Using Cloud Allowance
    [Documentation]    Validates states from charging to idle and using RemoteStopTransaction to end charging on Connector 2.
    Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Previous test case failed.
    Stop RemoteTransaction
    Close State Car Charging         ${ser}
    Close State Car Requiring Power  ${ser}
    Log    message=Press     console=${True}
    Close State CH PWR               ${ser}  
    Close State Car Connected        ${ser}
    Close State Cable Connected      ${ser}

*** Keywords ***

Open Serial Port
    [Documentation]    Opens up a serial COM-port and is able to pass it between test to avoid reboot of device.
    [Arguments]  ${port}
    ${ser}  Open Serial  ${port} 
    Set Suite Variable  ${ser}
    sleep  2s

Start RemoteTransaction
    ${MAC_ADRESS}    Get MAC-Address From Config File
    sleep  2s
    ${StartResult}    Start Transaction      ${connector_2}  ${MAC_ADRESS}
    sleep  15s
    Should Contain    ${StartResult}     Accepted     msg=RemoteStartTransaction failed. 

Stop RemoteTransaction
    ${MAC_ADRESS}    Get MAC-Address From Config File
    ${StopResult}     Stop Transaction      ${connector_2}  ${MAC_ADRESS}
    sleep  2s
    Should Contain    ${StopResult}     Accepted      msg=RemoteStopTransaction failed.
    sleep  6s