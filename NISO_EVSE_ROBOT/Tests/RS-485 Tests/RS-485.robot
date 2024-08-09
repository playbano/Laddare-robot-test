*** Settings ***
Library    ../../main.py
Library    ../../Elmatare.py
Library    BuiltIn

*** Variables ***
${COMPORT}    COM9
${BAUDRATE}    115200

${relay_0}     0
${relay_1}     1
${relay_2}     2
${relay_3}     3

${AMPERE}    16
${kWhTOT}    80.6
${VOLT}    200
${Connector_1}    0

*** Keywords ***
Number Should Be Between
    [Arguments]    ${number}    ${lower}    ${upper}
    Run Keyword If    ${number} > ${lower} and ${number} < ${upper}    Log    ${number} is between ${lower} and ${upper}
    ...    ELSE    Fail    ${number} is NOT between ${lower} and ${upper}

*** Test Cases ***

RUN SERIAL SENDS
    ${CLOSED}    Receive Serial Data    ${COMPORT}    ${BAUDRATE}    ${AMPERE}    ${kWhTOT}    ${VOLT}
    Should Be True    ${CLOSED}

DutyCyle 16
    Start Relay    ${relay_0}
    Start Relay    ${relay_1}
    Start Relay    ${relay_2}
    Start Relay    ${relay_3}
    ${CLOSED}    Receive Serial Data    ${COMPORT}    ${BAUDRATE}    ${AMPERE}    ${kWhTOT}    ${VOLT}
    ${Duty_Cycle_1}    Measure Pwm Duty Cycle     ${Connector_1}
    ${Duty_Cycle_A}    Evaluate    ${Duty_Cycle_1} * 0.6
    Number Should Be Between    ${Duty_Cycle_A}    15    17

DutyCycle 24
    ${CLOSED}    Receive Serial Data    ${COMPORT}    ${BAUDRATE}    22    ${kWhTOT}    ${VOLT}
    Sleep    10
    ${Duty_Cycle_1}    Measure Pwm Duty Cycle     ${Connector_1}
    ${Duty_Cycle_A}    Evaluate    ${Duty_Cycle_1} * 0.6
    Number Should Be Between    ${Duty_Cycle_A}    59    62
    