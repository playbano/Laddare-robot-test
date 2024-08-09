*** Settings ***
Library  ../../main.py
# Suite Setup  Start All Relays
# Suite Teardown  Close All Relays
*** Variables ***

${port}  1
${L1}    0
${L2}    1
${L3}    2
${N}     3

*** Keywords ***
Test L1 Relay On
    [Documentation]  Test power throughput on phase L1 by passing 5volts in.
    ${status}        Digital In    ${port}  ${L1}
    Should Be True   ${status}

Test L1 Relay Off
    [Documentation]  Test power throughput on phase L1 by passing 5volts in.
    ${status}        Digital In    ${port}  ${L1}
    Should Not Be True   ${status}

# Test L2 Relay
#     [Documentation]  Test power throughput on phase L2 by passing 5volts in.
#     ${status}        Digital In    ${port}  ${L2}
#     Should Be True   ${status}

# Test L3 Relay
#     [Documentation]  Test power throughput on phase L3 by passing 5volts in.
#     ${status}        Digital In    ${port}  ${L3}
#     Should Be True   ${status}

# Test N Relay
#     [Documentation]  Test power throughput on Ground by passing 5volts in.
#     ${status}        Digital In    ${port}  ${N}
#     Should Be True   ${status}

