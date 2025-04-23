*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           OperatingSystem
Library           CSVLibrary
Library           String
Library           JSONLibrary
Library           DatabaseLibrary
Library           urllib3
Library           random
Library           DateTime

Suite Setup       Suite Initialization
Suite Teardown    Disconnect From Database

*** Variables ***
${DBName}                 validation
${DBUser}                 qa.chandraprakash.d
${DBPass}                 KrG3yfPY
${DBHost}                 dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}                 3306
${base_url}               https://svcstage.digitap.work
${file_path}              C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\PanFname_Data.csv
${json_schema_file}       C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\Json_schema.json
${output_file}            ${EMPTY}

*** Keywords ***

Suite Initialization
    Initialize Log File
    Connect To Database    pymysql    ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}

Initialize Log File
    ${timestamp}=    Get Time    result_format=%Y-%m-%d_%H-%M-%S
    ${timestamp_no_colons}=    Replace String    ${timestamp}    :    -
    ${logfile_name}=    Set Variable    PanFname_Results_${timestamp_no_colons}.log
    ${output_file}=    Set Variable    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\Test_Results\\${logfile_name}
    Set Global Variable    ${output_file}

Write To Output File
    [Arguments]    ${message}
    Append To File    ${output_file}    ${message}\n

Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    Write To Output File    File content loaded successfully.
    FOR    ${line}    IN    @{lines}[1:]  # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary     Test Cases=${columns[0]}    pan=${columns[1]}    client_ref_num=${columns[2]}
        Append To List    ${test_data}    ${data}
    END
    RETURN    ${test_data}

Validate JSON Response
    [Arguments]    ${expected_json}    ${actual_json}
    ${expected_keys}=    Get Dictionary Keys    ${expected_json}
    ${actual_keys}=      Get Dictionary Keys    ${actual_json}

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
        ${actual_value}=      Get From Dictionary    ${actual_json}    ${key}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${actual_value}    ${expected_value}    msg=Mismatch for key ${key}
    END


Send Post Request And Validate
    [Arguments]    ${auth}    ${body}    ${expected_schema_file}    ${case_key}
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${header}=        Create Dictionary    Content-Type=application/json
    ${response}=      Post Request    mysession    /validation/kyc/v1/pan_to_fname    json=${body}    headers=${header}
    Write To Output File    Request Body: ${body}
    Write To Output File    Response Status Code: ${response.status_code}
    Write To Output File    Response Content: ${response.content}

    ${actual_json}=    Convert To Dictionary    ${response.json()}
    ${expected_json}=    Load JSON From File    ${expected_schema_file}
    ${expected_case_json}=    Get From Dictionary    ${expected_json}    ${case_key}
    Validate JSON Response    ${expected_case_json}    ${actual_json}

Run All Test Cases From CSV
    [Arguments]    ${auth}    ${file_path}    ${expected_schema_file}
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${failures}=    Create List

    Write To Output File    ------------------- STARTING TEST CASES -------------------

    FOR    ${index}    IN RANGE    0    ${test_data.__len__()}
        ${row}=    Get From List    ${test_data}    ${index}
        ${test_case_name}=    Get From Dictionary    ${row}    Test Cases
        Write To Output File    ${EMPTY}
        Write To Output File    ============================================================
        Write To Output File    Running Test Case: ${test_case_name}
        Write To Output File    ------------------------------------------------------------

        ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
        ${case_key}=    Evaluate    "case" + str(${index} + 1)

        ${result}=    Run Keyword And Ignore Error    Send Post Request And Validate    ${auth}    ${body}    ${expected_schema_file}    ${case_key}
        ${status}=    Set Variable    ${result}[0]
        ${error}=     Set Variable    ${result}[1]

        IF    '${status}' == 'FAIL'
            Append To List    ${failures}    Test case "${test_case_name}" failed: ${error}
            Write To Output File    Test case "${test_case_name}" FAILED: ${error}
            Write To Output File     ${EMPTY}
        ELSE
            Write To Output File    Test case "${test_case_name}" PASSED
            Write To Output File     ${EMPTY}
        END
    END

    Write To Output File    ------------------- END OF TEST CASES -------------------

    Run Keyword If    ${failures.__len__()} > 0    Fail    The following test cases failed:\n${failures}


Verify the database values
    [Arguments]    ${client_ref_num}
    ${sql_query}=    Set Variable    SELECT pan, client_ref_num, http_status_code, result_code, error, source_response, source_tat, created_on, updated_on FROM validation.kyc_pan_to_fname_api where client_ref_num='${client_ref_num}' order by id desc limit 1;
    ${query_result}=    Query    ${sql_query}
    Write To Output File    Database Verification for Client Ref Num: ${client_ref_num}
    FOR    ${row}    IN    @{query_result}
        Write To Output File    pan = ${row[0]}
        Write To Output File    client_ref_num = ${row[1]}
        Write To Output File    http_status_code = ${row[2]}
        Write To Output File    result_code = ${row[3]}
        Write To Output File    error = ${row[4]}
        Write To Output File    source_response = ${row[5]}
        Write To Output File    source_tat = ${row[6]}
        Write To Output File    created_on = ${row[7]}
        Write To Output File    updated_on = ${row[8]}
    END
    Run Keyword If    not ${query_result}    Write To Output File    No matching record found in the database.


*** Test Cases ***
Run All Test Cases
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    Run All Test Cases From CSV    ${auth}    ${file_path}    ${json_schema_file}

Test case 2

    Write To Output File    ============================================================
    Write To Output File    Running Test Case: Verify that the result code 101 is stored in DB
    Write To Output File    ------------------------------------------------------------
    Write To Output File     ${EMPTY}

    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }
    Write To Output File    Request Body: ${body}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_to_fname   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    Write To Output File    Response Status Code: ${response.status_code}
    Write To Output File    Response Content: ${response.content}
    Write To Output File     ${EMPTY}
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
    Should Be Equal As Strings  ${response.json()['result']['father_name']}  DEVARAJAN

    Verify the database values     ${client_ref_num}
    


    Write To Output File    ============================================================
    Write To Output File    Finished Test Case: Verify that the result code 101 is stored in DB
    Write To Output File    ------------------------------------------------------------
    