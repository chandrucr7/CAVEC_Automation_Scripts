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

Suite Setup       Connect To Database    pymysql    ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}
Suite Teardown    Disconnect From Database

*** Variables ***
${DBName}                 validation
${DBUser}                 qa.chandraprakash.d
${DBPass}                 KrG3yfPY
${DBHost}                 digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}                 3306
${base_url}               https://svcstage.digitap.work
${file_path}              C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\PanFname_Data.csv
${json_schema_file}       C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\Json_schema.json
${output_file}            C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\TestResults.log

*** Keywords ***
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
        Write To Output File    Running Test Case: ${test_case_name}

        ${body}=    Create Dictionary    pan=${row['pan']}    client_ref_num=${row['client_ref_num']}
        ${case_key}=    Evaluate    "case" + str(${index} + 1)

        ${result}=    Run Keyword And Ignore Error    Send Post Request And Validate    ${auth}    ${body}    ${expected_schema_file}    ${case_key}
        ${status}=    Set Variable    ${result}[0]
        ${error}=     Set Variable    ${result}[1]

        IF    '${status}' == 'FAIL'
            Append To List    ${failures}    Test case "${test_case_name}" failed: ${error}
            Write To Output File    Test case "${test_case_name}" FAILED: ${error}
        ELSE
            Write To Output File    Test case "${test_case_name}" PASSED
        END
    END

    Write To Output File    ------------------- END OF TEST CASES -------------------

    Run Keyword If    ${failures.__len__()} > 0    Fail    The following test cases failed:\n${failures}

*** Test Cases ***
Run All Test Cases
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    Run All Test Cases From CSV    ${auth}    ${file_path}    ${json_schema_file}
