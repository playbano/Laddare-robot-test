*** Settings ***
Library    ../main.py
Library    ../Elmatare.py
Library    SerialLibrary
Library    Process
Library    OperatingSystem
Resource   ../Resources/Config_Loader.resource
Resource   ../Resources/CP_PP/CP_PP.resource

# Suite Setup  Open Serial Port  ${port} 
# Suite Teardown  Close Serial  ${ser}


*** Variables ***
${relay_4}     4
${relay_5}     5
${relay_6}     6
${relay_7}     7
${port}        ${PORT_GLOBAL}    #Sätts i Config_Loader
${connector_2}   State 2
${CP_channel_port_2}  2
${PP_channel_port_2}  3
${Channel_2}    2

${state_idle}        CH_STATE_IDLE
${state_cable_con}   CH_STATE_CABLE_CONN
${state_car_con}     CH_STATE_CAR_CONN
${state_ch_PWR}      CH_STATE_CH_PWR
${state_car_req}     CH_STATE_CAR_REQ_PWR
${state_charging}    CH_STATE_CHARGING
${data}
${ser}

${Serial_COM_Port}    COM9
${BAUDRATE}           115200 







*** Keywords ***

# Startar första reläet och kontrollerar om kabeln är inkopplad
Check State Cable Connected
    [Documentation]    This test case checks if the PP cable is connected.
    [Arguments]  ${ser}
    ${data}  Simulate Cable Plugin  ${relay_4}  ${ser}
    Check State And CP/PP Value     ${data}     ${state_cable_con}

# Startar andra reläet och kontrollerar om kommunikationen mellan fordonet och laddaren är etablerad.
Check State Car Connected
    [Documentation]    This test case checks if the CP car connection is established.
    [Arguments]  ${ser}
    # Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Check PP-Cable-Conn failed, aborting test execution
    ${data}  Simulate Cable Plugin  ${relay_5}  ${ser}
    Check State And CP/PP Value     ${data}     ${state_car_con}
    #Check State And CP/PP Value     ${data}     ${state_car_ch_pwr}

Check State CH PWR
    [Documentation]    This test case checks if charging cloud is true.
    [Arguments]  ${ser}
    ${data}    Collect State 15 sec    ${ser}    ${state_ch_PWR}
    Log    ${data}

# Startar tredje reläet och kontrollerar om fordonet begär ström.
Check State Car Requiring Power
    [Documentation]    This test case checks if the CP car requests power.
    [Arguments]  ${ser}
    # Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Check CP-Car-Con failed, aborting test execution
    ${data}  Simulate Cable Plugin  ${relay_6}  ${ser}
    Check State And CP/PP Value     ${data}     ${state_car_req}

# Startar fjärde reläet, låser kabeln och aktiverar laddning.
Check State Car Charging
    [Documentation]    This test case checks if the CP car starts charging.
    [Arguments]  ${ser}
    # Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Check CP-Car-Req-Pwr failed, aborting test execution
    ${data}  Simulate Cable Plugin  ${relay_7}  ${ser}
    Check State And CP/PP Value     ${data}     ${state_charging}


# 19 Ampere till Laddaren, Läser värde 3 gånger
Check Duty Cycle 
    [Documentation]    Checks Duty Cycle under normal load
    ${FUSE}    Get Main Fuse Value From Config File 
    ${CLOSED}    Receive Serial Data    ${Serial_COM_Port}    ${BAUDRATE}    19    100001    200
    
    FOR    ${index}    IN RANGE    1    4
        ${Duty_Cycle_1}    Measure Pwm Duty Cycle     ${Channel_2}
        Log    Iteration test nr:${index}
        ${Duty_Cycle_A}    Evaluate    ${Duty_Cycle_1} * 0.6
        Log    ${Duty_Cycle_A}
        Sleep    1s
    END
    



# Spik på 22 Ampere till laddaren, Läser värde 3 gånger
Check Duty Cycle Fuse
    [Documentation]    Checks Duty Cycle +1 A Above Fuse
    ${FUSE}    Get Main Fuse Value From Config File 
    ${FUSEOVER}=    Evaluate    ${FUSE} + 1
    FOR    ${index}    IN RANGE    1    15
        ${CLOSED}    Receive Serial Data    ${Serial_COM_Port}    ${BAUDRATE}    ${FUSEOVER}    100002    200
        ${CLOSED}    Receive Serial Data    ${Serial_COM_Port}    ${BAUDRATE}    19    100002    200
        Log    Iteration test nr:${index}
        ${Duty_Cycle_1}    Measure Pwm Duty Cycle     ${Channel_2}
        ${Duty_Cycle_A}    Evaluate    ${Duty_Cycle_1} * 0.6
        Exit For Loop If     ${Duty_Cycle_A} < 8
        IF     ${index} == 14
        Fail    Took to long failing
        END
    END

Check Duty Cycle Fuse +
    [Documentation]    Checks Duty Cycle +1 A Above Fuse
    ${FUSE}    Get Main Fuse Value From Config File 
    ${FUSEUNDER}=    Evaluate    ${FUSE} -5
    FOR    ${index}    IN RANGE    1    15
        ${CLOSED}    Receive Serial Data    ${Serial_COM_Port}    ${BAUDRATE}    ${FUSEUNDER}    100002    200
        ${CLOSED}    Receive Serial Data    ${Serial_COM_Port}    ${BAUDRATE}    19    100002    200
        Log    Iteration test nr:${index}
        ${Duty_Cycle_1}    Measure Pwm Duty Cycle     ${Channel_2}
        ${Duty_Cycle_A}    Evaluate    ${Duty_Cycle_1} * 0.6
        Exit For Loop If     ${Duty_Cycle_A} > 15
        IF     ${index} == 14
        Fail    Took to long failing
        END
    END
# Stegar baklänges och kontrollerar om states uppfylls vid avstängning.
Close State Car Charging
    [Documentation]    This test case checks if the CP car charging is closed properly.
    [Arguments]  ${ser}
    # Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Check CP-Car-Charging failed, aborting test execution
    ${data}  Simulate Cable Disconnect  ${relay_7}  ${ser}
    Check State And CP/PP Value         ${data}     ${state_car_req}

# Stegar baklänges och kontrollerar om states uppfylls vid avstängning.
Close State Car Requiring Power
    [Documentation]    This test case checks if the CP car power request is closed properly.
    [Arguments]  ${ser}
    # Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Close CP-Car-Charging failed, aborting test execution
    ${data}  Simulate Cable Disconnect  ${relay_6}  ${ser}
    Check State And CP/PP Value         ${data}     ${state_ch_PWR}

Close State CH PWR
    [Documentation]    This test case checks if charging cloud is true.
    [Arguments]  ${ser}
    ${data}    Collect State 15 sec    ${ser}    ${state_car_con}
    Log    ${data}

# Stegar baklänges och kontrollerar om states uppfylls vid avstängning.
Close State Car Connected
    [Documentation]    This test case checks if the CP car connection is closed properly.
    [Arguments]  ${ser}
    # Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Close CP-Car-Req-pwr, aborting test execution
    ${data}  Simulate Cable Disconnect  ${relay_5}  ${ser}
    Check State And CP/PP Value         ${data}     ${state_cable_con}

# Stegar baklänges och kontrollerar om states uppfylls vid avstängning.
Close State Cable Connected
    [Documentation]    This test case checks if the PP cable connection is closed properly.
    [Arguments]  ${ser}
    # Run Keyword If    '${PREV_TEST_STATUS}' != 'PASS'    Fail    Close CP-Car-Con, aborting test execution
    ${data}  Simulate Cable Disconnect  ${relay_4}  ${ser}
    Check State And CP/PP Value         ${data}     ${state_idle}

# *** Keywords ***
# Open Serial Port
#     [Documentation]    Opens up a serial COM-port and is able to pass it between test to avoid reboot of device.
#     [Arguments]  ${port}
#     ${ser}  Open Serial  ${port} 
#     Set Suite Variable  ${ser}
#     Sleep  2s

Check State And CP/PP Value
    [Arguments]  ${data}  ${state}
    ${PP}  Get CP/PP Value  ${PP_channel_port_2}
    ${CP}  Get CP/PP Value  ${CP_channel_port_2}
    Log    ${PP}
    Log    ${CP}
    Sleep  1s

    Run Keyword If  "'${state}' in ${data}"  Run Keywords
            Should Be True  ${PP} >= ${PP_min[${state}]} and ${PP} <= ${PP_max[${state}]}
            Should Be True  ${CP} >= ${CP_min[${state}]} and ${CP} <= ${CP_max[${state}]}
    Log    ${data}
    Should Contain    ${data}    ${connector_2}        msg=Connector Error
    Should Contain    ${data}    ${state}            msg=State Error
    #Sleep    1s

Simulate Cable Plugin
    [Arguments]  ${relay}  ${ser}
    Start Relay    ${relay}
    ${data}    Collect State    ${ser} 
    Sleep    2s 
    Log    ${data}
    Return From Keyword    ${data}

Simulate Cable Disconnect
    [Arguments]  ${relay}  ${ser}
    Close Relay    ${relay}
    ${data}    Collect State    ${ser} 
    Sleep    2s 
    Return From Keyword    ${data}

Number Should Be Between
    [Arguments]    ${number}    ${lower}    ${upper}
    Run Keyword If    ${number} > ${lower} and ${number} < ${upper}    Log    ${number} is between ${lower} and ${upper}
    ...    ELSE    Fail    ${number} is NOT between ${lower} and ${upper}