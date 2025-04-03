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
Library    ssl    # To Validate SSL Certificate
Library    socket

Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Disconnect From Database


*** Variables ***
${HOST}    svcstage.digitap.work
${PORT}    443
${DBName}   validation
${DBUser}   qa.chandraprakash.d
${DBPass}   KrG3yfPY
${DBHost}   dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
${base_url_http}=    http://svcstage.digitap.work
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Details V1\\PanDetails_V1_Data.csv
${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Details V1\\Pan_details_V1_data.json

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}   name=${columns[3]}   name_match_method=${columns[4]}   father_name=${columns[5]}   pan_display_name=${columns[6]}
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
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${actual_value}    ${expected_value}    msg=Mismatch for key ${key}
    END

# Post Request and Validate
Send Post Request And Validate V1
    [Arguments]    ${auth}    ${body}    ${expected_schema_file}    ${case_key}
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession    /validation/kyc/v1/pan_details    json=${body}    headers=${header}
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

Send Post Request And Validate BC
    [Arguments]    ${auth}    ${body}    ${expected_schema_file}    ${case_key}
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession    /validation/kyc/v1/pan_details_bc    json=${body}    headers=${header}
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

Get Certificate CN
    [Arguments]    ${host}
    ${ctx}=    Evaluate    ssl.create_default_context()    ssl
    ${sock}=    Evaluate    socket.create_connection(("${host}", 443))    socket
    ${sslsock}=    Evaluate    ${ctx}.wrap_socket(${sock}, server_hostname="${host}")    ssl
    ${cert}=    Evaluate    ${sslsock}.getpeercert()    ssl
    [Return]    ${cert['subject'][0][0][1]}

*** Test Cases ***
Test Case 1
    Log To Console    Verify by entering valid Individual pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case1

Test_case2
    Log To Console    Firm/Limited Liability Partnership pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case2

Test_case3
    Log To Console    Hindu Undivided Family (HUF) pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case3

Test_case4
    Log To Console    Verify by entering Association of Persons (AOP) pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case4

Test_case5
    Log To Console    Verify by entering Body of Individuals (BOI) pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case5

Test_case6
    Log To Console    Verify by entering Government Agency pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case6

Test_case7
    Log To Console    Verify by entering Artificial Juridical Person pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case7

Test_case8
    Log To Console    Verify by entering Local Authority pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case8

Test_case9
    Log To Console    Verify by entering Trust pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case9

Test_case10
    Log To Console    Verify by entering Company pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case10

Test_case11
    Log To Console    Verify by entering in-valid pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case11

Test_case12
    Log To Console    Verify by entering pan number as numeric char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case12

Test_case13
    Log To Console    Verify by entering pan number as alpha char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case13
Test_case14
    Log To Console    Verify by entering pan number as special char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case14

Test_case15
    Log To Console    Verify by entering pan number as mixed of alpha numeric special char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case15

Test_case16
    Log To Console    Verify by entering pan number less than 10 char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case16

Test_case17
    Log To Console    Verify by entering pan number more than 10 char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case17

Test_case18
    log to console  Verify by leaving pan number empty
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case18

Test_case19
    log to console  Verify by leaving pan number empty space
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case19

Test_case20
    log to console  Verify by valid client ref number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case20

Test_case21
    log to console  Verify by in-valid client ref number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case21

Test_case22
    log to console  Verify by leaving client ref number empty
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case22

Test_case23
    log to console  Verify by leaving client ref number empty space
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case23

Test_case24
    log to console  Verify by entering client ref number as 45 char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case24

Test_case25
    log to console  Verify by entering client ref number more than 45 char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case25

Test_case26
    log to console  Verify by changing the 5th char of the pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case26

Test_case27
    log to console  Verify by entering pan number in lower case char
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case27

Test_case28
    log to console  Verify by entering e pan number
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case28

Test_case29
    log to console  Verify by entering Deleted pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case29

Test_case30
    log to console  Verify by entering Deactivated pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case30

Test_case31
    log to console  Verify by entering Fake pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case31

Test_case32
    log to console  Verify by entering No record found pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case32


Test_case33
    log to console  Verify by entering Invalid (Regex) pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case33


Test_case34
    log to console  Verify by entering Valid (Different PAN Display Name) pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case34

Test_case35
    log to console  Entering IT registered transgender pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case35


Test_case36
    log to console  Entering Non IT registered transgender pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    35
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case36

Test_case37
    log to console  pan_details number present in both IT profile api and pan_details link api
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    36
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case37

Test_case38
    log to console  pan_details number not found in IT profile api and pan_details link api
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   37
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case38

Test_case39
    log to console  pan_details number not found in the IT profile and present in the pan_details link api
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    38
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case39

Test_case40
    log to console  Verify by entering valid Individual pan number with bc endpoint
    ${auth}=    create list    740513625625008    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    39
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate BC    ${auth}    ${body}    ${json_schema_file}    case40

Test_case41
    log to console  Verify by entering invalid pan number with bc endpoint
    ${auth}=    create list    740513625625008    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    40
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate BC    ${auth}    ${body}    ${json_schema_file}    case41

#------------------------------------------------------------------------------------------------------#
Test_case42
    log to console  To verify by entering valid name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    41
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case42

Test_case43
    log to console  Name which not match to the pan number (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    42
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case43

Test_case44
    log to console  Name with space at each character (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    43
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case44

Test_case45
    log to console  Dot in the name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    44
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1   ${auth}    ${body}    ${json_schema_file}    case45

Test_case46
    log to console  First name last name middle name (proper Name) (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    45
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case46

Test_case47
    log to console  Middle name first name last name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    46
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case47

Test_case48
    log to console  last name middle name first name (Reverse order) (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    47
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case48

Test_case49
    log to console  First name only (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    48
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case49

Test_case50
    log to console  Middle name only (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    49
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case50

Test_case51
    log to console  last name only (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    50
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case51

Test_case52
    log to console  First letter of first name and first letter of last name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    51
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case52

Test_case53
    log to console  Proper First name and last name as initial (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    42
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case53

Test_case54
    log to console  First name as initial and proper last name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    53
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case54

Test_case55
    log to console  First valid name and last name as other person name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    54
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case55

Test_case56
    log to console  Name with five empty space in middle (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    55
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case56

Test_case57
    log to console  upper case first name and lower case last name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    56
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case57

Test_case58
    log to console  lower case first name and upper case last name (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    57
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case58

Test_case59
    log to console  Entering only half name in proper order (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    58
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case59

Test_case60
    log to console  To verify by entering Name as empty (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    59
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case60

Test_case61
    log to console  To verify by entering Name as empty space (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    60
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case61

Test_case62
    log to console  To verify by entering first name as multiple time along with proper middle and last (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    61
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case62

Test_case63
    log to console  To verify by entering middle name as multiple time along with proper middle and last (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    62
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}     name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case63

Test_case64
    log to console  To verify by entering last name as multiple time along with proper middle and last (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    63
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}      name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case64

Test_case65
    log to console  To verify by entering first name as multiple time (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    64
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}      name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case65

Test_case66
    log to console  To verify by entering middle name as multiple time (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    65
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}      name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case66

Test_case67
    log to console  To verify by entering last name as multiple time (fuzzy)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    66
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}      name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case67

Test_case68
    log to console  To verify by entering valid name (exact)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    67
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}      name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case68

Test_case69
    log to console  To verify by entering valid name (dg_name_match)
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    68
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}      name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case69

Test_case70
    log to console  To verify by entering invalid name match method
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   69
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}      name=${row['name']}     name_match_method=${row['name_match_method']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case70

Test_case71
    log to console  To verify by entering Father name as true individual pan
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   70
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case71

Test_case72
    log to console  To verify by entering Father name as true non individual pan
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   71
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case72

Test_case73
    log to console  To verify by entering Father name as true for invalid pan
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   72
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case73

Test_case74
    log to console  To verify by entering Father name as false
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   73
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case74

Test_case75
    log to console  To verify by leaving Father name as empty
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   74
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case75

Test_case76
    log to console  To verify by leaving Father name as empty space
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   75
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case76

Test_case77
    log to console  To verify by entering Father name as TRUE
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   76
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case77
    
Test_case78
    log to console  To verify by entering Father name as FALSE
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   77
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case78

Test_case79
    log to console  To verify by entering Father name as luther apart from true false
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   78
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    father_name=${row['father_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case79

Test_case80
    log to console  To verify by entering Display name as true individual pan
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   79
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case80

Test_case81
    log to console  To verify by entering Display name as true non individual pan
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   80
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case81

Test_case82
    log to console  To verify by entering Display name as true for invalid pan
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   81
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case82

Test_case83
    log to console  To verify by entering Display name as false
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   82
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    cas83

Test_case84
    log to console  To verify by leaving Display name as empty
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   83
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case84

Test_case85
    log to console  To verify by leaving Display name as empty space
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   84
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case85

Test_case86
    log to console  To verify by entering Display name as TRUE
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   85
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case86

Test_case87
    log to console  To verify by entering Display name as FALSE
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   86
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case87

Test_case88
    log to console  Display name as luther apart from true false
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}   87
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}    pan_display_name=${row['pan_display_name']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case88

#------------------------------------------------------------------------------------------------------------------------------------

Test_case89
    log to console  Disabling the IT user profile
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,7405136256250051,740513625625005]' WHERE (`id` = '9');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="9";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    log to console  Verify by disabling the IT portal and entering the registered pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX6170
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  28/119
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  Ponnammapet S.O
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  Krishnan kovil street
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  636001
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  Salem
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  Tamil Nadu
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    log to console  Enabling the IT user profile after the 89th test case execution
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[52652631504,7405136256250051,740513625625005]' WHERE (`id` = '9');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="9";
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

Test_case90
    log to console  Disabling the Validate pan
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,7405136256250051,740513625625005]' WHERE (`id` = '7');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="7";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    log to console  Verify by disabling the validate pan and entering the registered pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX6170
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  28/119
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  Ponnammapet S.O
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  Krishnan kovil street
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  636001
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  Salem
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  Tamil Nadu
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    log to console  Enabling the validate pan after the 90th test case execution
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[5265263150,7405136256250051,740513625625005]' WHERE (`id` = '7');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="7";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, befisc_fname_api_response, validate_pan_response,validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
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
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

Test_case91
    log to console  Disabling the pan_details endpoint
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,7405136256250051,740513625625005]' WHERE (`id` = '10');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="10";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    log to console  Verify by disabling the pan_details end point and entering the registered pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  FYJPR1333F
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['pan_status']}  Active
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  KOLE RAGHAVI
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  KOLE
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  RAGHAVI
    Should Be Equal As Strings  ${response.json()['result']['gender']}  transgender
    Should Be Equal As Strings  ${response.json()['result']['dob']}  30/03/2002
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX1224
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    log to console  Enabling the pan_details endpoint after the 91th test case execution
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[52652631,7405136256250051,740513625625005]' WHERE (`id` = '10');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="10";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, befisc_fname_api_response, validate_pan_response,pan_details_link_response,pan_details_link_api_tat,pan_details_link_source, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
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
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    father_name_status = ${row[10]}
        Log To Console    pan_status = ${row[11]}
        Log To Console    Source = ${row[12]}
    END

Test_case92
    log to console  Disabling validate pan, IT endpoint, aadhar endpoints
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,7405136256250051,740513625625005]' WHERE (`id` = '7');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,7405136256250051,740513625625005]' WHERE (`id` = '9');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,7405136256250051,740513625625005]' WHERE (`id` = '10');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="7";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="9";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="10";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    log to console  Verify by disabling the all three end points and entering the registered pan number
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  FYJPR1333F
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['pan_status']}  Active
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  KOLE RAGHAVI
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  KOLE
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  RAGHAVI
    Should Be Equal As Strings  ${response.json()['result']['gender']}  transgender
    Should Be Equal As Strings  ${response.json()['result']['dob']}  30/03/2002
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX1224
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    log to console  Enabling the pan_details endpoint after the 92nd test case execution
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[74051362562500599,7405136256250051,740513625625005]' WHERE (`id` = '7');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[74051362562500599,7405136256250051,740513625625005]' WHERE (`id` = '9');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[74051362562500599,7405136256250051,740513625625005]' WHERE (`id` = '10');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="7";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="9";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="10";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, befisc_fname_api_response, validate_pan_response,pan_details_link_response,pan_details_link_api_tat,pan_details_link_source, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
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
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    father_name_status = ${row[10]}
        Log To Console    pan_status = ${row[11]}
        Log To Console    Source = ${row[12]}
    END

Test_case93
    log to console  Verify by entering Invalid pan number with pan basic enabled

    #Pan basic enabled
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,740513625625005,5265263150,7405136256250058,7405136256250051]' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="3";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    #skip validate pan enable
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[74051362562500598,7405136256250051,740513625625005]' WHERE (`id` = '7');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="7";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"FGIPP0546K", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  FGIPP0546K
    Should Be Equal As Strings  ${response.json()['message']}  Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['pan_status']}  Invalid
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['gender']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

Test_case94
    log to console  Verify by entering invalid pan number with pan basic disabled

    #Pan basic enabled
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,740513625625005,5265263150,7405136256250058,7405136256250051]' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="3";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

     #skip validate pan enable
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005789,7405136256250051,740513625625005]' WHERE (`id` = '7');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="7";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"IFIPK6067F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  IFIPK6067F
    Should Be Equal As Strings  ${response.json()['message']}  No record found for the given input
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['gender']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END


Test_case95
    log to console  Verify by enabling the data purging and doing the reqeust for individual IT registered pan
    #query to enable the puring
    ${update_output}=    Execute SQL String    UPDATE `digitap`.`ent_client_ex` SET `purge_policy` = '0' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT purge_policy FROM digitap.ent_client_ex where id = '3';
    FOR    ${row}    IN    @{query_result1}
        Log To Console    purge_policy = ${row[0]}
    END


    ${auth}=    create list    740513625625007    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX6170
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  28/119
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  Ponnammapet S.O
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  Krishnan kovil street
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  636001
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  Salem
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  Tamil Nadu
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, request_payload, response_payload, pan_details_link_response, pan_details_link_api_tat, pan_details_link_source, aureole_softi_pan_details_lite_api_response, aureole_softi_pan_details_lite_api_tat, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    request_payload = ${row[5]}
        Log To Console    response_payload = ${row[6]}
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    aureole_softi_pan_details_lite_api_response = ${row[10]}
        Log To Console    aureole_softi_pan_details_lite_api_tat = ${row[11]}
        Log To Console    validate_pan_response = ${row[12]}
        Log To Console    validate_pan_tat = ${row[13]}
        Log To Console    father_name_status = ${row[14]}
        Log To Console    pan_status = ${row[15]}
        Log To Console    source = ${row[16]}
    END

Test_case96
    log to console  Verify by enabling the data purging and doing the reqeust for Non individual IT registered pan
    #query to enable the puring
    ${update_output}=    Execute SQL String    UPDATE `digitap`.`ent_client_ex` SET `purge_policy` = '0' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT purge_policy FROM digitap.ent_client_ex where id = '3';
    FOR    ${row}    IN    @{query_result1}
        Log To Console    purge_policy = ${row[0]}
    END


    ${auth}=    create list    740513625625007    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"ABOFA5399M", "client_ref_num":"${random_client_ref_num}" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  ABOFA5399M
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Firm/Limited Liability Partnership
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ANNA KIRANA
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ANNA KIRANA
    Should Be Equal As Strings  ${response.json()['result']['gender']}  None
    Should Be Equal As Strings  ${response.json()['result']['dob']}  01/01/2019
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, request_payload, response_payload, pan_details_link_response, pan_details_link_api_tat, pan_details_link_source, aureole_softi_pan_details_lite_api_response, aureole_softi_pan_details_lite_api_tat, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    request_payload = ${row[5]}
        Log To Console    response_payload = ${row[6]}
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    aureole_softi_pan_details_lite_api_response = ${row[10]}
        Log To Console    aureole_softi_pan_details_lite_api_tat = ${row[11]}
        Log To Console    validate_pan_response = ${row[12]}
        Log To Console    validate_pan_tat = ${row[13]}
        Log To Console    father_name_status = ${row[14]}
        Log To Console    pan_status = ${row[15]}
        Log To Console    source = ${row[16]}
    END

Test_case97
    log to console  Verify by enabling the data purging and doing the reqeust for individual IT non registered pan
    #query to enable the puring
    ${update_output}=    Execute SQL String    UPDATE `digitap`.`ent_client_ex` SET `purge_policy` = '0' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT purge_policy FROM digitap.ent_client_ex where id = '3';
    FOR    ${row}    IN    @{query_result1}
        Log To Console    purge_policy = ${row[0]}
    END


    ${auth}=    create list    740513625625007    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"QTOPS8532L", "client_ref_num":"${random_client_ref_num}" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  QTOPS8532L
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MALLESH SABANNA
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MALLESH
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  SABANNA
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  25/07/2003
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX2135
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, request_payload, response_payload, pan_details_link_response, pan_details_link_api_tat, pan_details_link_source, aureole_softi_pan_details_lite_api_response, aureole_softi_pan_details_lite_api_tat, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    request_payload = ${row[5]}
        Log To Console    response_payload = ${row[6]}
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    aureole_softi_pan_details_lite_api_response = ${row[10]}
        Log To Console    aureole_softi_pan_details_lite_api_tat = ${row[11]}
        Log To Console    validate_pan_response = ${row[12]}
        Log To Console    validate_pan_tat = ${row[13]}
        Log To Console    father_name_status = ${row[14]}
        Log To Console    pan_status = ${row[15]}
        Log To Console    source = ${row[16]}
    END

Test_case98
    log to console  Verify by enabling the data purging and doing the reqeust for non individual IT non registered pan
    #query to enable the puring
    ${update_output}=    Execute SQL String    UPDATE `digitap`.`ent_client_ex` SET `purge_policy` = '0' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT purge_policy FROM digitap.ent_client_ex where id = '3';
    FOR    ${row}    IN    @{query_result1}
        Log To Console    purge_policy = ${row[0]}
    END


    ${auth}=    create list    740513625625007    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"ABCFB6551C", "client_ref_num":"${random_client_ref_num}" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  ABCFB6551C
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Firm/Limited Liability Partnership
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  BARHANA ORGANICS LLP
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  BARHANA ORGANICS LLP
    Should Be Equal As Strings  ${response.json()['result']['gender']}  None
    Should Be Equal As Strings  ${response.json()['result']['dob']}  04/03/2024
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, request_payload, response_payload, pan_details_link_response, pan_details_link_api_tat, pan_details_link_source, aureole_softi_pan_details_lite_api_response, aureole_softi_pan_details_lite_api_tat, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    request_payload = ${row[5]}
        Log To Console    response_payload = ${row[6]}
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    aureole_softi_pan_details_lite_api_response = ${row[10]}
        Log To Console    aureole_softi_pan_details_lite_api_tat = ${row[11]}
        Log To Console    validate_pan_response = ${row[12]}
        Log To Console    validate_pan_tat = ${row[13]}
        Log To Console    father_name_status = ${row[14]}
        Log To Console    pan_status = ${row[15]}
        Log To Console    source = ${row[16]}
    END

Test_case99
    log to console  Verify by leaving pan number empty when purge policy is enabled
    #query to enable the puring
    ${update_output}=    Execute SQL String    UPDATE `digitap`.`ent_client_ex` SET `purge_policy` = '0' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT purge_policy FROM digitap.ent_client_ex where id = '3';
    FOR    ${row}    IN    @{query_result1}
        Log To Console    purge_policy = ${row[0]}
    END


    ${auth}=    create list    740513625625007    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case100
     log to console  Verify by leaving pan number empty space when purge policy is enabled
    #query to enable the puring
    ${update_output}=    Execute SQL String    UPDATE `digitap`.`ent_client_ex` SET `purge_policy` = '0' WHERE (`id` = '3');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT purge_policy FROM digitap.ent_client_ex where id = '3';
    FOR    ${row}    IN    @{query_result1}
        Log To Console    purge_policy = ${row[0]}
    END

    ${auth}=    create list    740513625625007    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case101
    log to console  Verify by leaving pan number empty when purge policy is disabled


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case102
     log to console  Verify by leaving pan number empty space when purge policy is disabled

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case103
    log to console  Verify by making the client id to be enabled in CHANGE_pan_details_ENDPOINT for Individual registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

Test_case104
    log to console  Verify by making the client id to be enabled in CHANGE_pan_details_ENDPOINT for Individual non registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

Test_case105
    log to console  Verify by making the client id to be enabled in CHANGE_pan_details_ENDPOINT for non Individual registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

Test_case106
    log to console  Verify by making the client id to be enabled in CHANGE_pan_details_ENDPOINT for non Individual non registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

Test_case107
    log to console  Verify by making the client id to be enabled in pan_details_NULL for Individual registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '17');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="17";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '17');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="17";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

Test_case108
    log to console  Verify by making the client id to be enabled in pan_details_NULL for Individual non registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '17');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="17";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '17');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="17";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

Test_case109
    log to console  Verify by making the client id to be enabled in pan_details_NULL for non Individual registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '17');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="17";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

Test_case110
    log to console  Verify by making the client id to be enabled in pan_details_NULL for non Individual non registered pan number

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005]' WHERE (`id` = '16');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="16";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BKBPH1005G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BKBPH1005G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MAHADEO NARAYAN HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MAHADEO
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  NARAYAN
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  HIVRALE
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/02/2000
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX3619
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  true
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, pan_details_link_response, validate_pan_response, validate_pan_tat, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    pan_details_link_response = ${row[5]}
        Log To Console    validate_pan_response = ${row[6]}
        Log To Console    validate_pan_tat = ${row[7]}
        Log To Console    father_name_status = ${row[8]}
        Log To Console    pan_status = ${row[9]}
        Log To Console    Source = ${row[10]}
    END

    #pan_details endpoint change
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '17');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="17";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


Test_case111
    log to console  Verify by entering pan number with pan display name true for the father name not enabled client id

    #query to disable the father name
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,740513625625005,7405136256250051,74051362562,740513625625005]' WHERE (`id` = '4');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="4";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    #query enable the pan display name
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[7405136256250057,7405136256250051,7405136256250050,740513625625005]' WHERE (`id` = '12');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="12";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"ACKPZ3465E", "client_ref_num":"${random_client_ref_num}", "pan_display_name": "true" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  ACKPZ3465E
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MD GHULAM ZILANI
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MD
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  GHULAM
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ZILANI
    Should Be Equal As Strings  ${response.json()['result']['pan_display_name']}  MD GHULAM ZILANI
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  04/02/1997
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX4941
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, request_payload, response_payload, pan_details_link_response, pan_details_link_api_tat, pan_details_link_source, aureole_softi_pan_details_lite_api_response, aureole_softi_pan_details_lite_api_tat, gender_response, gender_api_tat, validate_pan_response, validate_pan_tat, father_name_status, father_name_source, pan_display_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    request_payload = ${row[5]}
        Log To Console    response_payload = ${row[6]}
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    aureole_softi_pan_details_lite_api_response = ${row[10]}
        Log To Console    aureole_softi_pan_details_lite_api_tat = ${row[11]}
        Log To Console    gender_response = ${row[12]}
        Log To Console    gender_api_tat = ${row[13]}
        Log To Console    validate_pan_response = ${row[14]}
        Log To Console    validate_pan_tat = ${row[15]}
        Log To Console    father_name_status = ${row[16]}
        Log To Console    father_name_source = ${row[17]}
        Log To Console    father_name_status = ${row[18]}
        Log To Console    pan_display_name_status = ${row[19]}
        Log To Console    pan_status = ${row[20]}
        Log To Console    source = ${row[21]}
    END

Test_case112
    log to console  Verify by entering pan number with pan display name true and father name true
    #query to enable IT profile
     ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[7405136256250050,7405136256250051,740513625625005]' WHERE (`id` = '9');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="9";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    #query to enable the father name
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625005,740513625625005,7405136256250051,74051362562,740513625625005]' WHERE (`id` = '4');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="4";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    #query to enable the pan display name
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[7405136256250057,7405136256250051,7405136256250050,740513625625005]' WHERE (`id` = '12');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="12";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"ACKPZ3465E", "client_ref_num":"${random_client_ref_num}", "pan_display_name": "true", "father_name": "true" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['result']['pan']}  ACKPZ3465E
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MD GHULAM ZILANI
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  MD
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  GHULAM
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ZILANI
    Should Be Equal As Strings  ${response.json()['result']['father_name']}  SAYED SIDDIQUI
    Should Be Equal As Strings  ${response.json()['result']['pan_display_name']}  MD GHULAM ZILANI
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  04/02/1997
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX4941
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

        # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${pan}=    Set Variable    ${response.json()['result']['pan']}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, it_tat, http_status_code, result_code, request_payload, response_payload, pan_details_link_response, pan_details_link_api_tat, pan_details_link_source, aureole_softi_pan_details_lite_api_response, aureole_softi_pan_details_lite_api_tat, gender_response, gender_api_tat, validate_pan_response, validate_pan_tat, father_name_status, father_name_source, pan_display_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    it_tat = ${row[2]}
        Log To Console    http_status_code = ${row[3]}
        Log To Console    result_code = ${row[4]}
        Log To Console    request_payload = ${row[5]}
        Log To Console    response_payload = ${row[6]}
        Log To Console    pan_details_link_response = ${row[7]}
        Log To Console    pan_details_link_api_tat = ${row[8]}
        Log To Console    pan_details_link_source = ${row[9]}
        Log To Console    aureole_softi_pan_details_lite_api_response = ${row[10]}
        Log To Console    aureole_softi_pan_details_lite_api_tat = ${row[11]}
        Log To Console    gender_response = ${row[12]}
        Log To Console    gender_api_tat = ${row[13]}
        Log To Console    validate_pan_response = ${row[14]}
        Log To Console    validate_pan_tat = ${row[15]}
        Log To Console    father_name_status = ${row[16]}
        Log To Console    father_name_source = ${row[17]}
        Log To Console    father_name_status = ${row[18]}
        Log To Console    pan_display_name_status = ${row[19]}
        Log To Console    pan_status = ${row[20]}
        Log To Console    source = ${row[21]}
    END


Test_case113
    log to console  Verify by entering pan display name as integer

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"ACKPZ3465E", "client_ref_num":"${random_client_ref_num}", "pan_display_name": true }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test_case114
    log to console  Verify by entering father name as integer
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"ACKPZ3465E", "client_ref_num":"${random_client_ref_num}", "father_name": true }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test_case115
    log to console  Verify by entering Valid authentication
    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case1

Test_cas116
    log to console  Verify by entering in-Valid authentication
    ${auth}=    create list    5265263150$$    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case89

Test_case117
    log to console  Verify by Leaving client user name as empty
    ${auth}=    create list    ${EMPTY}    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case89


Test_case118
    log to console  Verify by leaving client password as empty
    ${auth}=    create list    740513625625005    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case89

Test_case119
    log to console  Verify by leaving client username and password as empty
    ${auth}=    create list    ${EMPTY}    ${EMPTY}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case89

Test_case120
    log to console  Verify by entering authentication which don't having pan details service
    ${auth}=    create list    21717999    XiNLt8vtsRXoKWkcelzHIAsBfZx7O9XBY
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate V1    ${auth}    ${body}    ${json_schema_file}    case89

Test_case121
    log to console  Verify that the result code 101 is stored in DB
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['gender']}  male
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  XXXXXXXX6170
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  India
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, http_status_code, result_code, befisc_fname_api_response, validate_pan_response, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    http_status_code = ${row[2]}
        Log To Console    result_code = ${row[3]}
        Log To Console    befisc_fname_api_response = ${row[4]}
        Log To Console    validate_pan_response = ${row[5]}
        Log To Console    father_name_status = ${row[6]}
        Log To Console    pan_status = ${row[7]}
        Log To Console    Source = ${row[8]}
    END

Test_case122
    log to console  Verify that the result code 102 is stored in DB
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"LJKPK2266E", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['message']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['result']['pan']}  LJKPK2266E
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['gender']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, http_status_code, result_code, befisc_fname_api_response, validate_pan_response, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    http_status_code = ${row[2]}
        Log To Console    result_code = ${row[3]}
        Log To Console    befisc_fname_api_response = ${row[4]}
        Log To Console    validate_pan_response = ${row[5]}
        Log To Console    father_name_status = ${row[6]}
        Log To Console    pan_status = ${row[7]}
        Log To Console    Source = ${row[8]}
    END

Test_case123
    log to console  Verify that the result code 103 is stored in DB
    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"LJKPK2266E", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${response.json()['message']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['result']['pan']}  LJKPK2266E
    Should Be Equal As Strings  ${response.json()['result']['pan_type']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['gender']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['address']['country']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['email']}  ${EMPTY}

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT error, website_response, http_status_code, result_code, befisc_fname_api_response, validate_pan_response, father_name_status, pan_status, source FROM validation.kyc_pan_details_api where http_status_code='${status_code}' AND pan='${pan}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    error = ${row[0]}
        Log To Console    website_response = ${row[1]}
        Log To Console    http_status_code = ${row[2]}
        Log To Console    result_code = ${row[3]}
        Log To Console    befisc_fname_api_response = ${row[4]}
        Log To Console    validate_pan_response = ${row[5]}
        Log To Console    father_name_status = ${row[6]}
        Log To Console    pan_status = ${row[7]}
        Log To Console    Source = ${row[8]}
    END
    
###------------------ additional Security cases ----------------###
Test_case124
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
