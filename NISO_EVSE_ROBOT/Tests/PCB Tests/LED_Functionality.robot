*** Settings ***
Library   ../../main.py
Library   OperatingSystem
Resource  ../../Resources/LED/LED_Functionality.resource

*** Variables ***
${green_LED}    10
${blue_LED}    11
${red_LED}    12
${LEDCHECK}    ${False}


*** Keywords ***
Check Green LED
    [Documentation]  Checks if green LED is active
    ${data}    Digital In    0    ${green_LED}
    Should Be Equal    ${data}    ${False}    GREEN LED
    ${data}    Digital In    0    ${blue_LED}
    Should Be Equal    ${data}    ${True}    BLUE LED
    ${data}    Digital In    0    ${red_LED}
    Should Be Equal    ${data}    ${True}    RED LED

Check Yellow LED
    [Documentation]  Checks if Yellow LED is active
    ${data}    Digital In    0    ${green_LED}
    Should Be Equal    ${data}    ${False}    GREEN LED
    ${data}    Digital In    0    ${blue_LED}
    Should Be Equal    ${data}    ${True}    BLUE LED
    ${data}    Digital In    0    ${red_LED}
    Should Be Equal    ${data}    ${False}    RED LED

Check Blue LED
    [Documentation]  Checks if Blue LED is active
    ${data}    Digital In    0    ${green_LED}
    Should Be Equal    ${data}    ${True}    GREEN LED
    ${data}    Digital In    0    ${blue_LED}
    Should Be Equal    ${data}    ${False}    BLUE LED
    ${data}    Digital In    0    ${red_LED}
    Should Be Equal    ${data}    ${True}    RED LED

Check Blue LED Flashing
    [Documentation]  Checks if Blue LED is flashing
    FOR  ${i}  IN RANGE  5
        Sleep    0.5
        ${greendata}    Digital In    0    ${green_LED}
        ${bluedata}    Digital In    0    ${blue_LED}
        ${reddata}    Digital In    0    ${red_LED}
        ${LEDCHECK}=  Evaluate  '${True}'
        Exit For Loop If  ${greendata} == ${True} and ${bluedata} == ${False} and ${reddata} == ${True}
        ${LEDCHECK}=  Evaluate  '${False}'
    END
    Run Keyword If  ${LEDCHECK} == ${False}    Fail    Failed Blue LED Flashing Test
    FOR  ${i}  IN RANGE  5
        Sleep    0.5
        ${greendata}    Digital In    0    ${green_LED}
        ${bluedata}    Digital In    0    ${blue_LED}
        ${reddata}    Digital In    0    ${red_LED}
        ${LEDCHECK}=  Evaluate  '${True}'
        Exit For Loop If  ${greendata} == ${True} and ${bluedata} == ${True} and ${reddata} == ${True}
        ${LEDCHECK}=  Evaluate  '${False}'
    END
    Run Keyword If  ${LEDCHECK} == ${False}    Fail    Failed Blue LED Flashing Test
    

Check Blue/Yellow LED Flashing
    [Documentation]  Checks if Blue/Yellow LED is flashing
    FOR  ${i}  IN RANGE  5
        Sleep    0.5
        ${greendata}    Digital In    0    ${green_LED}
        ${bluedata}    Digital In    0    ${blue_LED}
        ${reddata}    Digital In    0    ${red_LED}
        ${LEDCHECK}=  Evaluate  '${True}'
        Exit For Loop If  ${greendata} == ${True} and ${bluedata} == ${False} and ${reddata} == ${True}
        ${LEDCHECK}=  Evaluate  '${False}'
    END
    Run Keyword If  ${LEDCHECK} == ${False}    Fail    Failed Blue/Yellow LED Flashing Test
    FOR  ${i}  IN RANGE  5
        Sleep    0.5
        ${greendata}    Digital In    0    ${green_LED}
        ${bluedata}    Digital In    0    ${blue_LED}
        ${reddata}    Digital In    0    ${red_LED}
        ${LEDCHECK}=  Evaluate  '${True}'
        Exit For Loop If  ${greendata} == ${False} and ${bluedata} == ${True} and ${reddata} == ${False}
        ${LEDCHECK}=  Evaluate  '${False}'
    END
    Run Keyword If  ${LEDCHECK} == ${False}    Fail    Failed Blue/Yellow LED Flashing Test