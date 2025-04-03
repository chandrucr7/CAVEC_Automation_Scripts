*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DatabaseLibrary
Library    urllib3
Library    random
Library    DateTime
Library    JSONLibrary

Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Disconnect From Database

*** Variables ***
${DBName}   validation
${DBUser}   qa.abi.nanthana
${DBPass}   nOu0XNreRyDMEmr
${DBHost}   dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://g206c04f25.execute-api.ap-south-1.amazonaws.com
${file_path}=  C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Passport\\passport.csv
${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Passport\\passport_schema.json

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    file_number=${columns[1]}    client_ref_num=${columns[2]}  dob=${columns[3]}
        Append To List    ${test_data}    ${data}
    END
   RETURN    ${test_data}

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
    ${response}=    Post Request    mysession    /v1/kyc-passport-verification-api    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    Log To Console    ${EMPTY}
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
CAVEC-T6065:
    Log To Console    Verify by entering valid passport number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case0

CAVEC-T6066:
    Log To Console    Verify by entering invalid passport number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

CAVEC-T6067:
    Log To Console    Verify by leaving the passport file number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

CAVEC-T6068:
    Log To Console    Verify that 103 is coming only for no record found case
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

CAVEC-T6069:
    Log To Console    Verify that 102 is coming only for all cases other than no record found
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

CAVEC-T6070:
    Log To Console    Verify by entering passport file number special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

CAVEC-T6071:
    Log To Console    Verify by entering passport file number numeric char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

CAVEC-T6072:
    Log To Console    To verify by leaving empty space in the passport file number field
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7

CAVEC-T6073:
    Log To Console    To verify by entering the passport file number as mixed with numeric,alpha and special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8

CAVEC-T6074:
    Log To Console    To verify by entering the passport file number as alpha char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

CAVEC-T6075:
    Log To Console    To verify by entering the passport file number less than 15 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

CAVEC-T6076:
    Log To Console    To verify by entering the passport file number more than 15 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

CAVEC-T6077:
    Log To Console    To verify by entering the valid dob number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

CAVEC-T6078:
    Log To Console    To verify by entering the invalid dob number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

CAVEC-T6079:
    Log To Console    To verify by leaving dob number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

CAVEC-T6080:
    Log To Console    To verify by entering the wrong format for dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

CAVEC-T6081:
    Log To Console    To verify by entering empty space in the dob number field
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

CAVEC-T6082:
    Log To Console    To verify by entering invalid number (slash instead of -)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

CAVEC-T6083:
    Log To Console    To verify by entering invalid number (slash instead of .)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

CAVEC-T6085:
    Log To Console    To verify by entering invalid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

CAVEC-T6086:
    Log To Console   To verify by entering the client ref number more than 45 characters
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

CAVEC-T6087:
    Log To Console   To verify by leaving the client ref number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

CAVEC-T6088:
    Log To Console   To verify by leaving the client ref number as empty space
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

Testcase 1:
    Log To Console   To verify entering valid authentication
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

Testcase 2:
    Log To Console   To verify entering invalid authentication
    ${auth}=    Create List    526526315047#    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

CAVEC-T6091:
    Log To Console   To verify by entering empty client username
    ${auth}=    Create List    ${EMPTY}    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case25

CAVEC-T6092:
    Log To Console   To verify by entering empty client password
    ${auth}=    Create List    526526315047    ${EMPTY}

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

CAVEC-T6093:
    Log To Console   To verify by entering empty client username and password
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case27

CAVEC-T6089:
    Log To Console   To verify by entering one client username and another client password
    ${auth}=    Create List    526526315047    BI9WnuOcxLBKKgPEB4qtLdADGc9PH0d5

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case28

CAVEC-T6090:
    Log To Console   To verify by entering client id which are not having passport service
    ${auth}=    Create List    21717999    XiNLt8vtsRXoKWkcelzHIAsBfZx7O9XB

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case29

CAVEC-T6094:
    Log To Console     To verify by giving request by Changing the type of request. POST to GET
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

     # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30    # Select the first row

    ${file_number}=    Get From Dictionary    ${row}    file_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${dob}=    Get From Dictionary    ${row}    dob

    ${body}=    create dictionary    file_number=${file_number}    client_ref_num=${client_ref_num}   dob=${dob}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Get Request     mysession     /v1/kyc-passport-verification-api   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
     #Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    #Should Be Equal As Strings  ${response.json()['client_ref_num']}    test
     Should Be Equal As Strings    ${response.json()['message']}    API running successfully!

CAVEC-T6096:
    Log To Console     To verify by giving request by changing the Endpoint url
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

      # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31    # Select the first row

    ${file_number}=    Get From Dictionary    ${row}    file_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${dob}=    Get From Dictionary    ${row}    dob

    ${body}=    create dictionary    file_number=${file_number}    client_ref_num=${client_ref_num}   dob=${dob}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /v1/kyc1-passport-verification-api   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    Should Contain   ${response.text}    Apache APISIX Dashboard

Testcase 3:
    Log To Console   To verify by entering dob format(D/MM/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case32

Testcase 4:
    Log To Console   To verify by entering dob format(DD/M/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case33

Testcase 5:
    Log To Console   To verify by entering dob format(D/M/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case34

Testcase 5:
    Log To Console   To verify by entering dob that accepts upto 31(DD)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    35

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Testcase 6:
    Log To Console   To verify by entering dob that accepts upto 12(MM)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    36

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case36

Testcase 7:
    Log To Console   To verify by entering dob format(DDMMYYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case37

Testcase 8:
    Log To Console   To verify by entering dob format(DD.MM.YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    38

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case38

Testcase 9:
    Log To Console   To verify by entering dob format(DD.MM.YY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    39

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case39

Testcase 10:
    Log To Console   To verify by entering dob format(DDMMYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    40

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case40

Testcase 11:
    Log To Console   Verify that feb month that accepts DD as 31 or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    41

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case41

Testcase 12:
    Log To Console   Verify that feb month that accepts DD as 29 for leap year or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    42

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case42

Testcase 13:
    Log To Console   Verify that feb month that accepts DD as 29 for non-leap year or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    43

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case43

Testcase 14:
    Log To Console   Verify that apr,june,sept,nov accepts 31 or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    44

    ${body}=    Create Dictionary    file_number=${row['file_number']}    client_ref_num=${row['client_ref_num']}   dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case44


######----------------------------- Database ----------------------------#######
Testcase 15:
    Log To Console    Verify the 101 case is stored proper or not in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

      # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${file_number}=    Get From Dictionary    ${row}    file_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${dob}=    Get From Dictionary    ${row}    dob

    ${body}=    create dictionary    file_number=${file_number}    client_ref_num=${client_ref_num}   dob=${dob}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /v1/kyc-passport-verification-api   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    ${requestid}=   Set Variable    ${response.json()['request_id']}
    Log To Console    ${requestid}
    
    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}    pass
    Should Be Equal As Strings    ${response.json()['result_code']}    101

    ${sql_query}=   Set Variable   select autoid,client_id,request_id,file_number,dob,client_ref_num,requestJSON,responseJSON,http_response_code,result_code,is_valid_passport,application_date,passport_number,given_name,surname,date_of_dispatch,remarks,createdOn,updatedOn,purge_status from validation.kyc_passport_verification_api where client_ref_num='pass' and request_id='${requestid}' and result_code='101' order by autoid desc limit 1;
    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    autoid=${row[0]}
        Log To Console    client_id=${row[1]}
        Log To Console    request_id=${row[2]}
        Log To Console    file_number=${row[3]}
        Log To Console    dob=${row[4]}
        Log To Console    client_ref_num=${row[5]}
        Log To Console    requestJSON=${row[6]}
        Log To Console    responseJSON=${row[7]}
        Log To Console    http_response_code=${row[8]}
        Log To Console    result_code=${row[9]}
        Log To Console    is_valid_passport=${row[10]}
        Log To Console    application_date=${row[11]}
        Log To Console    passport_number=${row[12]}
        Log To Console    given_name=${row[13]}
        Log To Console    surname=${row[14]}
        Log To Console    date_of_dispatch=${row[15]}
        Log To Console    remarks=${row[16]}
        Log To Console    createdOn=${row[17]}
        Log To Console    updatedOn=${row[18]}
        Log To Console    purge_status=${row[19]}

    END

#    IF    (${row[19]} == NOT_PURGED and  ${row[8]} == 101)
#        IF    (${row[10]} == 1)
#                 Log To Console     case 101 is stored successfully
#        END
#    ELSE
#       Log To Console    Check
#    END

Testcase 16:
    Log To Console    Verify the 102 case is stored proper or not in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

      # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4    # Select the first row

    ${file_number}=    Get From Dictionary    ${row}    file_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${dob}=    Get From Dictionary    ${row}    dob

    ${body}=    create dictionary    file_number=${file_number}    client_ref_num=${client_ref_num}   dob=${dob}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /v1/kyc-passport-verification-api   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    ${requestid}=   Set Variable    ${response.json()['request_id']}
    Log To Console    ${requestid}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}    pass
    Should Be Equal As Strings    ${response.json()['result_code']}    102

    ${sql_query}=   Set Variable   select autoid,client_id,request_id,file_number,dob,client_ref_num,requestJSON,responseJSON,http_response_code,result_code,is_valid_passport,application_date,passport_number,given_name,surname,date_of_dispatch,remarks,createdOn,updatedOn,purge_status from validation.kyc_passport_verification_api where client_ref_num='pass' and request_id='${requestid}' and result_code='102' order by autoid desc limit 1;
    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    autoid=${row[0]}
        Log To Console    client_id=${row[1]}
        Log To Console    request_id=${row[2]}
        Log To Console    file_number=${row[3]}
        Log To Console    dob=${row[4]}
        Log To Console    client_ref_num=${row[5]}
        Log To Console    requestJSON=${row[6]}
        Log To Console    responseJSON=${row[7]}
        Log To Console    http_response_code=${row[8]}
        Log To Console    result_code=${row[9]}
        Log To Console    is_valid_passport=${row[10]}
        Log To Console    application_date=${row[11]}
        Log To Console    passport_number=${row[12]}
        Log To Console    given_name=${row[13]}
        Log To Console    surname=${row[14]}
        Log To Console    date_of_dispatch=${row[15]}
        Log To Console    remarks=${row[16]}
        Log To Console    createdOn=${row[17]}
        Log To Console    updatedOn=${row[18]}
        Log To Console    purge_status=${row[19]}

    END

Testcase 17:
    Log To Console    Verify the 103 case is stored proper or not in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

      # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3    # Select the first row

    ${file_number}=    Get From Dictionary    ${row}    file_number
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${dob}=    Get From Dictionary    ${row}    dob

    ${body}=    create dictionary    file_number=${file_number}    client_ref_num=${client_ref_num}   dob=${dob}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /v1/kyc-passport-verification-api   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    ${requestid}=   Set Variable    ${response.json()['request_id']}
    Log To Console    ${requestid}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}    pass
    Should Be Equal As Strings    ${response.json()['result_code']}    103

    ${sql_query}=   Set Variable   select autoid,client_id,request_id,file_number,dob,client_ref_num,requestJSON,responseJSON,http_response_code,result_code,is_valid_passport,application_date,passport_number,given_name,surname,date_of_dispatch,remarks,createdOn,updatedOn,purge_status from validation.kyc_passport_verification_api where client_ref_num='pass' and request_id='${requestid}' and result_code='103' order by autoid desc limit 1;
    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    autoid=${row[0]}
        Log To Console    client_id=${row[1]}
        Log To Console    request_id=${row[2]}
        Log To Console    file_number=${row[3]}
        Log To Console    dob=${row[4]}
        Log To Console    client_ref_num=${row[5]}
        Log To Console    requestJSON=${row[6]}
        Log To Console    responseJSON=${row[7]}
        Log To Console    http_response_code=${row[8]}
        Log To Console    result_code=${row[9]}
        Log To Console    is_valid_passport=${row[10]}
        Log To Console    application_date=${row[11]}
        Log To Console    passport_number=${row[12]}
        Log To Console    given_name=${row[13]}
        Log To Console    surname=${row[14]}
        Log To Console    date_of_dispatch=${row[15]}
        Log To Console    remarks=${row[16]}
        Log To Console    createdOn=${row[17]}
        Log To Console    updatedOn=${row[18]}
        Log To Console    purge_status=${row[19]}

    END


########-----------------------------Performance--------------------------------#####
CAVEC-T6106:
    Log To Console    success response is coming within 5 seconds
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    file_number=MD2068134678514    client_ref_num=SUCCESS      dob=04/09/1990
    ${header}=    create dictionary    Content-Type=application/json
    ${start_time}=  Get Current Date
    Log To Console    ${start_time}
    ${response}=    Post Request     mysession     /v1/kyc-passport-verification-api   json=${body}    headers=${header}
    ${end_time}=    Get Current Date
    Log To Console    ${end_time}
    ${time_in_seconds}=     Subtract Date From Date   ${end_time}    ${start_time}
    ${time_in_milliseconds}=    Evaluate    ${time_in_seconds}*1000
    Log To Console    Time taken for the above request: ${time_in_milliseconds}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    #Validation
    Should Be True    ${time_in_milliseconds}<3000  Response come within 5 seconds

CAVEC-T6107:
    Log To Console    Verify the success response is coming within 5 minutes
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    file_number=MD206813467851#    client_ref_num=FAILURE      dob=02/02/1991
    ${header}=    create dictionary    Content-Type=application/json
    ${start_time}=  Get Current Date
    Log To Console    ${start_time}
    ${response}=    Post Request     mysession     /v1/kyc-passport-verification-api   json=${body}    headers=${header}
    ${end_time}=    Get Current Date
    Log To Console    ${end_time}
    ${time_in_seconds}=     Subtract Date From Date   ${end_time}    ${start_time}
    ${time_in_milliseconds}=    Evaluate    ${time_in_seconds}*1000
    Log To Console    ${time_in_milliseconds}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    #Validation
    Should Be True    ${time_in_milliseconds}<3000  Response come within 3 minutes
