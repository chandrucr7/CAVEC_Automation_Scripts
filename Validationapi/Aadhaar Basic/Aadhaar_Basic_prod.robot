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
${base_url}=    https://svc.digitap.ai
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
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

Test Case 2
    Log To Console    Verify by entering in-valid Aadhaar number
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

Test Case 3
    Log To Console    Verify by Leaving Aadhaar number as empty
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

Test Case 4
    Log To Console    Verify by giving empty space in the Aadhaar number
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

Test Case 5
    Log To Console    Verify by giving Aadhaar number less than 12 char
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

Test Case 6
    Log To Console    Verify by giving Aadhaar number more than 12 char
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

Test Case 7
    Log To Console    Verify by entering Aadhaar number as alphabetic char
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7

Test Case 8
    Log To Console    Verify by entering Aadhaar number as special char
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8

Test Case 9
    Log To Console    Verify by entering Aadhaar number as mixed of alpha numeric and special char
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

Test Case 10
    Log To Console    Verify by entering Aadhaar number as 111111111111
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

Test Case 11
    Log To Console    Verify by entering cancelled aadhaar number
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

Test Case 12
    Log To Console    Verify by entering No records aadhaar number
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

Test Case 13
    Log To Console    Verify by entering aadhaar number which is not active
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

Test Case 14
    Log To Console    Verify by entering invalid aadhaar which shows 400
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

Test Case 15
    Log To Console    Verify by entering aadhaar number start from 0
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

Test Case 16
    Log To Console    Verify by entering aadhaar number where verhoff check fails
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

Test Case 17
    Log To Console    Verify by entering invalid aadhaar where verhoff check pass
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

Test Case 18
    Log To Console    Verify by entering valid client ref number
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

Test Case 19
    Log To Console    Verify by entering in-valid clinet ref number
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

Test Case 20
    Log To Console    Verify by entering Leaving client ref number as empty
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

Test Case 21
    Log To Console    Verify by entering Leaving client ref number as empty space
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

Test Case 22
    Log To Console    Verify by entering client ref number more than 45 char
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

Test Case 23
    Log To Console    Verify by entering client ref number as 45 char
    ${auth}=    Create List    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

Test Case 24
    Log To Console    Verify by entering invalid client username
    ${auth}=    Create List    52652631504%    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
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
    ${auth}=    Create List    ${EMPTY}    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
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

Test_case31
    log to console  Verify that the result code 101 is stored in DB
    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_result']}    Aadhaar Number XXXXXXXX6170 Exists!

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT aadhaar, client_ref_num, request_payload, response_payload, http_response_code, result_code, created_on, updated_on FROM validation.kyc_aadhaar_basic_verification_api where http_response_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;

    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}

    FOR    ${row}    IN    @{query_result}
        Log To Console    aadhaar = ${row[0]}
        Log To Console    client_ref_num = ${row[1]}
        Log To Console    request_payload = ${row[2]}
        Log To Console    response_payload = ${row[3]}
        Log To Console    http_response_code = ${row[4]}
        Log To Console    result_code = ${row[5]}
        Log To Console    created_on = ${row[6]}
        Log To Console    updated_on = ${row[7]}
    END


Test_case32
    log to console  Verify that the result code 102 is stored in DB
    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"153118812136", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['message']}    Invalid Aadhaar

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT aadhaar, client_ref_num, request_payload, response_payload, http_response_code, result_code, created_on, updated_on FROM validation.kyc_aadhaar_basic_verification_api where http_response_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}

    FOR    ${row}    IN    @{query_result}
        Log To Console    aadhaar = ${row[0]}
        Log To Console    client_ref_num = ${row[1]}
        Log To Console    request_payload = ${row[2]}
        Log To Console    response_payload = ${row[3]}
        Log To Console    http_response_code = ${row[4]}
        Log To Console    result_code = ${row[5]}
        Log To Console    created_on = ${row[6]}
        Log To Console    updated_on = ${row[7]}
    END

Test_case33
    log to console  Verify that the result code 103 No records is stored in DB
    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"431773858696", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['message']}    No records found for the given Input

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT aadhaar, client_ref_num, request_payload, response_payload, http_response_code, result_code, created_on, updated_on FROM validation.kyc_aadhaar_basic_verification_api where http_response_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}

    FOR    ${row}    IN    @{query_result}
        Log To Console    aadhaar = ${row[0]}
        Log To Console    client_ref_num = ${row[1]}
        Log To Console    request_payload = ${row[2]}
        Log To Console    response_payload = ${row[3]}
        Log To Console    http_response_code = ${row[4]}
        Log To Console    result_code = ${row[5]}
        Log To Console    created_on = ${row[6]}
        Log To Console    updated_on = ${row[7]}
    END

Test_case34
    log to console  Verify that the result code 103 inactive is stored in DB
    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"239169490978", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['message']}    Aadhaar Not Active

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT aadhaar, client_ref_num, request_payload, response_payload, http_response_code, result_code, created_on, updated_on FROM validation.kyc_aadhaar_basic_verification_api where http_response_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}

    FOR    ${row}    IN    @{query_result}
        Log To Console    aadhaar = ${row[0]}
        Log To Console    client_ref_num = ${row[1]}
        Log To Console    request_payload = ${row[2]}
        Log To Console    response_payload = ${row[3]}
        Log To Console    http_response_code = ${row[4]}
        Log To Console    result_code = ${row[5]}
        Log To Console    created_on = ${row[6]}
        Log To Console    updated_on = ${row[7]}
    END

Test_case35
    log to console  Verify by hitting with get captcha fails with fallback true

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case36
    log to console  Verify by hitting with get captcha fails with fallback false

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case37
    log to console  Verify by hitting with get captcha timeout with fallback true

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case38
    log to console  Verify by hitting with get captcha timeout with fallback false

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case39
    log to console  Verify by hitting with submit captcha fails with fallback true

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case40
    log to console  Verify by hitting with submit captcha fails with fallback False

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case41
    log to console  Verify by hitting with submit captcha gets timeout with fallback true

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case42
    log to console  Verify by hitting with submit captcha gets timeout with fallback false

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}


Test_case43
    log to console  Verify by hitting with submit captcha fails where both advanced and basic fails

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case44
    log to console  Verify by hitting with get captcha fails where both advanced and basic fails

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"669446616170", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case45
    log to console  Verify by hitting with get captcha fails with fallback true(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case46
    log to console  Verify by hitting with get captcha fails with fallback false(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case47
    log to console  Verify by hitting with get captcha timeout with fallback true(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case48
    log to console  Verify by hitting with get captcha timeout with fallback false(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case49
    log to console  Verify by hitting with submit captcha fails with fallback true(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case50
    log to console  Verify by hitting with submit captcha fails with fallback False(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case51
    log to console  Verify by hitting with submit captcha gets timeout with fallback true(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case52
    log to console  Verify by hitting with submit captcha gets timeout with fallback false(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}


Test_case53
    log to console  Verify by hitting with submit captcha fails where both advanced and basic fails(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case54
    log to console  Verify by hitting with get captcha fails where both advanced and basic fails(No records)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"954876546868", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case55
    log to console  Verify by hitting with get captcha fails with fallback true(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case56
    log to console  Verify by hitting with get captcha fails with fallback false(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case57
    log to console  Verify by hitting with get captcha timeout with fallback true(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case58
    log to console  Verify by hitting with get captcha timeout with fallback false(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case59
    log to console  Verify by hitting with submit captcha fails with fallback true(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case60
    log to console  Verify by hitting with submit captcha fails with fallback False(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case61
    log to console  Verify by hitting with submit captcha gets timeout with fallback true(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case62
    log to console  Verify by hitting with submit captcha gets timeout with fallback false(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}


Test_case63
    log to console  Verify by hitting with submit captcha fails where both advanced and basic fails(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case64
    log to console  Verify by hitting with get captcha fails where both advanced and basic fails(Deactivated)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case65
    log to console  Verify by hitting with get captcha fails with fallback true(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"322899552578", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case66
    log to console  Verify by hitting with get captcha fails with fallback false(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case67
    log to console  Verify by hitting with get captcha timeout with fallback true(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case68
    log to console  Verify by hitting with get captcha timeout with fallback false(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case69
    log to console  Verify by hitting with submit captcha fails with fallback true(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case70
    log to console  Verify by hitting with submit captcha fails with fallback False(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 }, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case71
    log to console  Verify by hitting with submit captcha gets timeout with fallback true(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": True } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case72
    log to console  Verify by hitting with submit captcha gets timeout with fallback false(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"timeout": 0.01}, "fallback": False } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}


Test_case73
    log to console  Verify by hitting with submit captcha fails where both advanced and basic fails(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "submit_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case74
    log to console  Verify by hitting with get captcha fails where both advanced and basic fails(cancelled)

    ${auth}=    create list    740513625625    RgANJ68JGHaFbkLec0nq1Uo1rXr3F2qz
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/basic_aadhaar   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    503
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}