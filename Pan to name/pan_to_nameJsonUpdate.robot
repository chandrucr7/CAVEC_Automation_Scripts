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
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to name\\pan_to_nameData.csv
${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to name\\pan_to_name_softi_schema.json

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}
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
    ${response}=    Post Request    mysession    /validation/kyc/v1/pan_to_name    json=${body}    headers=${header}
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
CAVEC-T4261:
    Log To Console    To verify by entering valid Pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case0

CAVEC-T4262:
    Log To Console    To verify by changing the 5th char of pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

CAVEC-T4263:
    Log To Console    To verify by leaving the pan as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

CAVEC-T4264:
    Log To Console    To verify by entering empty space in the pan number field
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

CAVEC-T4265:
    Log To Console    To verify by entering the pan in lower case alphabets
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

CAVEC-T4266:
    Log To Console    To verify by entering the pan more than 10 digit
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

CAVEC-T4267:
    Log To Console    To verify by entering the pan less than 10 digit
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

CAVEC-T4268:
    Log To Console    To verify by entering the pan number as alphabets
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7

CAVEC-T4269:
    Log To Console    To verify by entering the pan number as special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8\

CAVEC-T4270:
    Log To Console    To verify by entering the pan number as numeric char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

CAVEC-T4271:
    Log To Console    To verify by entering the pan number mixed with alpha,numeric and special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

CAVEC-T4273:
    Log To Console    To verify by entering empty space at the front of the pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

CAVEC-T4274:
    Log To Console    To verify by entering empty space at the end of the pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

CAVEC-T4275:
    Log To Console    To verify by entering registered individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

CAVEC-T4276:
    Log To Console    To verify by entering non-registered individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

CAVEC-T4277:
    Log To Console    To verify by entering registered non-individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

CAVEC-T4278:
    Log To Console    To verify by entering non-registered non-individual pan
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

CAVEC-T4279:
    Log To Console    To verify by entering Firm/Limited liability Partnership pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

CAVEC-T4280:
    Log To Console    To verify by entering Hindu undivided family pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

CAVEC-T4281:
    Log To Console    To verify by entering Association of persons(AOP) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

CAVEC-T4282:
    Log To Console    To verify by entering Body Of Individuals pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

CAVEC-T4283:
    Log To Console    To verify by entering Government Agency pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

CAVEC-T4284:
    Log To Console    To verify by entering Artificial Judicial Person pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

CAVEC-T4285:
    Log To Console    To verify by entering Local Authority pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

CAVEC-T4286:
    Log To Console    To verify by entering Trust pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

CAVEC-T4287:
    Log To Console    To verify by entering company pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case25

CAVEC-T4288:
    Log To Console    To verify by entering Death pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

CAVEC-T4289:
    Log To Console    To verify by entering invalid(Deactivated) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case27

CAVEC-T4290:
    Log To Console    To verify by entering invalid(Deleted) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case28

CAVEC-T4291:
    Log To Console    To verify by entering Fake pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case29

CAVEC-T4292:
    Log To Console    To verify by entering valid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case30

CAVEC-T4293:
    Log To Console    To verify by entering in-valid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case31

CAVEC-T4294:
    Log To Console    To verify by entering client ref number more than 45 characters
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case32

CAVEC-T4295:
    Log To Console    To verify by entering client ref number as 45 characters
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case33

CAVEC-T4296:
    Log To Console    To verify by leaving the client ref number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case34

CAVEC-T4297:
    Log To Console    To verify by leaving the client ref number as empty space
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    35

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

CAVEC-T4302:
    Log To Console    To verify by entering valid authentication
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    36

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case36

CAVEC-T4303:
    Log To Console    To verify by entering in-valid authentication
    ${auth}=    Create List    526526315047#    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case37

CAVEC-T4304:

CAVEC-T4305:
    Log To Console    To verify by entering one client username and another client password
    ${auth}=    Create List    526526315047    BI9WnuOcxLBKKgPEB4qtLdADGc9PH0d5

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    39

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case39

CAVEC-T4306:
    Log To Console    To verify by entering client id which are not having pan to name service
    ${auth}=    Create List    21717999    XiNLt8vtsRXoKWkcelzHIAsBfZx7O9XB

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    40

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case40

CAVEC-T4307:
    Log To Console    To verify by entering empty in the username
    ${auth}=    Create List    ${EMPTY}    EA6F34B4B3B618A10CF5C22232290778

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    41

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case41

CAVEC-T4308:
    Log To Console    To verify by entering empty in the password
    ${auth}=    Create List    526526315047    ${EMPTY}

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    42

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case42

CAVEC-T4309:
    Log To Console    To verify by entering empty in the username and password
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}

    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    43

    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case43

#CAVEC-T4332:
#    Log To Console    To verify by entering mock scenario 408 for the befisc
#    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
#
#    ${test_data}=    Read Test Data From CSV    ${file_path}
#    ${row}=    Get From List    ${test_data}    44
#
#    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
#    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case44
#
#CAVEC-T4333:
#    Log To Console    To verify by entering mock scenario 403 for the befisc
#    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
#
#    ${test_data}=    Read Test Data From CSV    ${file_path}
#    ${row}=    Get From List    ${test_data}    45
#
#    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
#    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case45
#
#CAVEC-T4334:
#    Log To Console    To verify by entering mock scenario 400 for the soft-i
#    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
#
#    ${test_data}=    Read Test Data From CSV    ${file_path}
#    ${row}=    Get From List    ${test_data}    46
#
#    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
#    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case46

#####-------------SECURITY--------------------#####
CAVEC-T4310:
    Log To Console     To verify by giving request by Changing the type of reqeust. POST to GET
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=Post_to_Get
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Get Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
     #Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    #Should Be Equal As Strings  ${response.json()['client_ref_num']}    test
     Should Be Equal As Strings    ${response.json()['message']}    API Running Successfully

#CAVEC-T4311:
#    Log To Console     To verify  by giving request by Changing the base url
#    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
#    create session    mysession    https://svcstage1.digitap.work    auth=${auth}    verify=true
#
#    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=EndPoint_url_change
#    ${header}=    create dictionary    Content-Type=application/json
#    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
#    Log To Console    ${body}
#    Log To Console    ${response.status_code}
#    Log To Console    ${response.content}
#
#    #Validations
#    Should Contain    ${response.text}    Could not send request


CAVEC-T4312:
    Log To Console     To verify  by giving request by changing the Endpoint url
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=EndPoint_url_change
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name1   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    Should Contain   ${response.text}    Apache APISIX Dashboard

#####------------------------PERFORMANCE ---------------------------#####
CAVEC-T4356:
    Log To Console    Verify the success response is coming within 5 minutes
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKPA8785Q    client_ref_num=SUCCESS
    ${header}=    create dictionary    Content-Type=application/json
    ${start_time}=  Get Current Date
    Log To Console    ${start_time}
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
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

CAVEC-T4357:
    Log To Console    Verify the failure response is coming within 3 minutes
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BTKP@8785Q    client_ref_num=FAILURE
    ${header}=    create dictionary    Content-Type=application/json
    ${start_time}=  Get Current Date
    Log To Console    ${start_time}
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
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
    
####-----------Database ------------#####
Testcase1 :
    Log To Console    To verify that id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on is storing in database or not(CASE101)

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BJPPC6837G    client_ref_num=DB101
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
    #${resultcode}=  Set Variable    ${response.json()['result_code']}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}     DB101
    Should Be Equal As Strings    ${response.json()['result_code']}    101



    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on FROM validation.kyc_pan_to_name_api where client_ref_num='DB101' and result_code='101'order by id desc limit 1;
    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    id=${row[0]}
        Log To Console    ent_id=${row[1]}
        Log To Console    pan=${row[2]}
        Log To Console    client_ref_num=${row[3]}
        Log To Console    request_payload=${row[4]}
        Log To Console    response_payload=${row[5]}
        Log To Console    request_uuid=${row[6]}
        Log To Console    http_status_code=${row[7]}
        Log To Console    result_code=${row[8]}
        Log To Console    source=${row[9]}
        Log To Console    provider_log_id=${row[10]}
        Log To Console    name_source=${row[11]}
        Log To Console    tat=${row[12]}
        Log To Console    created_on=${row[13]}
        Log To Console    updated_on=${row[14]}
    END

    #Provider table -
    ${provider_log_api_id_table}=   Set Variable    ${row[10]}

    ${sql_query1}=   Set Variable   SELECT id,request_payload,response_payload,http_status_code,source,tat,created_on FROM validation.kyc_pan_basic_provider_api_logs where id=${provider_log_api_id_table} order by id desc;
    ${query_results_provider}=   Query    ${sql_query1}

    FOR    ${row_provider}    IN    @{query_results_provider}
        Log To Console    id=${row_provider[0]}
        Log To Console    request_payload=${row_provider[1]}
        Log To Console    response_payload=${row_provider[2]}
        Log To Console    http_status_code=${row_provider[3]}
        Log To Console    source=${row_provider[4]}
        Log To Console    tat=${row_provider[5]}
        Log To Console    created_on=${row_provider[6]}

    END

Testcase2 :
    Log To Console    To verify that id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on is storing in database or not(CASE102)

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=LJKPK2266E    client_ref_num=DB102
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
    #${resultcode}=  Set Variable    ${response.json()['result_code']}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}     DB102
    Should Be Equal As Strings    ${response.json()['result_code']}    102



    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on FROM validation.kyc_pan_to_name_api where client_ref_num='DB102' and result_code='102'order by id desc limit 1;
    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    id=${row[0]}
        Log To Console    ent_id=${row[1]}
        Log To Console    pan=${row[2]}
        Log To Console    client_ref_num=${row[3]}
        Log To Console    request_payload=${row[4]}
        Log To Console    response_payload=${row[5]}
        Log To Console    request_uuid=${row[6]}
        Log To Console    http_status_code=${row[7]}
        Log To Console    result_code=${row[8]}
        Log To Console    source=${row[9]}
        Log To Console    provider_log_id=${row[10]}
        Log To Console    name_source=${row[11]}
        Log To Console    tat=${row[12]}
        Log To Console    created_on=${row[13]}
        Log To Console    updated_on=${row[14]}
    END

    #Provider table -
    ${provider_log_api_id_table}=   Set Variable    ${row[10]}

    ${sql_query1}=   Set Variable   SELECT id,request_payload,response_payload,http_status_code,source,tat,created_on FROM validation.kyc_pan_basic_provider_api_logs where id=${provider_log_api_id_table} order by id desc;
    ${query_results_provider}=   Query    ${sql_query1}

    FOR    ${row_provider}    IN    @{query_results_provider}
        Log To Console    id=${row_provider[0]}
        Log To Console    request_payload=${row_provider[1]}
        Log To Console    response_payload=${row_provider[2]}
        Log To Console    http_status_code=${row_provider[3]}
        Log To Console    source=${row_provider[4]}
        Log To Console    tat=${row_provider[5]}
        Log To Console    created_on=${row_provider[6]}

    END

Testcase3 :
    Log To Console    To verify that id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on is storing in database or not(CASE103)

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true

    ${body}=    create dictionary    pan=BJPPX6837G    client_ref_num=DB103
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
    #${resultcode}=  Set Variable    ${response.json()['result_code']}

    #Validations
    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
    Should Be Equal As Strings    ${response.json()['client_ref_num']}     DB103
    Should Be Equal As Strings    ${response.json()['result_code']}    103



    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on FROM validation.kyc_pan_to_name_api where client_ref_num='DB103' and result_code='103'order by id desc limit 1;
    ${query_results}=   Query    ${sql_query}

    FOR    ${row}    IN    @{query_results}
        Log To Console    id=${row[0]}
        Log To Console    ent_id=${row[1]}
        Log To Console    pan=${row[2]}
        Log To Console    client_ref_num=${row[3]}
        Log To Console    request_payload=${row[4]}
        Log To Console    response_payload=${row[5]}
        Log To Console    request_uuid=${row[6]}
        Log To Console    http_status_code=${row[7]}
        Log To Console    result_code=${row[8]}
        Log To Console    source=${row[9]}
        Log To Console    provider_log_id=${row[10]}
        Log To Console    name_source=${row[11]}
        Log To Console    tat=${row[12]}
        Log To Console    created_on=${row[13]}
        Log To Console    updated_on=${row[14]}
    END

    #Provider table -
    ${provider_log_api_id_table}=   Set Variable    ${row[10]}

    ${sql_query1}=   Set Variable   SELECT id,request_payload,response_payload,http_status_code,source,tat,created_on FROM validation.kyc_pan_basic_provider_api_logs where id=${provider_log_api_id_table} order by id desc;
    ${query_results_provider}=   Query    ${sql_query1}

    FOR    ${row_provider}    IN    @{query_results_provider}
        Log To Console    id=${row_provider[0]}
        Log To Console    request_payload=${row_provider[1]}
        Log To Console    response_payload=${row_provider[2]}
        Log To Console    http_status_code=${row_provider[3]}
        Log To Console    source=${row_provider[4]}
        Log To Console    tat=${row_provider[5]}
        Log To Console    created_on=${row_provider[6]}

    END



#Testcase4:
#    Log To Console  Verify fallback is happening or not for 101 case
#
#    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
#    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true
#
#    ${body}=    create dictionary    pan=BJPPC6837G    client_ref_num=FALLBACK101
#    ${header}=    create dictionary    Content-Type=application/json
#    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
#    Log To Console    ${body}
#    Log To Console    ${response.status_code}
#    Log To Console    ${response.content}
#   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
#    #${resultcode}=  Set Variable    ${response.json()['result_code']}
#
#    #Validations
#    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings    ${response.json()['client_ref_num']}     FALLBACK101
#    Should Be Equal As Strings    ${response.json()['result_code']}    101
#
#
#
#    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on FROM validation.kyc_pan_to_name_api where client_ref_num='FALLBACK101' and result_code='101'order by id desc limit 1;
#    ${query_results}=   Query    ${sql_query}
#
#    FOR    ${row}    IN    @{query_results}
#
#        Log To Console    id=${row[0]}
#        Log To Console    ent_id=${row[1]}
#        Log To Console    pan=${row[2]}
#        Log To Console    client_ref_num=${row[3]}
#        Log To Console    request_payload=${row[4]}
#        Log To Console    response_payload=${row[5]}
#        Log To Console    request_uuid=${row[6]}
#        Log To Console    http_status_code=${row[7]}
#        Log To Console    result_code=${row[8]}
#        Log To Console    source=${row[9]}
#        Log To Console    provider_log_id=${row[10]}
#        Log To Console    name_source=${row[11]}
#        Log To Console    tat=${row[12]}
#        Log To Console    created_on=${row[13]}
#        Log To Console    updated_on=${row[14]}
#    END
#
#    ${provider_id}=     Set Variable    ${row[10]}
#
#    ${sql_query1}=   Set Variable   select count(id),id,request_payload,response_payload,http_status_code,source,tat,created_on FROM validation.kyc_pan_basic_provider_api_logs where id=${provider_id} and http_status_code='200' order by id desc;
#    ${query_results1}=   Query    ${sql_query1}
#
#    FOR    ${row_provider}    IN    @{query_results1}
#        Log To Console    count=${row_provider[0]}
#        Log To Console    id=${row_provider[1]}
#        Log To Console    request_payload=${row_provider[2]}
#        Log To Console    response_payload=${row_provider[3]}
#        Log To Console    http_status_code=${row_provider[4]}
#        Log To Console    source=${row_provider[5]}
#        Log To Console    tat=${row_provider[6]}
#        Log To Console    created_on=${row_provider[7]}
#    END
#
#
#    ${count_row_provider}=  Set Variable    ${row_provider[0]}
#    Log To Console    ${count_row_provider}
#    ${http_status_code_provider}=   Set Variable    ${row_provider[4]}
#    Log To Console    ${http_status_code_provider}
#
#    IF    (${count_row_provider} == 1 and ${http_status_code_provider} == 200)
#        Log To Console  Fallback not happened for 101 case
#    ELSE
#        Log To Console  Fallback happened for 101 case
#    END
#
#Testcase5:
#    Log To Console  Verify fallback is happening or not for 102 case
#
#    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
#    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true
#
#    ${body}=    create dictionary    pan=LJKPK2266E    client_ref_num=FALLBACK102
#    ${header}=    create dictionary    Content-Type=application/json
#    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
#    Log To Console    ${body}
#    Log To Console    ${response.status_code}
#    Log To Console    ${response.content}
#   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
#    #${resultcode}=  Set Variable    ${response.json()['result_code']}
#
#    #Validations
#    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings    ${response.json()['client_ref_num']}     FALLBACK102
#    Should Be Equal As Strings    ${response.json()['result_code']}    102
#
#
#
#    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on FROM validation.kyc_pan_to_name_api where client_ref_num='FALLBACK102' and result_code='102' order by id desc limit 1;
#    ${query_results}=   Query    ${sql_query}
#
#    FOR    ${row}    IN    @{query_results}
#
#        Log To Console    id=${row[0]}
#        Log To Console    ent_id=${row[1]}
#        Log To Console    pan=${row[2]}
#        Log To Console    client_ref_num=${row[3]}
#        Log To Console    request_payload=${row[4]}
#        Log To Console    response_payload=${row[5]}
#        Log To Console    request_uuid=${row[6]}
#        Log To Console    http_status_code=${row[7]}
#        Log To Console    result_code=${row[8]}
#        Log To Console    source=${row[9]}
#        Log To Console    provider_log_id=${row[10]}
#        Log To Console    name_source=${row[11]}
#        Log To Console    tat=${row[12]}
#        Log To Console    created_on=${row[13]}
#        Log To Console    updated_on=${row[14]}
#    END
#
#    ${provider_id}=     Set Variable    ${row[10]}
#
#    ${sql_query1}=   Set Variable   select count(id),id,request_payload,response_payload,http_status_code,source,tat,created_on FROM validation.kyc_pan_basic_provider_api_logs where id=${provider_id} and http_status_code='200' order by id desc;
#    ${query_results1}=   Query    ${sql_query1}
#
#    FOR    ${row_provider}    IN    @{query_results1}
#        Log To Console    count=${row_provider[0]}
#        Log To Console    id=${row_provider[1]}
#        Log To Console    request_payload=${row_provider[2]}
#        Log To Console    response_payload=${row_provider[3]}
#        Log To Console    http_status_code=${row_provider[4]}
#        Log To Console    source=${row_provider[5]}
#        Log To Console    tat=${row_provider[6]}
#        Log To Console    created_on=${row_provider[7]}
#    END
#
#
#    ${count_row_provider}=  Set Variable    ${row_provider[0]}
#    Log To Console    ${count_row_provider}
#    ${http_status_code_provider}=   Set Variable    ${row_provider[4]}
#    Log To Console    ${http_status_code_provider}
#
#    IF    (${count_row_provider} == 1 and ${http_status_code_provider} == 200)
#        Log To Console  Fallback not happened for 102 case
#    ELSE
#        Log To Console  Fallback happened for 102 case
#    END
#
#Testcase6:
#    Log To Console  Verify fallback is happening or not for 103 case
#
#    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
#    create session    mysession    https://svcstage.digitap.work    auth=${auth}    verify=true
#
#    ${body}=    create dictionary    pan=BJPPX6837G    client_ref_num=FALLBACK103
#    ${header}=    create dictionary    Content-Type=application/json
#    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_name   json=${body}    headers=${header}
#    Log To Console    ${body}
#    Log To Console    ${response.status_code}
#    Log To Console    ${response.content}
#   # ${clientrefnum}=    Set Variable    ${response.json['client_ref_num']}
#    #${resultcode}=  Set Variable    ${response.json()['result_code']}
#
#    #Validations
#    Should Be Equal As Strings    ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings    ${response.json()['client_ref_num']}     FALLBACK103
#    Should Be Equal As Strings    ${response.json()['result_code']}    103
#
#
#
#    ${sql_query}=   Set Variable   SELECT id,ent_id,pan,client_ref_num,request_payload,response_payload,request_uuid,http_status_code,result_code,source,provider_log_id,name_source,tat,created_on,updated_on FROM validation.kyc_pan_to_name_api where client_ref_num='FALLBACK103' and result_code='103' order by id desc limit 1;
#    ${query_results}=   Query    ${sql_query}
#
#    FOR    ${row}    IN    @{query_results}
#
#        Log To Console    id=${row[0]}
#        Log To Console    ent_id=${row[1]}
#        Log To Console    pan=${row[2]}
#        Log To Console    client_ref_num=${row[3]}
#        Log To Console    request_payload=${row[4]}
#        Log To Console    response_payload=${row[5]}
#        Log To Console    request_uuid=${row[6]}
#        Log To Console    http_status_code=${row[7]}
#        Log To Console    result_code=${row[8]}
#        Log To Console    source=${row[9]}
#        Log To Console    provider_log_id=${row[10]}
#        Log To Console    name_source=${row[11]}
#        Log To Console    tat=${row[12]}
#        Log To Console    created_on=${row[13]}
#        Log To Console    updated_on=${row[14]}
#    END
#
#    ${provider_id}=     Set Variable    ${row[10]}
#
#    ${sql_query1}=   Set Variable   select count(id),id,request_payload,response_payload,http_status_code,source,tat,created_on FROM validation.kyc_pan_basic_provider_api_logs where id=${provider_id} and http_status_code='200' order by id desc;
#    ${query_results1}=   Query    ${sql_query1}
#
#    FOR    ${row_provider}    IN    @{query_results1}
#        Log To Console    count=${row_provider[0]}
#        Log To Console    id=${row_provider[1]}
#        Log To Console    request_payload=${row_provider[2]}
#        Log To Console    response_payload=${row_provider[3]}
#        Log To Console    http_status_code=${row_provider[4]}
#        Log To Console    source=${row_provider[5]}
#        Log To Console    tat=${row_provider[6]}
#        Log To Console    created_on=${row_provider[7]}
#    END
#
#
#    ${count_row_provider}=  Set Variable    ${row_provider[0]}
#    Log To Console    ${count_row_provider}
#    ${http_status_code_provider}=   Set Variable    ${row_provider[4]}
#    Log To Console    ${http_status_code_provider}
#
#    IF    (${count_row_provider} == 1 and ${http_status_code_provider} == 200)
#        Log To Console  Fallback not happened for 103 case
#    ELSE
#        Log To Console  Fallback happened for 103 case
#    END
#

