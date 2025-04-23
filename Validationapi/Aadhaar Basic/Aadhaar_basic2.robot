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
Library    pabot



Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Merge JSON Responses

*** Variables ***
${DBName}   validation
${DBUser}   qa.chandraprakash.d
${DBPass}   KrG3yfPY
${DBHost}   dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
${base_url_http}=    http://svcstage.digitap.work
${file_path}=  C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Aadhaar Basic\\AadhaarBasicData.csv
${json_schema_file}=  C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Aadhaar Basic\\Aadhaar_Basic_Json_schema.json

*** Keywords ***
Generate Unique Filename
    [Arguments]    ${prefix}=response
    ${timestamp}=    Get Time    epoch
    ${random}=    Evaluate    __import__('random').randint(1000, 9999)
    ${filename}=    Set Variable    ${prefix}_${timestamp}_${random}.json
    [Return]    ${filename}

Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    aadhaar_number=${columns[1]}    client_ref_num=${columns[2]}
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
    ${response}=    Post Request    mysession    /validation/kyc/v1/basic_aadhaar    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${EMPTY}

    # Parse actual response JSON
    ${actual_json}=    Convert To Dictionary    ${response.json()}
    Log To Console    ${actual_json}

    # Save response to temp file
    ${output_dir}=    Set Variable    responses/tmp
    Create Directory    ${output_dir}
    ${file_name}=      Generate Unique Filename    ${case_key}
    ${file_path}=      Set Variable    ${output_dir}/${file_name}
    ${json_string}=    Convert To String    ${actual_json}
    Create File        ${file_path}    ${json_string}

    # Load expected JSON schema
    ${expected_json}=    Load JSON From File    ${expected_schema_file}

    # Extract the relevant case from the JSON schema
    ${expected_case_json}=    Get From Dictionary    ${expected_json}    ${case_key}

    # Validate the JSON response
    Validate JSON Response    ${expected_case_json}    ${actual_json}

Merge JSON Responses
    ${merged}=    Create List
    ${tmp_dir}=   Set Variable    responses/tmp
    ${file_list}=    List Files In Directory    ${tmp_dir}
    FOR    ${file}    IN    @{file_list}
        ${content}=    Get File    ${tmp_dir}/${file}
        ${json}=       Convert To Dictionary    ${content}
        Append To List    ${merged}    ${json}
    END
    ${merged_string}=    Convert To String    ${merged}
    Create File    responses/all_responses.json    ${merged_string}

Disconnect From Database
    Disconnect From Database

*** Test Cases ***
Test Case 1
    Log To Console    Verify by entering valid aadhaar number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case1

Test Case 2
    Log To Console    Verify by entering in-valid Aadhaar number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case2

Test Case 3
    Log To Console    Verify by Leaving Aadhaar number as empty
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case3

Test Case 4
    Log To Console    Verify by giving empty space in the Aadhaar number
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case4

Test Case 5
    Log To Console    Verify by giving Aadhaar number less than 12 char
    ${auth}=    Create List    526526315047    EA6F34B4B3B618A10CF5C22232290778
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4
    ${body}=    Create Dictionary    aadhaar=${row['aadhaar_number']}    client_ref_num=${row['client_ref_num']}
    Send Post Request And Validate    ${auth}    ${body}    ${json_schema_file}    case5

