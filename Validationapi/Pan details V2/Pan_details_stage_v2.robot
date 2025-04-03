*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DatabaseLibrary
Library    JSONLibrary
Library    urllib3
Library    random

Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Disconnect From Database


*** Variables ***
${DBName}   validation
${DBUser}   qa.chandraprakash.d
${DBPass}   KrG3yfPY
${DBHost}   dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
${base_url_http}=    http://svcstage.digitap.work
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan details V2\\PanDetails_V2_Data.csv
${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan details V2\\pan_details_data_V2.json

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}   name=${columns[3]}   name_match_method=${columns[4]}
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
Send Post Request And Validate V2
    [Arguments]    ${auth}    ${body}    ${expected_schema_file}    ${case_key}
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession    /validation/kyc/v2/pan_details    json=${body}    headers=${header}
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
Test Case 1
    Log To Console    Verify by entering valid Individual pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case1


Test_case2
    Log To Console    Firm/Limited Liability Partnership pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case2


Test_case3
    Log To Console    Hindu Undivided Family (HUF) pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case3

Test_case4
    Log To Console    Verify by entering Association of Persons (AOP) pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case4

Test_case5
    Log To Console    Verify by entering Body of Individuals (BOI) pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case5

Test_case6
    Log To Console    Verify by entering Government Agency pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case6

Test_case7
    Log To Console    Verify by entering Artificial Juridical Person pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case7

Test_case8
    Log To Console    Verify by entering Local Authority pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case8

Test_case9
    Log To Console    Verify by entering Trust pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case9

Test_case10
    Log To Console    Verify by entering Company pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case10

Test_case11
    Log To Console    Verify by entering in-valid pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case11

Test_case12
    Log To Console    Verify by entering pan number as numeric char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case12

Test_case13
    Log To Console    Verify by entering pan number as alpha char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case13
Test_case14
    Log To Console    Verify by entering pan number as special char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case14

Test_case15
    Log To Console    Verify by entering pan number as mixed of alpha numeric special char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case15

Test_case16
    Log To Console    Verify by entering pan number less than 10 char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case16

Test_case17
    Log To Console    Verify by entering pan number more than 10 char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case17

Test_case18
    log to console  Verify by leaving pan number empty
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case18

Test_case19
    log to console  Verify by leaving pan number empty space
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case19

Test_case20
    log to console  Verify by valid client ref number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case20

Test_case21
    log to console  Verify by in-valid client ref number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case21

Test_case22
    log to console  Verify by leaving client ref number empty
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case22

Test_case23
    log to console  Verify by leaving client ref number empty space
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case23

Test_case24
    log to console  Verify by entering client ref number as 45 char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case24

Test_case25
    log to console  Verify by entering client ref number more than 45 char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case25

Test_case26
    log to console  Verify by changing the 5th char of the pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case26

Test_case27
    log to console  Verify by entering pan number in lower case char
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case27

Test_case28
    log to console  Verify by entering e pan number
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case28

Test_case29
    log to console  Verify by entering Deleted pan number
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case29

Test_case30
    log to console  Verify by entering Deactivated pan number
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case30

Test_case31
    log to console  Verify by entering Fake pan number
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case31

Test_case32
    log to console  Verify by entering No record found pan number
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case32

Test_case33
    log to console  Verify by entering Invalid (Regex) pan number
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case33

Test_case35
    log to console  Entering IT registered transgender pan number
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case34


Test_case36
    log to console  Entering Non IT registered transgender pan number
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    cas35

Test_case37
    log to console  Verify by entering Valid authentication
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case1

Test_case38
    log to console  Verify by entering in-Valid authentication
    ${auth}=    create list    7405136256250$%    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case36

Test_case39
    log to console  Verify by Leaving client user name as empty
    ${auth}=    create list    ${EMPTY}    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case36


Test_case40
    log to console  Verify by leaving client password as empty
    ${auth}=    create list    740513625625009    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case36

Test_case41
    log to console  Verify by leaving client username and password as empty
    ${auth}=    create list    ${EMPTY}    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case36

Test_case42
    log to console  Verify by entering authentication which don't having pan details service
    ${auth}=    create list    21717999    XiNLt8vtsRXoKWkcelzHIAsBfZx7O9XBY
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case36

Test_case43
    log to console  Disabling the IT user profile
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '8');
    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="8";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    log to console  Verify by disabling the IT user profile and hitting the request
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BRZPP3047H
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  SIDDHARTHA PRAMANIK
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  SIDDHARTHA
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  PRAMANIK
    Should Be Equal As Strings  ${response.json()['result']['dob']}  15/09/1988

    log to console  Enabling the IT user profile after the 48th test case execution
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '8');
    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="8";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, befisc_fname_api_response, validate_pan_response, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    befisc_fname_api_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    father_name_status = ${row[7]}
        Log To Console    pan_status = ${row[8]}
        Log To Console    Source = ${row[9]}
    END


Test_case44

    log to console  Disabling the validate pan endpoint
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '6');
    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="6";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    log to console  Verify by disabling the validate pan endpoint and hitting the request
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BRZPP3047H
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  SIDDHARTHA PRAMANIK
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  SIDDHARTHA
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  PRAMANIK
    Should Be Equal As Strings  ${response.json()['result']['dob']}  15/09/1988


    log to console  Enabling the validate pan endpoint after the 48th test case execution
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '6');
    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="6";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, befisc_fname_api_response, validate_pan_response, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    befisc_fname_api_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    father_name_status = ${row[7]}
        Log To Console    pan_status = ${row[8]}
        Log To Console    Source = ${row[9]}
    END

Test_case45

    log to console  Disabling both the validate pan endpoint and It user profile
    ${update_output1}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '8');
    Log To Console    ${update_output1}
    Should Be Equal As Strings    ${update_output1}    None

    ${update_output2}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '6');
    Log To Console    ${update_output2}
    Should Be Equal As Strings    ${update_output2}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="8";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END
    ${query_result2}=    Query    SELECT value FROM validation.validation_service_config where id="6";
    FOR    ${row}    IN    @{query_result2}
        Log To Console    vendor_list = ${row[0]}
    END


    log to console  Verify by disabling the validate pan endpoint and It user profile and hitting the request
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BRZPP3047H
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  SIDDHARTHA PRAMANIK
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  SIDDHARTHA
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  PRAMANIK
    Should Be Equal As Strings  ${response.json()['result']['dob']}  15/09/1988

    log to console  Enabling the validate pan and IT endpoint after the 54th test case execution
    ${update_output1}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '8');
    Log To Console    ${update_output1}
    Should Be Equal As Strings    ${update_output1}    None

    ${update_output2}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625009]' WHERE (`id` = '6');
    Log To Console    ${update_output2}
    Should Be Equal As Strings    ${update_output2}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="8";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${query_result2}=    Query    SELECT value FROM validation.validation_service_config where id="6";
    FOR    ${row}    IN    @{query_result2}
        Log To Console    vendor_list = ${row[0]}
    END


    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, befisc_fname_api_response, validate_pan_response, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    befisc_fname_api_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    father_name_status = ${row[7]}
        Log To Console    pan_status = ${row[8]}
        Log To Console    Source = ${row[9]}
    END

Test_case46
    log to console  Verify by entering father name input
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}", "father_name": "true" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case47
    log to console  Verify by entering skip validate pan input
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}", "skip_validate_pan": "true" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case48
    log to console  Verify by entering pan display name input
    ${auth}=    create list    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}", "pan_display_name": True }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test Case 49
    Log To Console    Verify by entering Individual pan number with name match as fuzzy
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   35
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case37

Test Case 50
    Log To Console    Verify by entering Individual pan number with name match as exact
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   36
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case38

Test Case 51
    Log To Console    Verify by entering Individual pan number with name match as dg_name_match
    ${auth}=    Create List    740513625625009    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   37
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V2    ${auth}    ${body}    ${json_schema_file}    case39

Test_case52
    log to console  Verify by hitting the reqeust with get method

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Get Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['error']}   API running successfully!

Test_case53
    log to console  Verify by hitting the request with OPTIONS method

    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Options Request    mysession    /validation/kyc/v2/pan_details    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    Convert To String    ${response.content}
    Should Be Equal As Strings  ${response.json()['message']}    API running successfully!

Test_case54
    log to console  Verify by hitting the request with http method

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url_http}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"255305008943", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

Test_case55
    log to console  Verify by hitting the request with POST method and checking the requests and response headers
    # Create session
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    # Generate a random client reference number
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=    Evaluate    { "pan_details":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    # Define request headers
    ${header}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept-Encoding=gzip, deflate, br
    ...    Connection=keep-alive

    # Log Request Headers
    Log To Console    Request Headers: ${header}

    # Validate Request Headers
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Content-Type    application/json
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Accept-Encoding    gzip, deflate, br
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Connection    keep-alive

    # Send POST request
    ${response}=    Post Request    mysession     /validation/kyc/v2/pan_details
    ...    json=${body}
    ...    headers=${header}

    # Log Response Details
    Log To Console    Request Body: ${body}
    Log To Console    Response Status Code: ${response.status_code}
    Log To Console    Response Content: ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

    # Capture Response Headers
    ${response_headers}=    Set Variable    ${response.headers}
    Log To Console    Response Headers: ${response_headers}

    # Validate Response Headers
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Server']}    	awselb/2.0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Content-Type']}    application/json
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Connection']}    keep-alive
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Content-Length']}    185


Test_case56
    log to console  Verify by hitting the request with OPTIONS method and checking the requests and response headers

    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    # Define request headers
    ${header}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept-Encoding=gzip, deflate, br
    ...    Connection=keep-alive

    # Log Request Headers
    Log To Console    Request Headers: ${header}

    # Validate Request Headers
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Content-Type    application/json
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Accept-Encoding    gzip, deflate, br
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Connection    keep-alive

    ${response}=    Options Request    mysession    /validation/kyc/v2/pan_details    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    Convert To String    ${response.content}
    Should Be Equal As Strings  ${response.json()['message']}    API running successfully!


     # Capture Response Headers
    ${response_headers}=    Set Variable    ${response.headers}
    Log To Console    Response Headers: ${response_headers}

    # Validate Response Headers
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Server']}    	awselb/2.0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Content-Type']}    application/json
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Connection']}    keep-alive
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Cache-Control']}    must-revalidate
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Referrer-Policy']}    	strict-origin-when-cross-origin
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-Content-Type-Options']}    	nosniff
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-Frame-Options']}    DENY
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-XSS-Protection']}    0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Credentials']}    true
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Headers']}    Origin, Content-Type, X-Auth-Token, Authorization
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Methods']}    	GET, POST, OPTIONS
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Origin']}    *

Test_case57
    log to console  Verify by hitting reqeust with additional data in the endpoint

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_detailss   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

Test_case58
    log to console  Verify by hitting the reqeust without authentication

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}     verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v2/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Not Be Empty    ${response.json()['client_ref_num']}


Test_case59
    log to console  Verify by hitting the reqeust with get method

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Get Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['error']}   API running successfully!

Test_case125
    log to console  Verify by hitting the request with OPTIONS method

    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Options Request    mysession    /validation/kyc/v1/pan_details    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    Convert To String    ${response.content}
    Should Be Equal As Strings  ${response.json()['message']}    API running successfully!

Test_case126
    log to console  Verify by hitting the request with http method

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url_http}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"255305008943", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

Test Case 127
    log to console  Verify by hitting the request with POST method and checking the requests and response headers
    # Create session
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    # Generate a random client reference number
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=    Evaluate    { "pan_details":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    # Define request headers
    ${header}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept-Encoding=gzip, deflate, br
    ...    Connection=keep-alive

    # Log Request Headers
    Log To Console    Request Headers: ${header}

    # Validate Request Headers
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Content-Type    application/json
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Accept-Encoding    gzip, deflate, br
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Connection    keep-alive

    # Send POST request
    ${response}=    Post Request    mysession     /validation/kyc/v1/pan_details
    ...    json=${body}
    ...    headers=${header}

    # Log Response Details
    Log To Console    Request Body: ${body}
    Log To Console    Response Status Code: ${response.status_code}
    Log To Console    Response Content: ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

    # Capture Response Headers
    ${response_headers}=    Set Variable    ${response.headers}
    Log To Console    Response Headers: ${response_headers}

    # Validate Response Headers
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Server']}    	awselb/2.0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Content-Type']}    application/json
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Connection']}    keep-alive
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Content-Length']}    185


Test_case128
    log to console  Verify by hitting the request with OPTIONS method and checking the requests and response headers

    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    # Define request headers
    ${header}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept-Encoding=gzip, deflate, br
    ...    Connection=keep-alive

    # Log Request Headers
    Log To Console    Request Headers: ${header}

    # Validate Request Headers
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Content-Type    application/json
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Accept-Encoding    gzip, deflate, br
    Run Keyword And Continue On Failure    Dictionary Should Contain Item    ${header}    Connection    keep-alive

    ${response}=    Options Request    mysession    /validation/kyc/v1/pan_details    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    Convert To String    ${response.content}
    Should Be Equal As Strings  ${response.json()['message']}    API running successfully!


     # Capture Response Headers
    ${response_headers}=    Set Variable    ${response.headers}
    Log To Console    Response Headers: ${response_headers}

    # Validate Response Headers
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Server']}    	awselb/2.0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Content-Type']}    application/json
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Connection']}    keep-alive
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Cache-Control']}    must-revalidate
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Referrer-Policy']}    	strict-origin-when-cross-origin
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-Content-Type-Options']}    	nosniff
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-Frame-Options']}    DENY
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-XSS-Protection']}    0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Credentials']}    true
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Headers']}    Origin, Content-Type, X-Auth-Token, Authorization
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Methods']}    	GET, POST, OPTIONS
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Origin']}    *

Test_case129
    log to console  Verify by hitting reqeust with additional data in the endpoint

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_detailss   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

Test_case130
    log to console  Verify by hitting the reqeust without authentication

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}     verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Not Be Empty    ${response.json()['client_ref_num']}

Test_case131
    log to console  Check if null byte the API is vulnerable to null byte injection

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    ${pan_with_null}=    Set Variable    EBQPP7566F\u0000

    ${body}=    Create Dictionary    pan=${pan_with_null}    client_ref_num=${random_client_ref_num}

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validate if the response indicates an issue
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['error']}     Invalid ID number or combination of inputs

Test_case132
    log to console  Verify SQL Injection vulnerability

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Define SQL Injection Payloads in a List
    @{sql_payloads}=    Create List
    ...    ' OR '1'='1  --
    ...    '; DROP TABLE users; --
    ...    ' UNION SELECT null,version(); --
    ...    ' AND 1=1 --
    ...    ' OR 'a'='a' --

    ${header}=    Create Dictionary    Content-Type=application/json

    # Loop through each SQL payload
    FOR    ${payload}    IN    @{sql_payloads}
        log to console  Testing Payload: ${payload}

        ${body}=    Create Dictionary    pan=${payload}    client_ref_num=${random_client_ref_num}
        ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}

        # Log response
        Log To Console    Response Code: ${response.status_code}
        Log To Console    Response Body: ${response.content}

        # Validate Expected Response
        Should Be Equal As Strings  ${response.json()['http_response_code']}    400
        Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    END