*** Settings ***
Library  ../../main.py

Suite Setup  Open Serial Port  ${port} 
Suite Teardown  Close Serial  ${ser}

*** Variables ***

${port}               COM15
${ser}                # Serial Connection
${line_connector_1}   0
${line_connector_2}   4
${connector_1_relay}  0    
${connector_2_relay}  4

*** Test Cases ***

Verify Relay Shut Off Timing Specification Port 1
    [Documentation]    Verifies that timing for shutoff is within specification.
    Start All Relays
    ${result}  Relay Timing  ${line_connector_1}  ${connector_1_relay}
    Should Be True  ${result} < 100
    Close All Relays

Verify Relay Shut Off Timing Specification Port 2
    [Documentation]    Verifies that timing for shutoff is within specification.
    Start All Relays
    ${result}  Relay Timing  ${line_connector_2}  ${connector_2_relay}
    Should Be True  ${result} < 100
    Close All Relays

*** Keywords ***

Open Serial Port
    [Documentation]    Opens up a serial COM-port and is able to pass it between test to avoid reboot of device.
    [Arguments]  ${port}
    ${ser}  Open Serial  ${port} 
    Set Suite Variable  ${ser}
    sleep  2s
