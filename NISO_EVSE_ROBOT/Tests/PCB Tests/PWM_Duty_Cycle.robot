*** Settings ***
Library   ../../main.py
Resource  ../../Resources/Config_Loader.resource


*** Variables ***
${max_current}   
${multiplier}    0.6

*** Test Cases ***

Validate PWM Signal according to config port 1
    ${PWM_Result}  Measure Pwm Signal
    Validate % Uptime                ${PWM_Result} 
    Validate Max Current To Config   ${PWM_Result} 

Validate PWM Signal according to config port 2
    ${PWM_Result}  Measure Pwm Signal
    Validate % Uptime                ${PWM_Result} 
    Validate Max Current To Config   ${PWM_Result} 


*** Keywords ***
Calculate Expected PWM Signal
    ${line_result}  Get Max Current Port 1 From Config File
    Log To Console  ${line_result}
    
Measure Pwm Signal
    [Documentation]  Measures the duty cycle and converts it to percent uptime. 26-27% ~ 16A
    Start Relay    0
    Start Relay    1
    Start Relay    2
    Start Relay    3
    Sleep  10
    ${max_current}  Measure Pwm Duty Cycle     0
    Should Be True  ${max_current} >= 26 and ${max_current} <= 27
    Return From Keyword  ${max_current}

Validate % Uptime
    [Arguments]    ${PWM_Result}
    Should Be True  ${PWM_Result} >= 26 and ${PWM_Result} <= 27 

Validate Max Current To Config
    [Arguments]    ${PWM_Result}
    ${Actual_max_current} =    Evaluate    ${PWM_Result} * 0.6
    Should Be True  ${Actual_max_current} >= 15 and ${Actual_max_current} <= 16 


