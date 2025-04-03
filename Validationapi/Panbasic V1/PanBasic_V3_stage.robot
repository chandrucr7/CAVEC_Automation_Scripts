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
${base_url}=    https://svcstage.digitap.work
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Panbasic V1\\PanBasicData.csv
${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Panbasic V1\\Panbasic_V1_Schema.json


*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}    name=${columns[3]}    name_match_method=${columns[4]}
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
    ${response}=    Post Request    mysession    /validation/kyc/v1/pan_basic    json=${body}    headers=${header}
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
    Log To Console    To verify by entering the valid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

Test Case 2
    Log To Console    To verify by entering the in-valid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

Test Case 3
    Log To Console    To verify by entering the client ref numbe as 45 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

Test Case 4
    Log To Console    To verify by entering the client ref number more than 45 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

Test Case 5
    Log To Console    To verify by leaving the client ref number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

Test Case 6
    Log To Console    To verify by leaving the client ref number as empty space
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

Test Case 7
    Log To Console    Verify by entering Valid pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7

Test Case 8
    Log To Console    Verify by changing the 5th char of the pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8

Test Case 9
    Log To Console    Verify by leaving the pan as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

Test Case 10
    Log To Console    Verify by leaving the pan as empty space
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

Test Case 11
    Log To Console    Entering the pan number in the lower case alphabets
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

Test Case 12
    Log To Console    Entering the pan number more than 10 digit
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

Test Case 13
    Log To Console    Entering the pan number less than 10 digit
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

Test Case 14
    Log To Console    Entering the pan number as alphabets
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

Test Case15
    Log To Console    Entering the pan number as special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

Test Case 16
    Log To Console    Entering the pan number as numeric char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

Test Case 17
    Log To Console    Entering the pan number as mixed with numeric alpha and special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

Test Case 18
    Log To Console    Verify by entering Registered individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

Test Case 19
    Log To Console    Verify by entering Non registered individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

Test Case 20
    Log To Console    Verify by entering Registered Non individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

Test Case 21
    Log To Console    To verify by entering Non registered Non individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

Test Case 22
    Log To Console    To verify by entering Firm/Limited Liability Partnership pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

Test Case 23
    Log To Console    To verify by Entering Hindu Undivided Family (HUF) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

Test Case 24
    Log To Console    To verify by Entering Association of Persons (AOP) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 25
    Log To Console    To verify by Entering Body of Individuals (BOI) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case25

Test Case 26
    Log To Console    To verify by Entering Government Agency pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 27
    Log To Console    To verify Entering Artificial Juridical Person pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case27

Test Case 28
    Log To Console    To verify by entering Local Authority pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case28

Test Case 29
    Log To Console    To verify by Entering Trust pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case29

Test Case 30
    Log To Console    To verify by Entering Company pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case30

Test Case 31
    Log To Console    Verify by entering Death pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case31

Test Case 32
    Log To Console    Verify by entering deactivated pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case32

Test Case 33
    Log To Console    Verify by entering deleted pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case33

Test Case 34
    Log To Console    Verify by entering Fake pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case34

Test Case 35
    Log To Console    Verify by entering Valid name matching to the pan number(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test Case 36
    Log To Console    Verify by entering Invalid name (mixed with numeric character)(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    35
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case36

Test Case 37
    Log To Console    Verify by entering Invalid name (mixed with special character)(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    36
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case37

Test Case 38
    Log To Console    Verify by entering Name which not match to the pan number(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case38

Test Case 39
    Log To Console    Verify by entering Name as empty(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    38
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case39

Test Case 40
    Log To Console    Verify by entering Empty space in name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    39
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case40

Test Case 41
    Log To Console    Verify by entering Name with space at each character(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    40
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case41

Test Case 42
    Log To Console    Verify by entering Dot in the name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    41
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case42

Test Case 43
    Log To Console    Verify by entering First name last name middle name (proper Name)(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    42
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case43

Test Case 44
    Log To Console    Verify by entering Middle name first name last name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    44
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case44

Test Case 45
    Log To Console    Verify by entering last name middle name first name (Reverse order)(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    44
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case45

Test Case 46
    Log To Console    Verify by entering First name only(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    45
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case46

Test Case 47
    Log To Console    Verify by entering last name only(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    46
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case47

Test Case 48
    Log To Console    Verify by entering First letter of first name and first letter of last name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    47
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case48

Test Case49
    Log To Console    Verify by entering Proper First name and last name as initial(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    48
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case49

Test Case 50
    Log To Console    Verify by entering First name as initial and proper last name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    49
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case50

Test Case 51
    Log To Console    Verify by entering First valid name and last name as other person name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    50
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case51

Test Case 52
    Log To Console    Verify by entering Name with five empty space in middle(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    51
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case52

Test Case 53
    Log To Console    Verify by entering upper case first name and lower case last name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    52
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case53

Test Case 54
    Log To Console    Verify by entering lower case first name and upper case last name(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    53
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case54

Test Case 55
    Log To Console    Verify by entering Entering only half name in proper order(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    54
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case55

Test Case 56
    Log To Console    Verify by entering Entering only half name in reverse order(fuzzy)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    55
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case56

Test Case 57
    Log To Console    Verify by entering Valid name matching to the pan number(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    56
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case57

Test Case 58
    Log To Console    Verify by entering Invalid name (mixed with numeric character)(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    57
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case58

Test Case 59
    Log To Console    Verify by entering Invalid name (mixed with special character)(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    58
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case59

Test Case 60
    Log To Console    Verify by entering Name which not match to the pan number(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    59
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case60

Test Case 61
    Log To Console    Verify by entering Name as empty(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    60
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case61

Test Case 62
    Log To Console    Verify by entering Empty space in name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    61
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case62

Test Case 63
    Log To Console    Verify by entering Name with space at each character(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    62
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case63

Test Case 64
    Log To Console    Verify by entering Dot in the name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    63
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case64

Test Case 65
    Log To Console    Verify by entering First name last name middle name (proper Name)(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    64
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case65

Test Case 66
    Log To Console    Verify by entering Middle name first name last name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    65
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case66

Test Case 67
    Log To Console    Verify by entering last name middle name first name (Reverse order)(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    66
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case67

Test Case 68
    Log To Console    Verify by entering First name only(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    67
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case68

Test Case 69
    Log To Console    Verify by entering last name only(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    68
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case69

Test Case 70
    Log To Console    Verify by entering First letter of first name and first letter of last name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    69
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case70

Test Case71
    Log To Console    Verify by entering Proper First name and last name as initial(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    70
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case71

Test Case 72
    Log To Console    Verify by entering First name as initial and proper last name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    71
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case72

Test Case 73
    Log To Console    Verify by entering First valid name and last name as other person name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    72
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case73

Test Case 74
    Log To Console    Verify by entering Name with five empty space in middle(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    73
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case74

Test Case 75
    Log To Console    Verify by entering upper case first name and lower case last name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    74
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case75

Test Case 76
    Log To Console    Verify by entering lower case first name and upper case last name(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    75
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case76

Test Case 77
    Log To Console    Verify by entering Entering only half name in proper order(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    76
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case77

Test Case 78
    Log To Console    Verify by entering Entering only half name in reverse order(exact)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    77
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case78

Test Case 79
    Log To Console    Verify by entering Valid name matching to the pan number(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    78
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case79

Test Case 80
    Log To Console    Verify by entering Invalid name (mixed with numeric character)(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    79
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case80

Test Case 81
    Log To Console    Verify by entering Invalid name (mixed with special character)(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    58
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case81

Test Case 82
    Log To Console    Verify by entering Name which not match to the pan number(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    81
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case82

Test Case 83
    Log To Console    Verify by entering Name as empty(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    82
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case83

Test Case 84
    Log To Console    Verify by entering Empty space in name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    83
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case84

Test Case 85
    Log To Console    Verify by entering Name with space at each character(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    84
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case85

Test Case 86
    Log To Console    Verify by entering Dot in the name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    85
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case86

Test Case 87
    Log To Console    Verify by entering First name last name middle name (proper Name)(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    86
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case87

Test Case 88
    Log To Console    Verify by entering Middle name first name last name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    87
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case88

Test Case 89
    Log To Console    Verify by entering last name middle name first name (Reverse order)(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    88
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case89

Test Case 90
    Log To Console    Verify by entering First name only(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    89
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case90

Test Case 91
    Log To Console    Verify by entering last name only(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    90
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case91

Test Case 92
    Log To Console    Verify by entering First letter of first name and first letter of last name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    91
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case92

Test Case93
    Log To Console    Verify by entering Proper First name and last name as initial(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    92
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case93

Test Case 94
    Log To Console    Verify by entering First name as initial and proper last name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    93
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case72

Test Case 95
    Log To Console    Verify by entering First valid name and last name as other person name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    94
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case95

Test Case 96
    Log To Console    Verify by entering Name with five empty space in middle(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    95
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case96

Test Case 97
    Log To Console    Verify by entering upper case first name and lower case last name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    96
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case97

Test Case 98
    Log To Console    Verify by entering lower case first name and upper case last name(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    97
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case98

Test Case 99
    Log To Console    Verify by entering Entering only half name in proper order(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    98
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case99

Test Case 100
    Log To Console    Verify by entering Entering only half name in reverse order(dg_name_match)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    99
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case100

Test_case101
    log to console  Verify that the result code 101 is stored in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_basic   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['name']}    DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['pan_display_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['status']}    Active
    Should Be Equal As Strings  ${response.json()['result']['seeding_status']}    Y
    Should Be Equal As Strings  ${response.json()['result']['name_validated']}    Y
    Should Be Equal As Strings  ${response.json()['result']['name_match']}    False
    Should Be Equal As Strings  ${response.json()['result']['name_match_score']}    0

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT pan, client_ref_num, request_payload, response_payload, http_status_code, result_code, source, name, response_name, it_response, tat, name_source, nsdl_tat, created_on, updated_on FROM validation.kyc_pan_basic_api where http_status_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    pan = ${row[0]}
        Log To Console    client_ref_num = ${row[1]}
        Log To Console    request_payload = ${row[2]}
        Log To Console    response_payload = ${row[3]}
        Log To Console    http_status_code = ${row[4]}
        Log To Console    result_code = ${row[5]}
        Log To Console    source = ${row[6]}
        Log To Console    name = ${row[7]}
        Log To Console    response_name = ${row[8]}
        Log To Console    it_response = ${row[9]}
        Log To Console    tat = ${row[10]}
        Log To Console    name_source = ${row[11]}
        Log To Console    nsdl_tat = ${row[12]}
        Log To Console    created_on = ${row[13]}
        Log To Console    updated_on = ${row[14]}

    END

Test_case102
    log to console  Verify that the result code 102 is stored in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"LJKPK2266E", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_basic   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['message']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['result']['pan']}    LJKPK2266E
    Should Be Equal As Strings  ${response.json()['result']['name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['pan_display_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['status']}    Invalid
    Should Be Equal As Strings  ${response.json()['result']['seeding_status']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['name_validated']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['name_match']}    False
    Should Be Equal As Strings  ${response.json()['result']['name_match_score']}    0

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT pan, client_ref_num, request_payload, response_payload, http_status_code, result_code, source, name, response_name, it_response, tat, name_source, nsdl_tat, created_on, updated_on FROM validation.kyc_pan_basic_api where http_status_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    pan = ${row[0]}
        Log To Console    client_ref_num = ${row[1]}
        Log To Console    request_payload = ${row[2]}
        Log To Console    response_payload = ${row[3]}
        Log To Console    http_status_code = ${row[4]}
        Log To Console    result_code = ${row[5]}
        Log To Console    source = ${row[6]}
        Log To Console    name = ${row[7]}
        Log To Console    response_name = ${row[8]}
        Log To Console    it_response = ${row[9]}
        Log To Console    tat = ${row[10]}
        Log To Console    name_source = ${row[11]}
        Log To Console    nsdl_tat = ${row[12]}
        Log To Console    created_on = ${row[13]}
        Log To Console    updated_on = ${row[14]}

    END

Test_case103
    log to console  Verify that the result code 103 is stored in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPX6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_basic   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['message']}    No record found for the given input
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BJPPX6837G
    Should Be Equal As Strings  ${response.json()['result']['name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['pan_display_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['status']}    Invalid
    Should Be Equal As Strings  ${response.json()['result']['seeding_status']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['name_validated']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['name_match']}    False
    Should Be Equal As Strings  ${response.json()['result']['name_match_score']}    0

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT pan, client_ref_num, request_payload, response_payload, http_status_code, result_code, source, name, response_name, it_response, tat, name_source, nsdl_tat, created_on, updated_on FROM validation.kyc_pan_basic_api where http_status_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    pan = ${row[0]}
        Log To Console    client_ref_num = ${row[1]}
        Log To Console    request_payload = ${row[2]}
        Log To Console    response_payload = ${row[3]}
        Log To Console    http_status_code = ${row[4]}
        Log To Console    result_code = ${row[5]}
        Log To Console    source = ${row[6]}
        Log To Console    name = ${row[7]}
        Log To Console    response_name = ${row[8]}
        Log To Console    it_response = ${row[9]}
        Log To Console    tat = ${row[10]}
        Log To Console    name_source = ${row[11]}
        Log To Console    nsdl_tat = ${row[12]}
        Log To Console    created_on = ${row[13]}
        Log To Console    updated_on = ${row[14]}

    END

Test Case 104
    Log To Console    Verify by entering Valid authentication
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

Test Case 105
    Log To Console    Verify by entering in-Valid authentication
    ${auth}=    Create List    52652631504$    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case101

Test Case 106
    Log To Console    Verify by Leaving client user name as empty
    ${auth}=    Create List    ${EMPTY}    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case101

Test Case 107
    Log To Console    Verify by leaving client password as empty
    ${auth}=    Create List    526526315047    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case101

Test Case 108
    Log To Console    Verify by leaving client username and password as empty
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case101

Test Case109
    Log To Console    Verify by entering authentication which don't having pan basic V1 service
    ${auth}=    Create List    21717999100    XiNLt8vtsRXoKWkcelzHIAsBfZx7O9XB
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case101