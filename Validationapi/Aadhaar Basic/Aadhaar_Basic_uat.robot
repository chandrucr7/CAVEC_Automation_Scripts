*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    CSVLibrary
Library    String
Library    JSONLibrary
Library    DatabaseLibrary
Library    urllib3
Library    random



Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Disconnect From Database

*** Variables ***
${DBName}   validation
${DBUser}   qa.chandraprakash.d
${DBPass}   KrG3yfPY
${DBHost}   digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcdemo.digitap.work
${file_path}=  C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Aadhaar Basic\\AadhaarBasicData.csv
${json_schema_file}=  C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Aadhaar Basic\\Aadhaar_Basic_Json_schema.json

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    aadhaar_number=${columns[1]}    client_ref_num=${columns[2]}
        Append To List    ${test_data}    ${data}
    END
    RETURN   ${test_data}

Validate JSON Response
    [Arguments]    ${expected_json}    ${actual_json}
    ${expected_keys}=    Get Dictionary Keys    ${expected_json}
    ${actual_keys}=    Get Dictionary Keys    ${actual_json}

    # Remove ignored keys (like request_id)
    Remove Values From List    ${actual_keys}    request_id
    Remove Values From List    ${expected_keys}    request_id

    # Check for missing keys
    ${missing_keys}=    Copy List    ${expected_keys}
    Remove Values From List    ${missing_keys}    @{actual_keys}
    Run Keyword If    ${missing_keys}    Fail    Missing keys in response: ${missing_keys}

    # Check for extra keys
    ${extra_keys}=    Copy List    ${actual_keys}
    Remove Values From List    ${extra_keys}    @{expected_keys}
    Run Keyword If    ${extra_keys}    Fail    Unexpected extra keys in response: ${extra_keys}

    # Validate each key-value pair
    FOR    ${key}    IN    @{expected_keys}
        ${expected_value}=    Get From Dictionary    ${expected_json}    ${key}
        ${actual_value}=    Get From Dictionary    ${actual_json}    ${key}
        Should Be Equal As Strings    ${actual_value}    ${expected_value}    msg=Mismatch for key ${key}
    END

# Post Request and Validate
Send Post Request And Validate
    [Arguments]    ${auth}    ${body}    ${expected_schema_file}    ${case_key}
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession    /validation/kyc/v1/basic_aadhaar    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${EMPTY}

    # Parse actual response JSON
    ${actual_json}=    Convert To Dictionary    ${response.json()}
    Log To Console    ${actual_json}

    # Load expected JSON schema
    ${expected_json}=    Load JSON From File    ${expected_schema_file}

    # Extract the relevant case from the JSON schema
    ${expected_case_json}=    Get From Dictionary    ${expected_json}    ${case_key}

    # Validate the JSON response
    Validate JSON Response    ${expected_case_json}    ${actual_json}

*** Test Cases ***
Test Case 1
    Log To Console    Verify by entering valid aadhaar number
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

Test Case 2
    Log To Console    Verify by entering in-valid Aadhaar number
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

Test Case 3
    Log To Console    Verify by Leaving Aadhaar number as empty
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

Test Case 4
    Log To Console    Verify by giving empty space in the Aadhaar number
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

Test Case 5
    Log To Console    Verify by giving Aadhaar number less than 12 char
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

Test Case 6
    Log To Console    Verify by giving Aadhaar number more than 12 char
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

Test Case 7
    Log To Console    Verify by entering Aadhaar number as alphabetic char
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7

Test Case 8
    Log To Console    Verify by entering Aadhaar number as special char
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8

Test Case 9
    Log To Console    Verify by entering Aadhaar number as mixed of alpha numeric and special char
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

Test Case 10
    Log To Console    Verify by entering Aadhaar number as 111111111111
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

Test Case 11
    Log To Console    Verify by entering cancelled aadhaar number
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

Test Case 12
    Log To Console    Verify by entering deactivated aadhaar number
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

Test Case 13
    Log To Console    Verify by entering aadhaar number which is not active
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

Test Case 14
    Log To Console    Verify by entering invalid aadhaar which shows 400
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

Test Case 15
    Log To Console    Verify by entering aadhaar number start from 0
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

Test Case 16
    Log To Console    Verify by entering aadhaar number where verhoff check fails
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

Test Case 17
    Log To Console    Verify by entering invalid aadhaar where verhoff check pass
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

Test Case 18
    Log To Console    Verify by entering valid client ref number
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

Test Case 19
    Log To Console    Verify by entering in-valid clinet ref number
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

Test Case 20
    Log To Console    Verify by entering Leaving client ref number as empty
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

Test Case 21
    Log To Console    Verify by entering Leaving client ref number as empty space
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

Test Case 22
    Log To Console    Verify by entering client ref number more than 45 char
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

Test Case 23
    Log To Console    Verify by entering client ref number as 45 char
    ${auth}=    Create List    740513625625    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

Test Case 24
    Log To Console    Verify by entering invalid client username
    ${auth}=    Create List    52652631504%    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 25
    Log To Console    Verify by entering invalid client password
    ${auth}=    Create List    740513625625    EA6F34B4B3B618A10CF5C2223229077@
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 26
    Log To Console    Verify by entering invalid client username and password
    ${auth}=    Create List    52652631504%    EA6F34B4B3B618A10CF5C2223229077#
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 27
    Log To Console    Verify by leaving client username as empty
    ${auth}=    Create List    ${EMPTY}    DQqdokAmK7DJxOjX5hHUnEjS1Ea78zmg
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 28
    Log To Console    Verify by leaving client password as empty
    ${auth}=    Create List    740513625625    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 29
    Log To Console    Verify by leaving client username and password as empty
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 30
    Log To Console    Verify by entering client doesnt have the Aadhaar advanced
    ${auth}=    Create List    740513625625    EA6F34B4B3B618A10CF5C22232290779
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

