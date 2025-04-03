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

*** Test Cases ***
Test_case01
    Log To Console  To verify by entering 101 result code DL number

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN3020170004980
    ${dob}=    Set Variable    26/02/1999
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case02
    Log To Console  To verify by entering 102 result code DL number

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN0320000004359
    ${dob}=    Set Variable    15/08/1962
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case03
    Log To Console  To verify by entering 103 result code DL number

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN3020170004980
    ${dob}=    Set Variable    26/02/1998
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}


Test_case04
    Log To Console  To verify by entering invalid DL number (All alpha char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    DLVALIDATION
    ${dob}=    Set Variable    26/02/1998
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


    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case05
    Log To Console  To verify by entering invalid DL number (All numeric char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    1234567890
    ${dob}=    Set Variable    26/02/1998
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case06
    Log To Console  To verify by entering invalid DL number (All special char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    !@%%%%%%%%%
    ${dob}=    Set Variable    26/02/1998
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case07
    Log To Console  To verify by entering invalid DL number (Mixed with numeric, alpha and special char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN30%%%%%**004980
    ${dob}=    Set Variable    26/02/1998
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case08
    Log To Console  To verify by entering invalid DL number (Invalid state code)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TY3020170004980
    ${dob}=    Set Variable    26/02/1998
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case09
    Log To Console  To verify by leaving DL as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    #${dl_number}=    Set Variable    TY3020170004980
    ${dob}=    Set Variable    26/02/1998
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${EMPTY}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case10
    Log To Console  To verify by leaving DL as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    #${dl_number}=    Set Variable    TY3020170004980
    ${dob}=    Set Variable    26/02/1998
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${SPACE}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case11
    Log To Console  To verify by entering the DL registered for multiple vehicle

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case12
    Log To Console  To verify by entering Wrong client ref num key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}


Test_case13
    Log To Console  To verify by entering With only one client ref number key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${EMPTY}

Test_case14
    Log To Console  To verify by entering With two client ref number key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${EMPTY}

Test_case15
    Log To Console  To verify by entering One client ref number key with 45 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=chandraprakashDchandraprakashDchandraprakashD    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    chandraprakashDchandraprakashDchandraprakashD
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case16
    Log To Console  To verify by entering One client ref number key with more than 45 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=chandraprakashDchandraprakashDchandraprakashDD    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    chandraprakashDchandraprakashDchandraprakashDD
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case17
    Log To Console  To verify by making One client ref number key as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${EMPTY}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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


    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case18
    Log To Console  To verify by making One client ref number key as empty space

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${SPACE}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${SPACE}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}
    
Test_case19
    Log To Console  To verify by making One client ref number as special char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=!%%%%%    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    dl_number=${dl_number}    dob=${dob}

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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    !%%%%%
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case20
    Log To Console  Verify by hitting the request with both valid authorization

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case21
    Log To Console  Verify by hitting the request with both invalid authorization

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbEx     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbEx
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    401
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case22
    Log To Console  Verify by hitting the request with authorization with one value and another authorization with another value

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=R1MydFdVU2d1NlBHUXhCb1dZUm5IYU9zb3NwZ2JMdlpDdzVnd3VaWm5xx
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}


Test_case23
    Log To Console  Verify by hitting the request with authorization as empty and another authorization as proper value

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=${EMPTY}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case24
    Log To Console  Verify by hitting the request with both authorization value as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${EMPTY}     Authorization2=${EMPTY}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN4819980001473
    ${dob}=    Set Variable    05/07/1977
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    401
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case25
    Log To Console  To verify by entering invalid encrypted data

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN3020170004980
    ${dob}=    Set Variable    26/02/1999
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
    ${dl_request}=    Create Dictionary    encrypted_data=${encrypted_input}s
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    401
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['error']}    Invalid Encryption

Test_case26
    Log To Console  To verify by entering invalid encrypted key name

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN3020170004980
    ${dob}=    Set Variable    26/02/1999
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
    ${dl_request}=    Create Dictionary    encrypted_datas=${encrypted_input}
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${EMPTY}


Test_case27
    Log To Console  To verify by leaving encrypted data as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${dl_number}=    Set Variable    TN3020170004980
    ${dob}=    Set Variable    26/02/1999
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
    ${dl_request}=    Create Dictionary    encrypted_data=${EMPTY}
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

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${EMPTY}