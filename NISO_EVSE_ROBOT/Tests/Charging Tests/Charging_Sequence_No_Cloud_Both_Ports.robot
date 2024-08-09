*** Settings ***
Library    ../../main.py
Library    SerialLibrary
Library    Process
Library    OperatingSystem
Resource   ../../Resources/State_Cycle_Test_Port_2.resource
Resource   ../../Resources/State_Cycle_Test_Port_1.resource

Suite Setup   Run Keywords   Open Serial Port  ${port}    AND    Set Mac Variable
Suite Teardown  Close Serial  ${ser}

#Documentation  Tests full charging cycle on both connectors from cable plugin to start charging. LED functionality, CP/PP values, charging states and voltage throughput are verified.
#...            \n\nMacAddress: ${mac_adress}
#...            \n\nSoftware Version: ${sw_version}


*** Variables ***
${port}        ${PORT_GLOBAL}
${url}
${transaction}
${tag}
${connector_1}   1
${connector_2}   2
${loadbalancing}  ${TRUE}
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
Start Charging Cycle On Both Ports Staggered for loadBalancing Validation.
    [Documentation]    Validates states from idle to charging on Connector 1.
    State_Cycle_Test_Port_1.Check State Cable Connected      ${ser}
    State_Cycle_Test_Port_2.Check State Cable Connected      ${ser}
    State_Cycle_Test_Port_1.Check State Car Connected        ${ser}
    State_Cycle_Test_Port_2.Check State Car Connected        ${ser}
    Log    message=Waiting for CH_PWR     console=${True}
    State_Cycle_Test_Port_1.Check State CH PWR               ${ser}
    State_Cycle_Test_Port_2.Check State CH PWR               ${ser}
    State_Cycle_Test_Port_1.Check State Car Requiring Power  ${ser}
    State_Cycle_Test_Port_2.Check State Car Requiring Power  ${ser}
    State_Cycle_Test_Port_1.Check State Car Charging         ${ser}
    State_Cycle_Test_Port_2.Check State Car Charging         ${ser}
    
Check Duty Cycle and Fuse
    Log    Loadbalancing
    State_Cycle_Test_Port_1.Check Duty Cycle Both Ports
    State_Cycle_Test_Port_1.Check Duty Cycle LoadBalancing

Stop Charging Cycle Port 1 and Port 2
    [Documentation]    Validates states from charging to idle on Connector 1.
    Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Previous test case failed.
    State_Cycle_Test_Port_1.Close State Car Charging         ${ser}
    State_Cycle_Test_Port_2.Close State Car Charging         ${ser}
    State_Cycle_Test_Port_1.Close State Car Requiring Power  ${ser}
    State_Cycle_Test_Port_2.Close State Car Requiring Power  ${ser}
    Log    message=Waiting for Car_Conn     console=${True}
    State_Cycle_Test_Port_1.Close State CH PWR               ${ser}
    State_Cycle_Test_Port_2.Close State CH PWR               ${ser}
    State_Cycle_Test_Port_1.Close State Car Connected        ${ser}
    State_Cycle_Test_Port_2.Close State Car Connected        ${ser}
    State_Cycle_Test_Port_1.Close State Cable Connected      ${ser}
    State_Cycle_Test_Port_2.Close State Cable Connected      ${ser}

Stop Charging Cycle Port 2
    [Documentation]    Validates states from charging to idle on Connector 2.
    Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Previous test case failed.
    
    
    
    

*** Keywords ***
Set Mac Variable
    ${MAC}  Get Mac-Address From Config File
    Set Suite Variable    ${MAC_GLOBAL}    ${MAC}

Open Serial Port
    [Documentation]    Opens up a serial COM-port and is able to pass it between test to avoid reboot of device.
    [Arguments]  ${port}
    ${ser}  Open Serial  ${port} 
    Set Suite Variable  ${ser}
    sleep  2s

Set Mac Adress
    [Documentation]    Gets MAC Adress From Initiation.csv
    Set Suite Variable  ${mac_adress}    Get C