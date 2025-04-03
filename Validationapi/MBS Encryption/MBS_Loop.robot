*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    CSVLibrary
Library    String
Library    JSONLibrary
Library    urllib3
Library    random


*** Variables ***
${base_url}=    https://svcstage.digitap.work
${aes_key}=    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=R1MydFdVU2d1NlBHUXhCb1dWUm5IYU9zb3NwZ2JMdlpDdzVnd3VaWm5j     Authorization2=R1MydFdVU2d1NlBHUXhCb1dWUm5IYU9zb3NwZ2JMdlpDdzVnd3VaWm5j

*** Test Cases ***
Test Cases with DL Numbers

    # --- Setup ---
    Create Session    mysession    ${base_url}        verify=true

    # --- Test Data ---
    @{test_data}=    Create List
    &{test_data_1}=    Create Dictionary    dl_number=TN3020170004980    dob=26/02/1999    test_case_name=To verify by entering 101 result code DL number
    &{test_data_2}=    Create Dictionary    dl_number=TN0320000004359    dob=15/08/1962    test_case_name=To verify by entering 102 result code DL number
    &{test_data_3}=    Create Dictionary    dl_number=TN3020170004980    dob=26/02/1998    test_case_name=Test case for duplicate DL
    &{test_data_4}=    Create Dictionary    dl_number=DLVALIDATION    dob=26/02/1998    test_case_name=Test case for alpha DL
    &{test_data_5}=    Create Dictionary    dl_number=1234567890    dob=26/02/1998    test_case_name=Test case for numeric DL
    &{test_data_6}=    Create Dictionary    dl_number=!%%%%(    dob=26/02/1998    test_case_name=Test case for special characters
    &{test_data_7}=    Create Dictionary    dl_number=TN30%%%%%**004980    dob=26/02/1998    test_case_name=Test case for all numeric,special and alpha characters

    Append To List    @{test_data}    &{test_data_1}
    Append To List    @{test_data}    &{test_data_2}
    Append To List    @{test_data}    &{test_data_3}
    Append To List    @{test_data}    &{test_data_4}
    Append To List    @{test_data}    &{test_data_5}
    Append To List    @{test_data}    &{test_data_6}
    Append To List    @{test_data}    &{test_data_7}

    # --- Loop through test data ---
    FOR    ${data}    IN    @{test_data}
        ${test_case_name}=    Get From Dictionary    ${data}    test_case_name
        ${dl_number}=    Get From Dictionary    ${data}    dl_number
        ${dob}=    Get From Dictionary    ${data}    dob

        Log To Console  \n\n*** Executing Test Case: ${test_case_name} ***\n
        Log To Console  Processing DL Number: ${dl_number}, DOB: ${dob}

        # --- Data Preparation ---
        ${client_ref_num}=    Generate Random String    10    [LETTERS]
        ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

        # --- Encrypt ---
        ${encrypt_request}=    Create Dictionary    plain_payload=${payload}    encryption_type=aes    aes_key=${aes_key}
        Log To Console    Encrypt Request Body: ${encrypt_request}
        ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
        Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
        Log To Console    Encrypt Response Content: ${encrypt_response.content}
        Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
        Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
        ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
        Log To Console    Extracted Encrypted Data: ${encrypted_input}

        # --- DL api ---
        ${dl_request}=    Create Dictionary    encrypted_data=${encrypted_input}
        Log To Console    DL Request Body: ${dl_request}
        ${dl_response}=    Post Request     mysession     /validation/kyc/mbs/v1/dl   json=${dl_request}    headers=${headers}
        Log To Console    DL Response Status: ${dl_response.status_code}
        Log To Console    DL Response Content: ${dl_response.content}
        ${encrypted_data_output}=    Set Variable    ${dl_response.json()['encrypted_data']}
        Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

        # --- Decrypt ---
        ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
        Log To Console    Decrypt Request Body: ${decrypt_request}
        ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
        Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
        Log To Console    Decrypt Response Content: ${decrypt_response.content}

    END
