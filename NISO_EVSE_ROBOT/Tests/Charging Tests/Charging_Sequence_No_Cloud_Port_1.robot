*** Settings ***
Library    ../../main.py
Library    SerialLibrary
Library    Process
Library    OperatingSystem
Resource   ../../Resources/Config_Loader.resource
Resource   ../../Resources/State_Cycle_Test_Port_1.resource
Resource   ../Relay Card Tests/Power_Board_Relay_Control_Port_1.resource

#Documentation  Tests full charging cycle on connector 1 from cable plugin to charging state. LED functionality, CP/PP values, states and voltage throughput are verified.
#...            \n\nMacAddress: ${mac_adress}
#...            \n\nSoftware Version: ${sw_version}


Suite Setup  Open Serial Port  ${port} 
Suite Teardown  Close Serial  ${ser}


*** Variables ***
${port}        ${PORT_GLOBAL}
${url}
${transaction}
${tag}
${connector}   1
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
    [Documentation]    Validates states from idle to charging on Connector 1, simulates start charging.
    Check State Cable Connected      ${ser}
    Check State Car Connected        ${ser}
    Log    message=Waiting for CH_PWR     console=${True}
    Check State CH PWR               ${ser}
    Check State Car Requiring Power  ${ser}
    Check State Car Charging         ${ser}
    # Test L1 Relay On
    Sleep    5s
Duty Cycle and Fuse
    Check Duty Cycle Fuse
    Check Duty Cycle Fuse +

Stop Charging Cycle 
    [Documentation]    Validates states from charging to idle on Connector 1, simulates stop charging.
    Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Previous test case failed.
    Close State Car Charging         ${ser}
    # Test L1 Relay Off
    Close State Car Requiring Power  ${ser}
    Log    message=Waiting for Car Con     console=${True}
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

