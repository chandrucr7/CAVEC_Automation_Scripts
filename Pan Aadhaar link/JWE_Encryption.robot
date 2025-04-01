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
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Aadhaar link\\PanAadhaarLinkData.csv
${json_schema_file}=    C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Aadhaar link\\Pan_aadhaar_link_Json_schema.json


*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}   aadhaar=${columns[2]}    client_ref_num=${columns[3]}
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
    ${response}=    Post Request    mysession    /validation/kyc/v1/pan_aadhaar_link    json=${body}    headers=${header}
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
Test_case01
    log to console  Verify by hitting the 200 response code with JWE format with JSON format

    #Query execution enabling the JWE 740513625625006 client id
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   Pan_aadhaar_link_jwe_list  = ${row[0]}
    END

    #Query execution enabling the Hybrid for 740513625625010 client id
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625010]' WHERE (`id` = '20');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="20";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    Pan_aadhaar_link_hybrid_list = ${row[0]}
    END

    #Query execution disabling the text for 740513625625006 client id
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625010]' WHERE (`id` = '18');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="18";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    Pan_aadhaar_link_text_list = ${row[0]}
    END

    #------After query execution, actual api call starts ------------------------------------
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Step 1: Encrypt Endpoint -------------------------------------------------------------------------

    ${encrypt_body}=   Evaluate    { "plain_payload": { "pan": "BJPPC6837G", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    create dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}


    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    ${EMPTY}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}
    Log To Console    ${EMPTY}

    # Step 2: Pan Aadhaar Link Endpoint ------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling PAN-Aadhaar Link Endpoint...
    Log To Console    ${EMPTY}

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN-Aadhaar Link Request Body: ${pan_aadhaar_body}
    Log To Console    ${EMPTY}

    ${pan_aadhaar_response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    PAN-Aadhaar Link Response Status: ${pan_aadhaar_response.status_code}
    Log To Console    PAN-Aadhaar Link Response Content: ${pan_aadhaar_response.content}


    ${encrypted_data_output}=  Set Variable    ${pan_aadhaar_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # Step 3: Decrypt Endpoint-------------------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling Decryption Endpoint...
    Log To Console    ${EMPTY}

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}
    Log To Console    ${EMPTY}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


Test_case02
    log to console  Verify by hitting the 200 response code with JWE format with text format

    #Query execution enabling the text for 740513625625006 client id
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '18');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="18";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    Pan_aadhaar_link_text_list = ${row[0]}
    END

    #------After query execution, actual api call starts ------------------------------------
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Step 1: Encrypt Endpoint -------------------------------------------------------------------------

    ${encrypt_body}=   Evaluate    { "plain_payload": { "pan": "BJPPC6837G", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    create dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}


    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    ${EMPTY}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}
    Log To Console    ${EMPTY}

    # Step 2: Pan Aadhaar Link Endpoint ------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling PAN-Aadhaar Link Endpoint...
    Log To Console    ${EMPTY}

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN-Aadhaar Link Request Body: ${pan_aadhaar_body}
    Log To Console    ${EMPTY}

    ${pan_aadhaar_response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    PAN-Aadhaar Link Response Status: ${pan_aadhaar_response.status_code}
    Log To Console    PAN-Aadhaar Link Response Content: ${pan_aadhaar_response.content}


    ${encrypted_data_output}=  Set Variable    ${pan_aadhaar_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # Step 3: Decrypt Endpoint-------------------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling Decryption Endpoint...
    Log To Console    ${EMPTY}

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}
    Log To Console    ${EMPTY}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


    #Query execution for reverting the text config
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[7405136256250]' WHERE (`id` = '18');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="18";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    Pan_aadhaar_link_text_list = ${row[0]}
    END

Test_case3
    log to console  Verify by entering normal payload for the encrypted input
    ${auth}=    create list    526526315047    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "encrypted_data":"eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2R0NNIn0.QJMZwoJJcQ_KF4hA6S3G69tdKrvlV0KKOMig1q_DO8m2UB0M80QKJrjlp9zWVaPPWWBn-3uJ30uWs1cby1znZo9YThYJLEwudepQ-BEEzyIWcvAolFc63-SpOTlJDw1bfpvkvnuqcQFUejHQFpf6NU6pKRlj943nhpxx6RJ2jfY.bJPB7XEBvfN-dhrf.pv6wslKyPcyjOQDWRX7iTb-Ixk0zZw9DWHwhc1nT2Lou6lG5WtFkskqwFSYHGhFqvvii8cbK-LEI7oPmWyeUoXsVthkRehO7nGRF0644EvZvKouQhDcd.3FOgBSIyKeBWtJzI7Qv7vw" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong


Test_case4
    log to console  Verify by hitting the request with invalid encrypted data
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "encrypted_data":"JhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2R0NNIn0.QJMZwoJJcQ_KF4hA6S3G69tdKrvlV0KKOMig1q_DO8m2UB0M80QKJrjlp9zWVaPPWWBn-3uJ30uWs1cby1znZo9YThYJLEwudepQ-BEEzyIWcvAolFc63-SpOTlJDw1bfpvkvnuqcQFUejHQFpf6NU6pKRlj943nhpxx6RJ2jfY.bJPB7XEBvfN-dhrf.pv6wslKyPcyjOQDWRX7iTb-Ixk0zZw9DWHwhc1nT2Lou6lG5WtFkskqwFSYHGhFqvvii8cbK-LEI7oPmWyeUoXsVthkRehO7nGRF0644EvZvKouQhDcd.3FOgBSIyKeBWtJzI7Qv7vw" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Invalid Encryption

Test_case5
    log to console  Verify by hitting the request with invalid encrypted data value as empty
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "encrypted_data":"" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Invalid Encryption

Test_case6
    log to console  Verify by hitting the request with invalid encrypted data key
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "encrypted_datas":"eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2R0NNIn0.QJMZwoJJcQ_KF4hA6S3G69tdKrvlV0KKOMig1q_DO8m2UB0M80QKJrjlp9zWVaPPWWBn-3uJ30uWs1cby1znZo9YThYJLEwudepQ-BEEzyIWcvAolFc63-SpOTlJDw1bfpvkvnuqcQFUejHQFpf6NU6pKRlj943nhpxx6RJ2jfY.bJPB7XEBvfN-dhrf.pv6wslKyPcyjOQDWRX7iTb-Ixk0zZw9DWHwhc1nT2Lou6lG5WtFkskqwFSYHGhFqvvii8cbK-LEI7oPmWyeUoXsVthkRehO7nGRF0644EvZvKouQhDcd.3FOgBSIyKeBWtJzI7Qv7vw" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test_case7
    log to console  Verify by hitting the JWE payload with Hybrid enabled client id
    ${auth}=    create list    740513625625010    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "encrypted_data":"eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2R0NNIn0.QJMZwoJJcQ_KF4hA6S3G69tdKrvlV0KKOMig1q_DO8m2UB0M80QKJrjlp9zWVaPPWWBn-3uJ30uWs1cby1znZo9YThYJLEwudepQ-BEEzyIWcvAolFc63-SpOTlJDw1bfpvkvnuqcQFUejHQFpf6NU6pKRlj943nhpxx6RJ2jfY.bJPB7XEBvfN-dhrf.pv6wslKyPcyjOQDWRX7iTb-Ixk0zZw9DWHwhc1nT2Lou6lG5WtFkskqwFSYHGhFqvvii8cbK-LEI7oPmWyeUoXsVthkRehO7nGRF0644EvZvKouQhDcd.3FOgBSIyKeBWtJzI7Qv7vw" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test_case08
    log to console  Verify by hitting the JWE payload when there is no client id present in the JWE config

    #Query execution for making the JWE config as empty
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END


    #------After query execution, actual api call starts ------------------------------------
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Step 1: Encrypt Endpoint -------------------------------------------------------------------------

    ${encrypt_body}=   Evaluate    { "plain_payload": { "pan": "BJPPC6837G", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    create dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}


    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    ${EMPTY}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}
    Log To Console    ${EMPTY}

    # Step 2: Pan Aadhaar Link Endpoint ------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling PAN-Aadhaar Link Endpoint...
    Log To Console    ${EMPTY}

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN-Aadhaar Link Request Body: ${pan_aadhaar_body}
    Log To Console    ${EMPTY}

    ${pan_aadhaar_response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    PAN-Aadhaar Link Response Status: ${pan_aadhaar_response.status_code}
    Log To Console    PAN-Aadhaar Link Response Content: ${pan_aadhaar_response.content}


    Should Be Equal As Strings  ${pan_aadhaar_response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${pan_aadhaar_response.json()['client_ref_num']}    ${EMPTY}
    Should Be Equal As Strings  ${pan_aadhaar_response.json()['error']}    One or more parameters format is wrong


    #Revert query for enabling the client id in JWE config
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END


Test_case9
    log to console  Verify by hitting the Normal payload when there is no client id present in the JWE config

    #Query execution for making the JWE config as empty
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END


    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BMGPS4514N", "aadhaar":"730811780605", "client_ref_num":"Vampire" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result_code']}    108
    Should Be Equal As Strings  ${response.json()['result']['message']}    Aadhaar PAN linking failed due to DOB mismatch
    Should Be Equal As Strings  ${response.json()['result']['code']}    LINK-008


    #Revert query for enabling the client id in JWE config
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END


Test_case10
    log to console  Verify by hitting the encrypted request with client id enabled in config but not in the KMS manager

    #Query execution for enabling client id in JWE
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625011]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END


    #------After query execution, actual api call starts ------------------------------------
    ${auth}=    create list    740513625625011    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Step 1: Encrypt Endpoint -------------------------------------------------------------------------

    ${encrypt_body}=   Evaluate    { "plain_payload": { "pan": "BJPPC6837G", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    create dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}


    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    ${EMPTY}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}
    Log To Console    ${EMPTY}

    # Step 2: Pan Aadhaar Link Endpoint ------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling PAN-Aadhaar Link Endpoint...
    Log To Console    ${EMPTY}

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN-Aadhaar Link Request Body: ${pan_aadhaar_body}
    Log To Console    ${EMPTY}

    ${pan_aadhaar_response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    PAN-Aadhaar Link Response Status: ${pan_aadhaar_response.status_code}
    Log To Console    PAN-Aadhaar Link Response Content: ${pan_aadhaar_response.content}


    Should Be Equal As Strings  ${pan_aadhaar_response.json()['http_response_code']}    451
    Should Be Equal As Strings  ${pan_aadhaar_response.json()['error']}    Misconfiguration


    #Revert query for enabling the client id in JWE config
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END

Test_case11
    log to console  Verify by hitting the normal request with client id enabled in config but not in the KMS manager

    #Query execution for enabling client id in JWE
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625011]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END

    #Query execution for the Hybrid encryption
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625010]' WHERE (`id` = '20');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="20";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    Pan_details_Hybrid_list = ${row[0]}
    END


    ${auth}=    create list    740513625625011    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan": "BQNPG8996F", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Capture Output
    ${response_content}=    Set Variable    ${response.content}
    ${status_code}=    Set Variable    ${response.status_code}
    ${client_ref_num}=    Set Variable    ${response.json()['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}


    #Revert query for enabling the client id in JWE config
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END

Test_case12
    log to console  Verify by hitting the JWE framework same client id is enabled in both JWE & Hybrid config

    #Query execution for the JWE encryption
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END

    #Query execution for the JWE client id in the hybird configuration
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '20');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="20";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_hybrid_list = ${row[0]}
    END


    #------After query execution, actual api call starts ------------------------------------
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Step 1: Encrypt Endpoint -------------------------------------------------------------------------

    ${encrypt_body}=   Evaluate    { "plain_payload": { "pan": "BJPPC6837G", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    create dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}


    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    ${EMPTY}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}
    Log To Console    ${EMPTY}

    # Step 2: Pan Aadhaar Link Endpoint ------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling PAN-Aadhaar Link Endpoint...
    Log To Console    ${EMPTY}

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN-Aadhaar Link Request Body: ${pan_aadhaar_body}
    Log To Console    ${EMPTY}

    ${pan_aadhaar_response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    PAN-Aadhaar Link Response Status: ${pan_aadhaar_response.status_code}
    Log To Console    PAN-Aadhaar Link Response Content: ${pan_aadhaar_response.content}


    Should Be Equal As Strings  ${pan_aadhaar_response.json()['http_response_code']}    451
    Should Be Equal As Strings  ${pan_aadhaar_response.json()['error']}    Misconfiguration


    #Revert Query execution for the JWE encryption
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END

    #Revert Query execution for the JWE client id in the hybird configuration
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625010]' WHERE (`id` = '20');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="20";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_hybrid_list = ${row[0]}
    END

Test_case13
    log to console  Verify by hitting the JWE framework client id is not enabled in JWE config but in hybrid config

    #Query execution for the JWE encryption
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[74051362562500]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END

    #Query execution enabling JWE client id in hybrid config
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '20');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="20";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_hybrid_list = ${row[0]}
    END


    #------After query execution, actual api call starts ------------------------------------
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Step 1: Encrypt Endpoint -------------------------------------------------------------------------

    ${encrypt_body}=   Evaluate    { "plain_payload": { "pan": "BJPPC6837G", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    create dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}


    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    ${EMPTY}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}
    Log To Console    ${EMPTY}

    # Step 2: Pan Aadhaar Link Endpoint ------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling PAN-Aadhaar Link Endpoint...
    Log To Console    ${EMPTY}

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN-Aadhaar Link Request Body: ${pan_aadhaar_body}
    Log To Console    ${EMPTY}

    ${pan_aadhaar_response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    PAN-Aadhaar Link Response Status: ${pan_aadhaar_response.status_code}
    Log To Console    PAN-Aadhaar Link Response Content: ${pan_aadhaar_response.content}


    Should Be Equal As Strings  ${pan_aadhaar_response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${pan_aadhaar_response.json()['error']}    One or more parameters format is wrong


    #Revert Query execution for the JWE encryption
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_jwe_list = ${row[0]}
    END

    #Revert Query execution enabling JWE client id in hybrid config
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625010]' WHERE (`id` = '20');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="20";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    pan_aadhaar_link_hybrid_list = ${row[0]}
    END

Test_case14
    log to console  Verify by checking the JWE response is stored properly in the Database

    #Query execution enabling the JWE 740513625625006 client id
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625006]' WHERE (`id` = '19');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="19";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   Pan_aadhaar_link_jwe_list  = ${row[0]}
    END

    #Query execution enabling the Hybrid for 740513625625010 client id
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625010]' WHERE (`id` = '20');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="20";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    Pan_aadhaar_link_hybrid_list = ${row[0]}
    END

    #Query execution disabling the text for 740513625625006 client id
    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[740513625625010]' WHERE (`id` = '18');

    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="18";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    Pan_aadhaar_link_text_list = ${row[0]}
    END

    #------After query execution, actual api call starts ------------------------------------
    ${auth}=    create list    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    # Step 1: Encrypt Endpoint -------------------------------------------------------------------------

    ${encrypt_body}=   Evaluate    { "plain_payload": { "pan": "BJPPC6837G", "aadhaar": "669446616170", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    create dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}


    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    ${EMPTY}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}
    Log To Console    ${EMPTY}

    # Step 2: Pan Aadhaar Link Endpoint ------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling PAN-Aadhaar Link Endpoint...
    Log To Console    ${EMPTY}

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN-Aadhaar Link Request Body: ${pan_aadhaar_body}
    Log To Console    ${EMPTY}

    ${pan_aadhaar_response}=    Post Request     mysession     /validation/kyc/v1/pan_aadhaar_link   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    PAN-Aadhaar Link Response Status: ${pan_aadhaar_response.status_code}
    Log To Console    PAN-Aadhaar Link Response Content: ${pan_aadhaar_response.content}


    ${encrypted_data_output}=  Set Variable    ${pan_aadhaar_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # Step 3: Decrypt Endpoint-------------------------------------------------------------------------------
    Log To Console    ${EMPTY}
    Log To Console    Calling Decryption Endpoint...
    Log To Console    ${EMPTY}

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}
    Log To Console    ${EMPTY}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    ${EMPTY}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


        # Capture Output
    ${response_content}=    Set Variable    ${decrypt_response.content}
    ${status_code}=    Set Variable    ${decrypt_response.status_code}
    ${client_ref_num}=    Set Variable    ${decrypt_response.json()['plain_response']['client_ref_num']}

    # Validations
    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result_code']}    101
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num']}    ${random_client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['message']}    Is already linked to given Aadhaar
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['code']}    LINK-001

    # Prepare SQL Query
    ${sql_query}=    Set Variable    SELECT pan, aadhaar, client_ref_num, request_payload, response_payload, http_response_code, result_code, error, website_response, tat, created_on, updated_on FROM validation.kyc_pan_aadhaar_link_api where http_response_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    #Log To Console    ${query_result}

    FOR    ${row}    IN    @{query_result}
        Log To Console    pan = ${row[0]}
        Log To Console    aadhaar = ${row[1]}
        Log To Console    client_ref_num = ${row[2]}
        Log To Console    request_payload = ${row[3]}
        Log To Console    response_payload = ${row[4]}
        Log To Console    http_response_code = ${row[5]}
        Log To Console    result_code = ${row[6]}
        Log To Console    error = ${row[7]}
        Log To Console    website_response = ${row[8]}
        Log To Console    tat = ${row[9]}
        Log To Console    created_on = ${row[10]}
        Log To Console    updated_on = ${row[11]}
    END