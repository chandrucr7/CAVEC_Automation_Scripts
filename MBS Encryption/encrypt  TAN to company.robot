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
${endpoint_url}=    /validation/kyb/mbs/v1/tan_to_company
${authorization_value1}=    I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE 
${authorization_value2}=    I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE 

*** Test Cases ***
Test_case01
    Log To Console  To verify by entering 101 result code tan to company

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt    json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


Test_case02
    Log To Console  To verify by entering 103 result code tan to company

    # --- Setup ---
     ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    PNEQ07804G
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt    json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case03
    Log To Console  To verify by entering tan no greater than 10 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381FA
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


Test_case04
    Log To Console  To verify by entering tan no less than 10 char
 # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELI07737

    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case05
    Log To Console    To verify by entering empty tan no

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    ${empty}
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case06
    Log To Console  To verify by entering space between tan no

   # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12 381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case07
    Log To Console  To verify by entering tan no in lowercase

     # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    rtkb03408g
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case08
    Log To Console  Verify by entering tan no as alpha char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    QWERTYUIOP
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case09
    Log To Console  Verify by entering tan no as special char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    !@#$%^
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case10
    Log To Console  Verify by entering tan no as mixed char

     # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    L!@#F05572

    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case11
    Log To Console  Verify that by entering individual tan no

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    CHEC00690E
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


Test_case12
    Log To Console  To verify by entering Wrong client ref num key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_11=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


Test_case13
    Log To Console  To verify by entering With only one client ref number key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case14
    Log To Console  To verify by entering With two client ref number key

   # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


Test_case15
    Log To Console  To verify by entering One client ref number key with 45 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=test1test1test1test1test1test1test1test1test1    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case16
    Log To Console  To verify by entering One client ref number key with more than 45 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=test1test1test1test1test1test1test1test1test18    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}    tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}


Test_case17
    Log To Console  To verify by making One client ref number key as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${empty}    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case18
    Log To Console  To verify by making One client ref number key as empty space

   # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${space}    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case19
    Log To Console  To verify by making One client ref number as special char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=!@#$%^    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case20
    Log To Console  Verify by hitting the request with both valid authorization

  # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}   client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case21
    Log To Console  Verify by hitting the request with both invalid authorization

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE 8    Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE 0
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}   client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case22
    Log To Console  Verify by hitting the request with authorization with one value and another authorization with another value

   # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${authorization_value1}     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE 1
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case23
    Log To Console  Verify by hitting the request with authorization as empty and another authorization as proper value

   # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${empty}     Authorization2=${authorization_value2}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

Test_case24
    Log To Console  Verify by hitting the request with both authorization value as empty

   # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${empty}     Authorization2=${empty}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${tan_number}=    Set Variable    DELM12381F
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}   client_ref_num_3=${client_ref_num}     tan=${tan_number}

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

    # --- tan api ---
    ${tan_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    tan Request Body: ${tan_request}
    ${tan_response}=    Post Request     mysession    ${endpoint_url}    json=${tan_request}    headers=${headers}
    Log To Console    tan Response Status: ${tan_response.status_code}
    Log To Console    tan Response Content: ${tan_response.content}
    ${encrypted_data_output}=    Set Variable    ${tan_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

