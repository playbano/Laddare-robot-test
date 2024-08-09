*** Settings ***
Library  ../main.py
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    String
Library    CSVLibrary

*** Variables ***

${file_path}    ../NISO_EVSE_ROBOT/Output/Initiation.csv

#Use to search for Mac Address
${mac}          OCPP: MAC

${wifi}         WiFi is connected

${SW_GLOBAL}    0.15

${max_current_port_1}  "Read value port 1 max:"
${max_current_port_2}  "Read value port 1 max:"

${PORT_GLOBAL}    COM15
${MAC_GLOBAL}    348518A1DC84
${MAIN_FUSE}    Main Fuse:
${SW_VERSION}   SW name:



*** Keywords ***

Get MAC-Address From Config File
    ${data}=  Read Config  ${mac}
    ${line}=    Convert To String     ${data}   
    ${MAC}=    Get Substring    ${line}    -15    -3
    #Set Suite Variable    ${MAC_ADRESS}    ${MAC}
    Return From Keyword  ${MAC}

Get Max Current Port 1 From Config File
    Get WiFi Status From Config File
    ${csv}  Get File  Output/Initiation.csv
    @{read}  Create List  ${csv}
    @{lines}  Split To Lines  @{read}
    #@{result}  Get Lines Containing String  @{lines}  ${wifi}  case-insensitive = true

    FOR  ${line}  IN  @{lines}
         ${cleaned_line}=  Evaluate  "${line}".replace("'", "").replace('"', '')
         ${cleaned_max_current_port_1}=  Evaluate  "${max_current_port_1}".replace("'", "").replace('"', '')
        IF  "${cleaned_max_current_port_1}" in "${cleaned_line}"
            Return From Keyword  ${line}
        END
    END


Get Max Current Port 2 From Config File
    Get WiFi Status From Config File
    ${csv}  Get File  Output/Initiation.csv
    @{read}  Create List  ${csv}
    @{lines}  Split To Lines  @{read}
    #@{result}  Get Lines Containing String  @{lines}  ${wifi}  case-insensitive = true

    FOR  ${line}  IN  @{lines}
         ${cleaned_line}=  Evaluate  "${line}".replace("'", "").replace('"', '')
         ${cleaned_wifi}=  Evaluate  "${wifi}".replace("'", "").replace('"', '')
        IF  "${cleaned_wifi}" in "${cleaned_line}"
            Return From Keyword  ${line}
        END
    END

    
Get WiFi Status From Config File
    ${csv}  Get File  Output/Initiation.csv
    @{read}  Create List  ${csv}
    @{lines}  Split To Lines  @{read}
    #@{result}  Get Lines Containing String  @{lines}  ${wifi}  case-insensitive = true

    FOR  ${line}  IN  @{lines}
         ${cleaned_line}=  Evaluate  "${line}".replace("'", "").replace('"', '')
         ${cleaned_wifi}=  Evaluate  "${wifi}".replace("'", "").replace('"', '')
        IF  "${cleaned_wifi}" in "${cleaned_line}"
            Return From Keyword  ${line}
        END
    END

Get Software Version From Config File
    ${lines}=    Get Lines Matching Pattern In CSV    ${file_path}    SW name:
    ${line}=    Convert To String     ${lines}   
    ${sw_Value}=    Get Substring    ${line}    -12    -2
    [Return]    ${sw_Value}
    #${csv}  Get File  Output/Initiation.csv
    #@{read}  Create List  ${csv}
    #@{lines}  Split To Lines  @{read}
    #@{result}  Get Lines Containing String  @{lines}  ${wifi}  case-insensitive = true

    # FOR  ${line}  IN  @{lines}
    #      ${cleaned_line}=  Evaluate  "${line}".replace("'", "").replace('"', '')
    #      ${cleaned_sw_version}=  Evaluate  "${sw_version}".replace("'", "").replace('"', '')
    #     IF  "${cleaned_sw_version}" in "${cleaned_line}"
    #         Return From Keyword  ${line}
    #     END
    # END
    #FOR  ${line}  IN  @{lines}
    #${cleaned_line}=  Evaluate  "${line}".replace("'", "").replace('"', '')
    #${cleaned_sw_version}=  Evaluate  "${sw_version}".replace("'", "").replace('"', '')
    #    IF  "${cleaned_sw_version}" in "${cleaned_line}"
    #    ${split_line}=  Split String  ${cleaned_line}  :
    #    ${result}=  Set Variable  ${split_line[-1]}  # Ta det sista elementet från listan som splittringen skapar
    #        Return From Keyword  ${result}
    #    END
    #END

Get Main Fuse Value From Config File
    ${lines}=    Get Lines Matching Pattern In CSV    ${file_path}    ${MAIN_FUSE}
    ${line}=    Convert To String     ${lines}   
    ${Fuse_Value}=    Get Substring    ${line}    -5    -2
    ${Fuse_int}=    Evaluate    isinstance(${Fuse_Value}, int)
    [Return]    ${Fuse_Value}

Get Lines Matching Pattern In CSV
    [Arguments]    ${file_path}    ${pattern}
    ${lines}=    Create List
    ${csv_data}=    Read Csv File To List      ${file_path}
    ${leng}=    Get Length    ${csv_data}
    FOR    ${line}    IN        @{csv_data}
    Log    line: ${line}
        ${string}=    Convert To String    ${line}
        ${match}    Run Keyword And Return Status    Should Match Regexp    ${string}    ${pattern}
        Exit For Loop If     ${match} == ${true}
    END   
    [Return]    ${line}



    
