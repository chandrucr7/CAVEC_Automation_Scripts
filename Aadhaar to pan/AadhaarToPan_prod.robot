*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    CSVLibrary
Library    String
Library    JSONLibrary
Library    urllib3
Library    random



*** Variables ***
${base_url}=    https://svcstage.digitap.work
#${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\PanFname_Data.csv
${file_path}=  C:\\Users\\DELL\\PycharmProjects\\KYCValidations\\Validationapi\\Aadhaar to pan\\AadhaarToPanData.csv
#${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\Pan_to_aadhaar_Json_Schema.json
${json_schema_file}=  C:\\Users\\DELL\\PycharmProjects\\KYCValidations\\Validationapi\\Aadhaar to pan\\Aadhaar_to_pan_Json_schema.json


*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    aadhaar=${columns[1]}   client_ref_num=${columns[2]}
        Append To List    ${test_data}    ${data}
    END
    RETURN    ${test_data}

Validate JSON Response
    [Arguments]    ${expected_json}    ${actual_json}
    ${expected_keys}=    Get Dictionary Keys    ${expected_json}
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
    ${response}=    Post Request    mysession    /validation/kyc/v1/aadhaar_to_masked_pan    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
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
    Log To Console    Verify by entering valid linked aadhaar number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

Test Case 2
    Log To Console    Verify by entering valid not linked aadhaar number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

Test Case 3
    Log To Console    Verify by entering in-valid aadhaar number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

Test Case 4
    Log To Console    Verify by entering aadhaar number as numeric char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

Test Case 5
    Log To Console    Verify by entering aadhaar number as alpha char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

Test Case 6
    Log To Console    Verify by entering aadhaar number special char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

Test Case 7
    Log To Console    mixed of alpha numeric special char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7


Test Case 8
    Log To Console    Verify by entering aadhaar number less than 12 char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8

Test Case 9
    Log To Console    Verify by entering aadhaar number more than 12 char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

Test Case 10
    Log To Console    Verify by leaving aadhaar number empty
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

Test Case 11
    Log To Console    Verify by leaving aadhaar number empty space
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

Test Case 12
    Log To Console    Verify by valid client ref number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

Test Case 13
    Log To Console    Verify by in-valid client ref number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

Test Case 14
    Log To Console    Verify by leaving client ref number empty
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

Test Case15
    Log To Console    Verify by leaving client ref number empty space
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

Test Case 16
    Log To Console    Verify by entering client ref number as 45 char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

Test Case 17
    Log To Console    Verify by entering client ref number more than 45 char
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

Test Case 18
    Log To Console    Verify by entering cancelled aadhaar number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

Test Case 19
    Log To Console    Verify by entering inactive aadhaar number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

Test Case 20
    Log To Console    Verify by entering inactive aadhaar number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

Test Case 21
    Log To Console    Verify by entering aadhaar number starts with 0
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

Test Case 22
    Log To Console    Verify by entering verhoff check aadhaar number
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

Test Case 23
    Log To Console    Verify by entering invalid aadhaar verhoff check passed
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

Test Case 24
    Log To Console    Verify by entering invalid aadhaar as all ones
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 25
    Log To Console    Verify by entering invalid aadhaar as 111111111115
    ${auth}=    Create List    740513625625    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case25

Test Case 26
    Log To Console    Verify by entering invalid client username
    ${auth}=    Create List    52652631504%    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    aadhaar=${row['aadhaar']}   client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 27
    Log To Console    Verify by entering invalid client password
    ${auth}=    Create List    740513625625    EA6F34B4B3B618A10CF5C2223229077@
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    aadhaar=${row['aadhaar']}   client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 28
    Log To Console    Verify by entering invalid client username and password
    ${auth}=    Create List    52652631504%    EA6F34B4B3B618A10CF5C2223229077#
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    aadhaar=${row['aadhaar']}   client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 29
    Log To Console    Verify by leaving client username as empty
    ${auth}=    Create List    ${EMPTY}    fGLjjl5qOpzdl5Udb69Q6H3cND1t64CB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    aadhaar=${row['aadhaar']}   client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 30
    Log To Console    Verify by leaving client password as empty
    ${auth}=    Create List    740513625625    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    aadhaar=${row['aadhaar']}   client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 31
    Log To Console    Verify by leaving client username and password as empty
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    aadhaar=${row['aadhaar']}   client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 32
    Log To Console    Verify by entering client doesnt have the aadhaar to pan api
    ${auth}=    Create List    740513625625    EA6F34B4B3B618A10CF5C22232290779
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar']}    aadhaar=${row['aadhaar']}   client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26