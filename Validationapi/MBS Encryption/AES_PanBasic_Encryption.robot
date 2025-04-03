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
    Log To Console  To verify by entering 101 result code PAN number

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}
    
    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result_code']}    101
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['pan']}    BJPPC6837G
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['status']}    Active
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['status_code']}    E
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['name']}    Y
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['fathername']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['dob']}    N
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['seeding_status']}    Y


Test_case02
    Log To Console  To verify by entering 102 result code PAN number

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=LJKPK2266E    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986
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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result_code']}    102
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['message']}    Invalid ID number or combination of inputs
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['pan']}    LJKPK2266E
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['status']}    Invalid
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['status_code']}    X
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['name']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['fathername']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['dob']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['seeding_status']}    ${EMPTY}

Test_case03
    Log To Console  To verify by entering 103 result code PAN number

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=HAHPS7571R    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986
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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result_code']}    103
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['message']}    No record found for the given input
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['pan']}    HAHPS7571R
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['status']}    Invalid
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['status_code']}    N
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['name']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['fathername']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['dob']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result']['seeding_status']}    ${EMPTY}



Test_case04
    Log To Console  To verify by entering invalid PAN number (All alpha char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=QWERTYUIOP    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  To verify by entering invalid PAN number (All numeric char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=1234567890    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986


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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  To verify by entering invalid PAN number (All special char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=!%%%%%%%%%%%%    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  To verify by entering invalid PAN number (Mixed with numeric, alpha and special char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJP!%6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  To verify by entering Company pan number

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  To verify by leaving PAN as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=${EMPTY}   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  To verify by leaving PAN as empty space

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=${SPACE}   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  To verify by entering the Invalid DOB format (YYYY/MM/DD)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=1986/07/11

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case12
    Log To Console  To verify by entering the Invalid DOB format (DD-MM-YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=26-02-1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case14
    Log To Console  To verify by entering the Invalid DOB format (MM/DD/YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G  fathername=Devarajan     name=ChandraPrakashD    dob=02/26/1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case15
    Log To Console  To verify by leaving DOB as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G  fathername=Devarajan     name=ChandraPrakashD    dob=${EMPTY}

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case16
    Log To Console  To Verify that feb month accepts DD as 29 for leap year or not

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=29/02/1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case17
    Log To Console  Verify that feb month accepts DD as 31 or not

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/02/1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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


Test_case18
    Log To Console  Verify by entering invalid dob format (DD.MM.YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=26.02.1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case19
    Log To Console  Verify by entering invalid dob format (DD.MM.YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=26.02.1999


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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case20
    Log To Console  verify by entering dob(0D/0M/YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G  fathername=Devarajan     name=ChandraPrakashD    dob=06/02/1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Log To Console  Verify by entering dob (3D/MM/YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=39/07/1993

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case22
    Log To Console  Verify by entering invalid dob format (DD/2M/YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=26/22/1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case23
    Log To Console  Verify by entering invalid dob format(DD/3M/YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=26/32/1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case24
    Log To Console  Verify by entering invalid dob format(DD/3M/YYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=26/32/1999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case25
    Log To Console  Verify by entering invalid dob format (DDMMYYYY)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=26021999

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case26
    Log To Console  To verify by entering Invalid Name(Special char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G  fathername=Devarajan     name=!@@%%%    dob=11/07/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case27
    Log To Console  To verify by entering Invalid Name(numeric char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=Devarajan     name=123456    dob=11/07/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case28
    Log To Console  To verify by entering name as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=Devarajan     name=${EMPTY}    dob=11/07/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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


Test_case29
    Log To Console  To verify by entering name as empty space

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=Devarajan     name=${SPACE}    dob=11/07/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case30
    Log To Console  To verify by entering Invalid Father Name(Special char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=!%%%()     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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


Test_case31
    Log To Console  To verify by entering Invalid Father Name(numeric char)

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=1234567890     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    
Test_case32
    Log To Console  To verify by entering Father name as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=${EMPTY}     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case33
    Log To Console  To verify by entering Father name as empty space

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=AAJCC0062G   fathername=${EMPTY}     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    
Test_case34
    Log To Console  To verify by entering Wrong client ref num key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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


Test_case35
    Log To Console  To verify by entering With only one client ref number key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}     pan=BJPPC6837G  fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case36
    Log To Console  To verify by entering With two client ref number key

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case37
    Log To Console  To verify by entering One client ref number key with 45 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=chandraprakashDchandraprakashDchandraprakashD   client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case38
    Log To Console  To verify by entering One client ref number key with more than 45 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=chandraprakashDchandraprakashDchandraprakashDD    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986
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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case39
    Log To Console  To verify by making One client ref number key as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${EMPTY}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case40
    Log To Console  To verify by making One client ref number key as empty space

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${SPACE}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case41
    Log To Console  To verify by making One client ref number as special char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=!%%%()%    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    !%%%()%
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${client_ref_num}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${client_ref_num}

Test_case42
    Log To Console  Verify by hitting the request with both valid authorization

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case43
    Log To Console  Verify by hitting the request with both invalid authorization

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbEx     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbEx
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case44
    Log To Console  Verify by hitting the request with authorization with one value and another authorization with another value

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=R1MydFdVU2d1NlBHUXhCb1dZUm5IYU9zb3NwZ2JMdlpDdzVnd3VaWm5xx
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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


Test_case45
    Log To Console  Verify by hitting the request with authorization as empty and another authorization as proper value

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=${EMPTY}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G   fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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

Test_case46
    Log To Console  Verify by hitting the request with both authorization value as empty

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=${EMPTY}     Authorization2=${EMPTY}
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
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


Test_case47
    Log To Console  To verify by entering invalid encrypted data

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=12${encrypted_input}43er
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    401
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case48
    Log To Console  To verify by entering invalid encrypted data key name

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G     fathername=Devarajan     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_datas=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_1']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_2']}    ${EMPTY}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['client_ref_num_3']}    ${EMPTY}

Test_case49
    Log To Console  To verify by entering father name as 75 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=chandraprakashDchandraprakashDchandraprakashDchandraprakashDchandraprakashD     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['result_code']}    101
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case50
    Log To Console  To verify by entering father name as more than 75 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=chandraprakashDchandraprakashDchandraprakashDchandraprakashDchandraprakashDD     name=ChandraPrakashD    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case51
    Log To Console  To verify by entering name as 85 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=Devarajan     name=chandraprakashDchandraprakashDchandraprakashDchandraprakashDchandraprakashDchandrapra    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case52
    Log To Console  To verify by entering name more than 85 char

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${payload}=    Create Dictionary    client_ref_num_1=${client_ref_num}    client_ref_num_2=${client_ref_num}    client_ref_num_3=${client_ref_num}     pan=BJPPC6837G    fathername=Devarajan     name=chandraprakashDchandraprakashDchandraprakashDchandraprakashDchandraprakashDchandraprak    dob=31/10/1986

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

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}


Test_case53
    Log To Console  To verify giving space infront of the DOB

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":"BJPPC6837G", "fathername":"Devarajan", "name":"chandraprakashD", "dob": " 31/10/1986" }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case54
    Log To Console  To verify giving space end of the DOB

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":"BJPPC6837G", "fathername":"Devarajan", "name":"chandraprakashD", "dob": "31/10/1986 " }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case55
    Log To Console  To verify giving space front of the Name

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":"BJPPC6837G", "fathername":"Devarajan", "name":" chandraprakashD", "dob": "31/10/1986" }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case56
    Log To Console  To verify giving space end of the Name

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":"BJPPC6837G", "fathername":"Devarajan", "name":"chandraprakashD ", "dob": "31/10/1986" }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case57
    Log To Console  To verify giving space front of the FatherName

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]

    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":"BJPPC6837G", "fathername":" Devarajan", "name":"chandraprakashD", "dob": "31/10/1986" }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case58
    Log To Console  To verify giving space end of the FatherName

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":"BJPPC6837G", "fathername":"Devarajan ", "name":"chandraprakashD", "dob": "31/10/1986" }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    200
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case59
    Log To Console  To verify giving space front of the pan

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":" BJPPC6837G", "fathername":"Devarajan", "name":"chandraprakashD", "dob": "31/10/1986" }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}

Test_case60
    Log To Console  To verify giving space end of the pan

    # --- Setup ---
    ${base_url}=    Set Variable    ${base_url}
    ${aes_key}=    Set Variable    b7da3567292d7ee55eb1924a1fdfdd8ac1645e22e89d6b7300d32e97ec7b13a1
    ${headers}=    Create Dictionary    Content-Type=application/json   Authorization1=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE     Authorization2=I0qv3rcEihbPAhl0CzuYGWVPiXxp1ymq9DgOF1JoWMfufXZxvqReoVC0gf0levbE
    Create Session    mysession    ${base_url}        verify=true

    # --- Data ---
    ${client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "client_ref_num_1": "${client_ref_num}", "client_ref_num_2": "${client_ref_num}", "client_ref_num_3": "${client_ref_num}", "pan":"BJPPC6837G ", "fathername":"Devarajan", "name":"chandraprakashD", "dob": "31/10/1986" }

    # --- Encrypt ---
    ${encrypt_request}=    Create Dictionary    plain_payload=${body}    encryption_type=aes    aes_key=${aes_key}
    Log To Console    Encrypt Request Body: ${encrypt_request}
    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_request}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}
    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!
    ${encrypted_input}=    Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    # --- Pan basic V2 api ---
    ${PanBasicV2_request}=    Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    PAN Basic Request Body: ${PanBasicV2_request}
    ${PanBasicV2_response}=    Post Request     mysession     /validation/kyc/mbs/v2/pan_basic   json=${PanBasicV2_request}    headers=${headers}
    Log To Console    PAN Basic Response Status: ${PanBasicV2_response.status_code}
    Log To Console    DL Response Content: ${PanBasicV2_response.content}
    ${encrypted_data_output}=    Set Variable    ${PanBasicV2_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    # --- Decrypt ---
    ${decrypt_request}=    Create Dictionary    encrypted_response=${encrypted_data_output}    aes_key=${aes_key}    encryption_type=aes
    Log To Console    Decrypt Request Body: ${decrypt_request}
    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_request}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    ${result_body}=    convert to string    ${decrypt_response.content}
    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Not Be Empty         ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Not Be Empty  ${decrypt_response.json()['plain_response']['request_id']}