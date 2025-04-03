*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    CSVLibrary
Library    String
Library    urllib3
Library    random

*** Variables ***
${base_url}=    https://svcstage.digitap.work
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Voter validation\\VoterData.csv

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    epic_number=${columns[1]}    client_ref_num=${columns[2]}
        Append To List    ${test_data}    ${data}
    END
    [Return]    ${test_data}



*** Test Cases ***
Test_case1
    log to console  Verify by entering valid voter number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request   mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case2
    log to console  Verify by entering in-valid voter number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case3
    log to console  Verify by leaving voter number as empty
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case4
    log to console  Verify by giving empty space in the voter number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case5
    log to console  Verify by leave empty in the voter number and client ref number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${SPACE}


Test_case6
    log to console  Verify by entering voter number in special characters
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case7
    log to console  Verify by entering voter number in all numeric characters
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case8
    log to console  Verify by entering voter number in all alpha  characters
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case9
    log to console  Verify by entering voter number alpha char in lower case
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['epic_no']}  LZX4516662
    Should Be Equal As Strings  ${response.json()['result']['ac_name']}  Rajpur
    Should Be Equal As Strings  ${response.json()['result']['dist_no']}  30
    Should Be Equal As Strings  ${response.json()['result']['pc_name']}  Buxar
    Should Be Equal As Strings  ${response.json()['result']['rln_name']}  Gulab
    Should Be Equal As Strings  ${response.json()['result']['name']}  Sanksharo
    Should Be Equal As Strings  ${response.json()['result']['st_name']}  Bihar
    Should Be Equal As Strings  ${response.json()['result']['id']}  63143463_LZX4516662_S04

Test_case10
    log to console  Verify by entering new format voter id
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['epic_no']}  LZX4516662
    Should Be Equal As Strings  ${response.json()['result']['ac_name']}  Rajpur
    Should Be Equal As Strings  ${response.json()['result']['dist_no']}  30
    Should Be Equal As Strings  ${response.json()['result']['pc_name']}  Buxar
    Should Be Equal As Strings  ${response.json()['result']['rln_name']}  Gulab
    Should Be Equal As Strings  ${response.json()['result']['name']}  Sanksharo
    Should Be Equal As Strings  ${response.json()['result']['st_name']}  Bihar
    Should Be Equal As Strings  ${response.json()['result']['id']}  63143463_LZX4516662_S04


Test_case11
    log to console  Verify by entering old format voter id
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['message']}    No Records Found for the Given ID or Combination of Inputs

Test_case12
    log to console  Verify by entering voter id which is not found
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['message']}    No Records Found for the Given ID or Combination of Inputs


Test_case13
    log to console  Verify by entering valid client ref number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['epic_no']}  LZX4516662
    Should Be Equal As Strings  ${response.json()['result']['ac_name']}  Rajpur
    Should Be Equal As Strings  ${response.json()['result']['dist_no']}  30
    Should Be Equal As Strings  ${response.json()['result']['pc_name']}  Buxar
    Should Be Equal As Strings  ${response.json()['result']['rln_name']}  Gulab
    Should Be Equal As Strings  ${response.json()['result']['name']}  Sanksharo
    Should Be Equal As Strings  ${response.json()['result']['st_name']}  Bihar
    Should Be Equal As Strings  ${response.json()['result']['id']}  63143463_LZX4516662_S04

Test_case14
    log to console  Verify by entering in-valid client ref number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    !@#$%

Test_case15
    log to console  Verify by entering client ref number more than 45 char
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashDchandraprakashD


Test_case16
    log to console  Verify by entering client ref number as 45 char
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashD
    Should Be Equal As Strings  ${response.json()['result']['epic_no']}  LZX4516662
    Should Be Equal As Strings  ${response.json()['result']['ac_name']}  Rajpur
    Should Be Equal As Strings  ${response.json()['result']['dist_no']}  30
    Should Be Equal As Strings  ${response.json()['result']['pc_name']}  Buxar
    Should Be Equal As Strings  ${response.json()['result']['rln_name']}  Gulab
    Should Be Equal As Strings  ${response.json()['result']['name']}  Sanksharo
    Should Be Equal As Strings  ${response.json()['result']['st_name']}  Bihar
    Should Be Equal As Strings  ${response.json()['result']['id']}  63143463_LZX4516662_S04


Test_case17
    log to console  Verify by giving empty in the client ref number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}


Test_case18
    log to console  Verify by giving empty space in the client ref number
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong or missing
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}

Test_case19
    log to console  Verify by entering Valid authentication
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['epic_no']}  LZX4516662
    Should Be Equal As Strings  ${response.json()['result']['ac_name']}  Rajpur
    Should Be Equal As Strings  ${response.json()['result']['dist_no']}  30
    Should Be Equal As Strings  ${response.json()['result']['pc_name']}  Buxar
    Should Be Equal As Strings  ${response.json()['result']['rln_name']}  Gulab
    Should Be Equal As Strings  ${response.json()['result']['name']}  Sanksharo
    Should Be Equal As Strings  ${response.json()['result']['st_name']}  Bihar
    Should Be Equal As Strings  ${response.json()['result']['id']}  63143463_LZX4516662_S04

Test_case20
    log to console  Verify by entering in-Valid authentication
    ${auth}=    create list    5265263150$$    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case21
    log to console  Verify by entering authentication which don't having voter service
    ${auth}=    create list    5265263150471   EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case22
    log to console  Verify by leaving client user name as empty
    ${auth}=    create list    ${EMPTY}   EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case23
    log to console  Verify by leaving password as empty
    ${auth}=    create list    526526315047   ${EMPTY}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case24
    log to console  Verify by leaving password and user name as empty
    ${auth}=    create list    526526315047   ${EMPTY}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${epic_number}=    Get From Dictionary    ${row}    epic_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    epic_number=${epic_number}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/mbs/v1/voter    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire