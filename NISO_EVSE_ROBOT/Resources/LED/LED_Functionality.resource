*** Settings ***
Library  ../../main.py

*** Variables ***

${port}   2
${green}
${red}
${blue}

*** Keywords ***

Verify Green LED Port 1
    ${green}         Digital In    ${port}  0
    ${red}           Digital In    ${port}  1
    ${blue}          Digital In    ${port}  2
    Should Be True      ${green}
    Should Not Be True  ${red}
    Should Not Be True  ${blue}

Verify Blue LED Port 1
    ${green}         Digital In    ${port}  0
    ${red}           Digital In    ${port}  1
    ${blue}          Digital In    ${port}  2
    Should Be True      ${blue}
    Should Not Be True  ${green}
    Should Not Be True  ${red}

Verify Red LED Port 1
    ${green}         Digital In    ${port}  0
    ${red}           Digital In    ${port}  1
    ${blue}          Digital In    ${port}  2
    Should Be True      ${red}
    Should Not Be True  ${green}
    Should Not Be True  ${blue}

Verify Green LED Port 2
    ${green}         Digital In    ${port}  3
    ${red}           Digital In    ${port}  4
    ${blue}          Digital In    ${port}  5
    Should Be True      ${green}
    Should Not Be True  ${red}
    Should Not Be True  ${blue}

Verify Blue LED Port 2
    ${green}         Digital In    ${port}  3
    ${red}           Digital In    ${port}  4
    ${blue}          Digital In    ${port}  5
    Should Be True      ${blue}
    Should Not Be True  ${green}
    Should Not Be True  ${red}

Verify Red LED Port 2
    ${green}         Digital In    ${port}  3
    ${red}           Digital In    ${port}  4
    ${blue}          Digital In    ${port}  5
    Should Be True      ${red}
    Should Not Be True  ${green}
    Should Not Be True  ${blue}

Verify Blue Blink LED Port 1
    ${blue}          Digital In Counter    2
    ${red}           Digital In            ${port}  1    
    ${green}         Digital In            ${port}  0
    Should Be True      ${blue}  >2
    Should Not Be True  ${green}
    Should Not Be True  ${red}


Verify Blue Blink LED Port 2
    ${blue}         Digital In Counter    5
    ${red}          Digital In            ${port}  4    
    ${green}        Digital In            ${port}  3    
    Should Be True      ${blue}  >2
    Should Not Be True  ${green}
    Should Not Be True  ${red}
    