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
${DBHost}   dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
${base_url_http}=    http://svcstage.digitap.work
${file_path}=  C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Compliance check api\\PanComplianceData.csv
${json_schema_file}=  C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Compliance check api\\Form_206AB_Schema.json

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}   client_ref_num=${columns[2]}
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
    ${response}=    Post Request    mysession    /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
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
    Log To Console    IT registered Individual pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

Test Case 2
    Log To Console    Non IT registered Individual pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

Test Case 3
    Log To Console    Verify by entering Firm/Limited Liability Partnership pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

Test Case 4
    Log To Console    Verify by entering Hindu Undivided Family (HUF) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

Test Case 5
    Log To Console    Verify by entering Association of Persons (AOP) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

Test Case 6
    Log To Console    Verify by entering Body of Individuals (BOI) pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case6

Test Case 7
    Log To Console    Verify by entering Government Agency pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case7

Test Case 8
    Log To Console    Verify by entering Artificial Juridical Person pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case8

Test Case 9
    Log To Console    Verify by entering Local Authority pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case9

Test Case 10
    Log To Console    Verify by entering Trust pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case10

Test Case 11
    Log To Console    Verify by entering Trust pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case11

Test Case 12
    Log To Console    Verify by Entering deleted pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case12

Test Case 13
    Log To Console    Verify by Entering deactivated pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case13

Test Case 14
    Log To Console    Verify by Entering Fake pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case14

Test Case15
    Log To Console    Verify by Entering death pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case15

Test Case 16
    Log To Console    Verify by entering in-valid pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case16

Test Case 17
    Log To Console    Verify by entering pan number as numeric char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case17

Test Case 18
    Log To Console    Verify by entering pan number as alpha char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case18

Test Case 19
    Log To Console    Verify by entering pan number as special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case19

Test Case 20
    Log To Console    Verify by entering pan number as mixed of alpha numeric special char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case20

Test Case 21
    Log To Console    To verify by entering pan number less than 10 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case21

Test Case 22
    Log To Console    To verify by entering pan number more than 10 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case22

Test Case 23
    Log To Console    To verify by leaving pan number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case23

Test Case 24
    Log To Console    To verify by leaving pan number as empty space
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case24

Test Case 25
    Log To Console    Entering Entering transgender pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case25

Test Case 26
    Log To Console    To verify by changing the 5th char of the pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case26

Test Case 27
    Log To Console    Entering pan number in lower case char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case27

Test Case 28
    Log To Console    Entering e pan number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case28

Test Case 29
    Log To Console    Entering Valid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case29

Test Case 30
    Log To Console    Entering in-Valid client ref number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case30

Test Case 31
    Log To Console    Verify by leaving client ref number empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case31

Test Case 32
    Log To Console    Verify by leaving client ref number empty space
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case32

Test Case 33
    Log To Console    Verify by Entering client ref number as 45 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case33

Test Case 34
    Log To Console    Verify by Entering client ref number more than 45 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case34

Test Case 35
    Log To Console    Verify by entering invalid client username
    ${auth}=    Create List    52652631504%    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test Case 36
    Log To Console    Verify by entering invalid client password
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C2223229077@
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test Case 36
    Log To Console    Verify by entering invalid client username and password
    ${auth}=    Create List    52652631504%    EA6F34B4B3B618A10CF5C2223229077#
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test Case 37
    Log To Console    Verify by leaving client username as empty
    ${auth}=    Create List    ${EMPTY}    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test Case 38
    Log To Console    Verify by leaving client password as empty
    ${auth}=    Create List    526526315047    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test Case 39
    Log To Console    Verify by leaving client username and password as empty
    ${auth}=    Create List    ${EMPTY}    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test Case 40
    Log To Console    Verify by entering client doesnt have the pan compliance api
    ${auth}=    Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290779
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case35

Test_case41
    log to console  Verify that the result code 101 is stored in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/form206ab_compliance_status   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}    DXXXXXXXN CXXXXXA PXXXXXH
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}    N
    Should Be Equal As Strings  ${response.json()['result']['pan_operative_status']}    operative
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}    2024-25
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}    2017-01-07

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT pan, client_ref_num, request_payload, response_payload, http_status_code, result_code, source, error, website_response, website_http_status_code, website_tat, source2_response, source2_http_status_code, source2_tat, pan_source, tat, created_on, updated_on FROM validation.kyc_form206ab_compliance_status where http_status_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
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
        Log To Console    error = ${row[7]}
        Log To Console    website_response = ${row[8]}
        Log To Console    website_http_status_code = ${row[9]}
        Log To Console    website_tat = ${row[10]}
        Log To Console    source2_response = ${row[11]}
        Log To Console    source2_http_status_code = ${row[12]}
        Log To Console    source2_tat = ${row[13]}
        Log To Console    pan_source = ${row[14]}
        Log To Console    tat = ${row[15]}
        Log To Console    created_on = ${row[16]}
        Log To Console    updated_on = ${row[17]}

    END

Test_case42
    log to console  Verify that the result code 102 is stored in DB
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/form206ab_compliance_status   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}    DXXXXXXXN CXXXXXA PXXXXXH
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}    N
    Should Be Equal As Strings  ${response.json()['result']['pan_operative_status']}    operative
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}    2024-25
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}    2017-01-07

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT pan, client_ref_num, request_payload, response_payload, http_status_code, result_code, source, error, website_response, website_http_status_code, website_tat, source2_response, source2_http_status_code, source2_tat, pan_source, tat, created_on, updated_on FROM validation.kyc_form206ab_compliance_status where http_status_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
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
        Log To Console    error = ${row[7]}
        Log To Console    website_response = ${row[8]}
        Log To Console    website_http_status_code = ${row[9]}
        Log To Console    website_tat = ${row[10]}
        Log To Console    source2_response = ${row[11]}
        Log To Console    source2_http_status_code = ${row[12]}
        Log To Console    source2_tat = ${row[13]}
        Log To Console    pan_source = ${row[14]}
        Log To Console    tat = ${row[15]}
        Log To Console    created_on = ${row[16]}
        Log To Console    updated_on = ${row[17]}

    END

Test_case43
    log to console  Verify by hitting the reqeust with get method

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Get Request     mysession     /validation/kyc/v1/form206ab_compliance_status   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['message']}    API running successfully!

Test_case44
    log to console  Verify by hitting the request with OPTIONS method

    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Options Request    mysession    /validation/kyc/v1/form206ab_compliance_status    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    Convert To String    ${response.content}
    Should Be Equal As Strings  ${response.json()['message']}    API running successfully!

Test_case45
    log to console  Verify by hitting the request with http method

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url_http}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/form206ab_compliance_status   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

Test Case46
    log to console  Verify by hitting the request with POST method and checking the requests and response headers
    # Create session
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    # Generate a random client reference number
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

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
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status
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
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Cache-Control']}    must-revalidate
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Referrer-Policy']}    	strict-origin-when-cross-origin
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-Content-Type-Options']}    	nosniff
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-Frame-Options']}    DENY
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['X-XSS-Protection']}    0
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Credentials']}    true
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Headers']}    Origin, Content-Type, X-Auth-Token, Authorization
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Methods']}    	GET, POST, OPTIONS
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${response_headers['Access-Control-Allow-Origin']}    *


Test_case47
    log to console  Verify by hitting the request with OPTIONS method and checking the requests and response headers

    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
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

    ${response}=    Options Request    mysession    /validation/kyc/v1/form206ab_compliance_status    headers=${header}

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

Test_case48
    log to console  Verify by hitting reqeust with additional data in the endpoint

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/form206ab_compliance_statuss   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


Test_case49
    log to console  Verify by hitting the reqeust without authentication

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}     verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "aadhaar":"255305008943", "client_ref_num":"${random_client_ref_num}", "test_scenario": { "get_captcha": {"http_response_code": 502 } } }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/form206ab_compliance_status   json=${body}    headers=${header}
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