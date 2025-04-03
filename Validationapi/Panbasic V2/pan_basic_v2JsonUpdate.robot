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
${DBHost}   digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Panbasic V2\\PanbasicData.csv
${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Panbasic V2\\pan_basic_v2_schema.json

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}    name=${columns[3]}      dob=${columns[4]}
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
    ${response}=    Post Request    mysession    /validation/kyc/v2/pan_basic    json=${body}    headers=${header}
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
CAVEC-T3320:
    Log To Console    To verify by entering valid Pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

CAVEC-T3321:
    Log To Console    To verify by changing the 5th char of Pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

CAVEC-T3322:
    Log To Console    To verify by leaving the pan as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

CAVEC-T3323:
    Log To Console    To verify by leaving empty space in the pan number field
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

CAVEC-T3324:
    Log To Console    To verify by entering the pan number in the lower case alphabets
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

CAVEC-T3325:
    Log To Console    To verify by entering the pan number more than 10 digit
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

CAVEC-T3326:
    Log To Console    To verify by entering the pan number less than 10 digit
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7

CAVEC-T3327:
    Log To Console    To verify by entering the pan number as alphabets
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8

CAVEC-T3328:
    Log To Console    To verify by entering the pan number as special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

CAVEC-T3329:
    Log To Console    To verify by entering the pan number as numeric char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

CAVEC-T3330:
    Log To Console    To verify by entering the pan number as mixed with numeric,alpha and special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

CAVEC-T3332:
    Log To Console    To verify by entering registered individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

CAVEC-T3333:
    Log To Console    To verify by entering non-registered individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

CAVEC-T3334:
    Log To Console    To verify by entering registered non-individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

CAVEC-T3335:
    Log To Console    To verify by entering non-registered non-individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

CAVEC-T3336:
    Log To Console    To verify by entering Firm/Limited liablity Partnership pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

CAVEC-T3337:
    Log To Console    To verify by entering Hindu undivided family pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

CAVEC-T3338:
    Log To Console    To verify by entering Associations of Persons pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

CAVEC-T3339:
    Log To Console    To verify by entering Body od individuals pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

CAVEC-T3340:
    Log To Console    To verify by entering Government Agency pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

CAVEC-T3341:
    Log To Console    To verify by entering Artificial Judicial persons pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

CAVEC-T3342:
    Log To Console    To verify by entering Local authority pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

CAVEC-T3343:
    Log To Console    To verify by entering Trust pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

CAVEC-T3344:
    Log To Console    To verify by entering company pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

CAVEC-T3345:
    Log To Console    To verify by entering death pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case25

CAVEC-T3346:
    Log To Console    To verify by entering invalid(deactivated) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

CAVEC-T3347:
    Log To Console    To verify by entering invalid(deleted) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case27

CAVEC-T3348:
    Log To Console    To verify by entering Fake pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case28

CAVEC-T3349:
    Log To Console    To verify by entering valid name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case29

CAVEC-T3350:
    Log To Console    To verify by entering name with mixed of alpha and numeric
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    35

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case30

CAVEC-T3351:
    Log To Console    To verify by entering name with mixed of alpha and special
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    36

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case31

CAVEC-T3352:
    Log To Console    To verify by entering name as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case32

CAVEC-T3353:
    Log To Console    To verify by entering name as emptyspace
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    38

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case33

CAVEC-T3354:
    Log To Console    To verify by entering name as Alphabets
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    39

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case34

CAVEC-T3355:
    Log To Console    To verify by entering name as special characters
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    40

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

CAVEC-T3356:
    Log To Console    To verify by entering name as numeric characters
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    41

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case36

CAVEC-T3357:
    Log To Console    To verify by entering name in upper case
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    42

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case37

CAVEC-T3358:
    Log To Console    To verify by entering name in lower case
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    43

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case38

CAVEC-T3359:
    Log To Console    Empty space infront of name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    72

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case39

CAVEC-T3360:
    Log To Console    Empty space infront of name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    73

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case40

CAVEC-T3361:
    Log To Console    Multiple space in between the name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    44

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case41

CAVEC-T3362:
    Log To Console    To verify by entering valid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case42

CAVEC-T3363:
    Log To Console    To verify by entering invalid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case43

CAVEC-T3364:
    Log To Console    To verify by entering client ref number as 45 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case44

CAVEC-T3365:
    Log To Console    To verify by entering client ref number more than 45 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case45

CAVEC-T3366:
    Log To Console    To verify by leaving the client ref number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case46

CAVEC-T3367:
    Log To Console    To verify by leaving the client ref number as empty space
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case47

CAVEC-T3369:
    Log To Console    To verify by entering valid dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    74

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case48

CAVEC-T3370:
    Log To Console    To verify by entering invalid dob(26/02-1999)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    75

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case49

CAVEC-T3371:
    Log To Console    To verify by entering empty field in dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    76

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case50

CAVEC-T3372:
    Log To Console    To verify by entering empty space in dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    77

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case51

CAVEC-T3373:
    Log To Console    To verify by entering the dob format(26-02-1999)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    78

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case52

CAVEC-T3374:
    Log To Console    To verify by entering the dob format(Month and Date)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    79

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case53

CAVEC-T3375:
    Log To Console    To verify by entering the dob format(Reverse order)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    80

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case54

CAVEC-T3376:
    Log To Console    To verify by entering the dob in alpha case
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    81

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case55

CAVEC-T3377:
    Log To Console    To verify by entering the dob in special case
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    82

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case56

CAVEC-T3378:
    Log To Console    To verify by entering empty space instead of slash
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    83

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case57

CAVEC-T3382:
    Log To Console    To verify by entering valid authentication
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case58

CAVEC-T3383:
    Log To Console    To verify by entering invalid authentication
    ${auth}=    Create List    526526315047#    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case59

CAVEC-T3385:
    Log To Console    To verify by entering one client username and other client password
    ${auth}=    Create List    740513625625    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case60

CAVEC-T3386:
    Log To Console    To verify by entering client not having pan basic v2 service
    ${auth}=    Create List    21717999    XiNLt8vtsRXoKWkcelzHIAsBfZx7O9XB

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case60

CAVEC-T3387:
    Log To Console    To verify by entering empty username
    ${auth}=    Create List    ${EMPTY}    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case60

CAVEC-T3388:
    Log To Console    To verify by entering empty password
    ${auth}=    Create List    526526315047    ${EMPTY}

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case60

CAVEC-T3389:
    Log To Console    To verify by entering empty username and password
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case60

CAVEC-T3875:
    Log To Console    To verify by entering the dob format as (DD-MM-YYYY)
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    78

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case61

CAVEC-T3876:
    Log To Console    To verify by entering the dob format as (0D/0M/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    45

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case62

CAVEC-T3877:
    Log To Console    To verify by entering the dob format as (2D/MM/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    46

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case63

CAVEC-T3878:
    Log To Console    To verify by entering the dob format as (3D/MM/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    47

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case64

CAVEC-T3879:
    Log To Console    To verify by entering the dob format as (DD/2M/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    48

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case65

CAVEC-T3880:
    Log To Console    To verify by entering the dob format as (DD/3M/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    49

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case66

CAVEC-T3881:
    Log To Console    To verify by entering the dob format as (DD/MM/0YYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    50

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case67

CAVEC-T3882:
    Log To Console    To verify by entering the dob format as (DDMMYYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    51

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case68

CAVEC-T3883:
    Log To Console    To verify by entering the dob format as (DD.MM.YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    52

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case69

CAVEC-T3884:
    Log To Console    To verify by entering the dob format as (DD.MM.YY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    53

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case70

CAVEC-T3885:
    Log To Console    To verify by entering the dob format as (DDMMYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    54

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case71

CAVEC-T3887:
    Log To Console    To verify that feb month accepts DD as 31 or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    55

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case72

CAVEC-T3888:
    Log To Console    To verify that feb month accepts DD as 29 for leap year or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    56

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case73

CAVEC-T3889:
    Log To Console    To verify that feb month accepts DD as 29 for non-leap year or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    57

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case74

CAVEC-T3890:
    Log To Console    To verify that apr,june,sept,nov accepts 31 or not
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    58

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case75

CAVEC-T3892:
    Log To Console    To verify by entering dob in MM/DD/YYYY
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    59

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case76

CAVEC-T3893:
    Log To Console    To verify by entering dob in YYYY/MM/DD
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    60

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case77

CAVEC-T3894:
    Log To Console    To verify by entering dob in DD/YYYY/MM
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    61

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case78

CAVEC-T3895:
    Log To Console    To verify by entering dob in YYYY/MM/DD
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    60

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case79

CAVEC-T3896:
    Log To Console    To verify by entering dob in YYYY/DD/MM
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    62

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case80

CAVEC-T3897:
    Log To Console    To verify by empty dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    63

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case81

CAVEC-T3898:
    Log To Console    To verify by empty space in dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    64

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case81

CAVEC-T3899:
    Log To Console    To verify by entering alpha char in dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    65

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case81

CAVEC-T3900:
    Log To Console    To verify by entering special char in dob
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    66

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case81

CAVEC-T3901:
    Log To Console    To verify by entering dob that accepts upto 31(DD)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    67

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case82

CAVEC-T3902:
    Log To Console    To verify by entering dob that accepts upto 12(MM)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    68

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case83

CAVEC-T3903:
    Log To Console    To verify by entering dob format(D/MM/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    69

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case84

CAVEC-T3904:
    Log To Console    To verify by entering dob format(DD/M/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    70

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case84

CAVEC-T3905:
    Log To Console    To verify by entering dob format(D/M/YYYY)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    71

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case84

CAVEC-T4690:
    Log To Console    To verify by entering invalid pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    84

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case84

CAVEC-T4691:
    Log To Console    To verify by entering invalid name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    85

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case110

CAVEC-T4692:
    Log To Console    To verify by entering name which is not matched to the pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    86

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case85

CAVEC-T4693:
    Log To Console    To verify by entering name with reverse order
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    87

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case86

CAVEC-T4694:
    Log To Console    To verify by entering name with dot added in it
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    88

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case87

CAVEC-T4695:
    Log To Console    To verify by entering firstname,lastname,middle name (proper name)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    89

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case88

CAVEC-T4696:
    Log To Console    To verify by entering middlename firstname lastname
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    90

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case89

CAVEC-T4697:
    Log To Console    To verify by entering lastname middlename firstname (Reverse order)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    91

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case90

CAVEC-T4698:
    Log To Console    To verify by entering firstname only
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    92

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case91

CAVEC-T4699:
    Log To Console    To verify by entering lastname only
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    93

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case92

CAVEC-T4700:
    Log To Console    To verify by entering first char of first name and first letter of last name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    94

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case93

CAVEC-T4701:
    Log To Console    To verify by entering proper firstname and last name as initial
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    95

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case94

CAVEC-T4702:
    Log To Console    To verify by entering firstname and last name as initial
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    96

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case95

CAVEC-T4703:
    Log To Console    To verify by entering first valid name and last name as other person name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    97

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case96

CAVEC-T4704:
    Log To Console    To verify by entering uppercase first name and lower case last name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    98

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case97

CAVEC-T4705:
    Log To Console    To verify by entering lowercase first name and uppercase last name
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    99

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case98

CAVEC-T4706:
    Log To Console    To verify by entering name in reverse order with initial
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    100

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case99

CAVEC-T4707:
    Log To Console    To verify by entering first name in reverse order
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    101

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case100

CAVEC-T4708:
    Log To Console    To verify by entering buisness pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    102

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case101

CAVEC-T4709:
    Log To Console    To verify by entering proper firstname middlename lastname buisness pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    103

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case102

CAVEC-T4710:
    Log To Console    To verify by changing the name as middlename firstname lastname(buisness)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    104

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case103

CAVEC-T4711:
    Log To Console    To verify by entering the name as lastname middlename firstname lastname(buisness)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    105

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case104

CAVEC-T4712:
    Log To Console    To verify by entering last half name name only(buisness)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    106

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case105

CAVEC-T4713:
    Log To Console    To verify by entering firstname only(buisness)
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    107

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case106

CAVEC-T4714:
    Log To Console    To verify by entering pan number with & symbol in it
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    108

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case107

CAVEC-T4715:
    Log To Console    To verify by entering no record found pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    109

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case108

CAVEC-T4716:
    Log To Console    To verify by entering invalid regex pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    110

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}   name=${row['name']}     dob=${row['dob']}
    Send Post Request And Validate    ${auth}   ${body}    ${json_schema_file}    case109


#####--------------------------Database---------------------------------#####
Testcase1:
    Log To Console    To verify that the id,ent_id,pan,provider_log_api_id,client_ref_num,request_payload,response_payload,request_id,http_response_code,result_code,source,tat,created_on,updated_on is storing in the DB or not (101 CASE)

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BJPPC6837G    client_ref_num=DB101     name=chandra prakash D      dob=26/02/1999
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_basic   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
    #${resultcode}=  Set Variable    ${response.json()['result_code']}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}     DB101
    Should Be Equal As Strings    ${response.json()['result_code']}    101



    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,provider_api_log_id,client_ref_num,request_payload,response_payload,request_id,http_status_code,result_code,source,tat,created_on,updated_on FROM validation.kyc_pan_basic_v2_api where client_ref_num='DB101' and result_code='101'order by id desc limit 1;

    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    id=${row[0]}
        Log To Console    ent_id=${row[1]}
        Log To Console    pan=${row[2]}
        Log To Console    provider_log_api_id=${row[3]}
        Log To Console    client_ref_num=${row[4]}
        Log To Console    request_payload=${row[5]}
        Log To Console    response_payload=${row[6]}
        Log To Console    request_id=${row[7]}
        Log To Console    http_status_code=${row[8]}
        Log To Console    result_code=${row[9]}
        Log To Console    source=${row[10]}
        Log To Console    tat=${row[11]}
        Log To Console    created_on=${row[12]}
        Log To Console    updated_on=${row[13]}
    END
    ${provider_log_api_id_table}=  Set Variable      ${row[3]}
    
    ${sql_query1}=  Set Variable    select id,request_payload,response_payload,http_status_code,source,tat,created_on from validation.kyc_pan_basic_provider_api_logs where id=${provider_log_api_id_table} and source='V2' order by id desc;
    ${query_results_providertable}=     Query    ${sql_query1}
    
    FOR    ${rowProvider}    IN    @{query_results_providertable}
        Log To Console    id=${rowProvider[0]}
        Log To Console    request_payload=${rowProvider[1]}
        Log To Console    response_payload=${rowProvider[2]}
        Log To Console    http_status_code=${rowProvider[3]}
        Log To Console    source=${rowProvider[4]}
        Log To Console    tat=${rowProvider[5]}
        Log To Console    created_on=${rowProvider[6]}
         
    END
    ${provider_table_id}=   Set Variable    ${rowProvider[0]}

    IF    (${provider_table_id} == ${provider_log_api_id_table})
        Log To Console    Details are succcessfully stored in provider table
    ELSE
        Log To Console    Details are not properly stored
    END


Testcase2:
    Log To Console    To verify that the id,ent_id,pan,provider_log_api_id,client_ref_num,request_payload,response_payload,request_id,http_response_code,result_code,source,tat,created_on,updated_on is storing in the DB or not (102 CASE)

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=LJKPK2266E    client_ref_num=DB102     name=chandra prakash D      dob=26/02/1999
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_basic   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
    #${resultcode}=  Set Variable    ${response.json()['result_code']}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}     DB102
    Should Be Equal As Strings    ${response.json()['result_code']}    102



    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,provider_api_log_id,client_ref_num,request_payload,response_payload,request_id,http_status_code,result_code,source,tat,created_on,updated_on FROM validation.kyc_pan_basic_v2_api where client_ref_num='DB102' and result_code='102' order by id desc limit 1;

    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    id=${row[0]}
        Log To Console    ent_id=${row[1]}
        Log To Console    pan=${row[2]}
        Log To Console    provider_log_api_id=${row[3]}
        Log To Console    client_ref_num=${row[4]}
        Log To Console    request_payload=${row[5]}
        Log To Console    response_payload=${row[6]}
        Log To Console    request_id=${row[7]}
        Log To Console    http_status_code=${row[8]}
        Log To Console    result_code=${row[9]}
        Log To Console    source=${row[10]}
        Log To Console    tat=${row[11]}
        Log To Console    created_on=${row[12]}
        Log To Console    updated_on=${row[13]}
    END
    ${provider_log_api_id_table}=  Set Variable      ${row[3]}

    ${sql_query1}=  Set Variable    select id,request_payload,response_payload,http_status_code,source,tat,created_on from validation.kyc_pan_basic_provider_api_logs where id=${provider_log_api_id_table} and source='V2' order by id desc;
    ${query_results_providertable}=     Query    ${sql_query1}

    FOR    ${rowProvider}    IN    @{query_results_providertable}
        Log To Console    id=${rowProvider[0]}
        Log To Console    request_payload=${rowProvider[1]}
        Log To Console    response_payload=${rowProvider[2]}
        Log To Console    http_status_code=${rowProvider[3]}
        Log To Console    source=${rowProvider[4]}
        Log To Console    tat=${rowProvider[5]}
        Log To Console    created_on=${rowProvider[6]}

    END
    ${provider_table_id}=   Set Variable    ${rowProvider[0]}

    IF    (${provider_table_id} == ${provider_log_api_id_table})
        Log To Console    Details are succcessfully stored in provider table for 102  case
    ELSE
        Log To Console    Details are not properly stored for 102 case
    END

Testcase3:
    Log To Console    To verify that the id,ent_id,pan,provider_log_api_id,client_ref_num,request_payload,response_payload,request_id,http_response_code,result_code,source,tat,created_on,updated_on is storing in the DB or not (103 CASE)

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BJPPX6837G    client_ref_num=DB103     name=chandra prakash D      dob=26/02/1999
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_basic   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
    #${resultcode}=  Set Variable    ${response.json()['result_code']}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}     DB103
    Should Be Equal As Strings    ${response.json()['result_code']}    103



    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,provider_api_log_id,client_ref_num,request_payload,response_payload,request_id,http_status_code,result_code,source,tat,created_on,updated_on FROM validation.kyc_pan_basic_v2_api where client_ref_num='DB103' and result_code='103' order by id desc limit 1;

    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    id=${row[0]}
        Log To Console    ent_id=${row[1]}
        Log To Console    pan=${row[2]}
        Log To Console    provider_log_api_id=${row[3]}
        Log To Console    client_ref_num=${row[4]}
        Log To Console    request_payload=${row[5]}
        Log To Console    response_payload=${row[6]}
        Log To Console    request_id=${row[7]}
        Log To Console    http_status_code=${row[8]}
        Log To Console    result_code=${row[9]}
        Log To Console    source=${row[10]}
        Log To Console    tat=${row[11]}
        Log To Console    created_on=${row[12]}
        Log To Console    updated_on=${row[13]}
    END
    ${provider_log_api_id_table}=  Set Variable      ${row[3]}

    ${sql_query1}=  Set Variable    select id,request_payload,response_payload,http_status_code,source,tat,created_on from validation.kyc_pan_basic_provider_api_logs where id=${provider_log_api_id_table} and source='V2' order by id desc;
    ${query_results_providertable}=     Query    ${sql_query1}

    FOR    ${rowProvider}    IN    @{query_results_providertable}
        Log To Console    id=${rowProvider[0]}
        Log To Console    request_payload=${rowProvider[1]}
        Log To Console    response_payload=${rowProvider[2]}
        Log To Console    http_status_code=${rowProvider[3]}
        Log To Console    source=${rowProvider[4]}
        Log To Console    tat=${rowProvider[5]}
        Log To Console    created_on=${rowProvider[6]}

    END
    ${provider_table_id}=   Set Variable    ${rowProvider[0]}

    IF    (${provider_table_id} == ${provider_log_api_id_table})
        Log To Console    Details are succcessfully stored in provider table for 103 case
    ELSE
        Log To Console    Details are not properly stored for 103 case
    END

#####------------------------PERFORMANCE ---------------------------#####
Testcase 4:
    Log To Console    Verify the success response is coming within 5 minutes
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=SUCCESS   name=abi nanthana   dob=02/07/1996
    ${header}=    create dictionary    Content-Type=application/json
    ${start_time}=  Get Current Date
    Log To Console    ${start_time}
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_basic   json=${body}    headers=${header}
    ${end_time}=    Get Current Date
    Log To Console    ${end_time}
    ${time_in_seconds}=     Subtract Date From Date   ${end_time}    ${start_time}
    ${time_in_milliseconds}=    Evaluate    ${time_in_seconds}*1000
    Log To Console    ${time_in_milliseconds}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    #Validation
    Should Be True    ${time_in_milliseconds}<5000  Response come within 5 minutes

Testcase 4:
    Log To Console    Verify the success response is coming within 5 minutes
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKP@8785Q    client_ref_num=FAILURE   name=abi nanthana   dob=02/07/1996
    ${header}=    create dictionary    Content-Type=application/json
    ${start_time}=  Get Current Date
    Log To Console    ${start_time}
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_basic   json=${body}    headers=${header}
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

#####-------------SECURITY--------------------#####
Testcase5:
    Log To Console     To verify by giving request by Changing the type of reqeust. POST to GET
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=Post_to_Get   name=abi nanthana   dob=02/07/1996
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Get Request     mysession     /validation/kyc/v2/pan_basic   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
     #Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    #Should Be Equal As Strings  ${response.json()['client_ref_num']}    test
     Should Be Equal As Strings    ${response.json()['message']}    API Running Successfully

#Testcase 6:
#    Log To Console     To verify  by giving request by Changing the base url
#    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
#    create session    mysession    https://svcstage1.digitap.work    auth=${auth}    verify=true
#
#    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=EndPoint_url_change   name=abi nanthana   dob=02/07/1996
#    ${header}=    create dictionary    Content-Type=application/json
#    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_basic   json=${body}    headers=${header}
#    Log To Console    ${body}
#    Log To Console    ${response.status_code}
#    Log To Console    ${response.content}


Test case 7:
    Log To Console     To verify by giving request by changing the Endpoint url
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=EndPoint_url_change   name=abi nanthana   dob=02/07/1996
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_basic1   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    Should Contain   ${response.text}    Apache APISIX Dashboard

