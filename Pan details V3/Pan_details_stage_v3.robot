*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String
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
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Details V3\\PanDetailsData.csv

*** Keywords ***
Read Test Data From CSV
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}
        Append To List    ${test_data}    ${data}
    END
    [Return]    ${test_data}

*** Test Cases ***
Test_case1
    log to console  Verify by entering valid Individual pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True

Test_case2
    log to console  Verify by entering valid Firm/Limited Liability Partnership pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AATFV2323C
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  VEDANT CONSULTANCY SERVICES
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  VEDANT CONSULTANCY SERVICES
    Should Be Equal As Strings  ${response.json()['result']['dob']}  24/09/2020
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None

Test_case3
    log to console  Verify by entering valid Hindu Undivided Family (HUF) pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAQHS2176D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  SANJAY V AGARWAL HUF
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  SANJAY V AGARWAL HUF
    Should Be Equal As Strings  ${response.json()['result']['dob']}  01/04/2006
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None

Test_case4
    log to console  Verify by entering valid Association of Persons (AOP) pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAAAV2459D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  VIKASH EDUCATIONAL INSTITUTIONS
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  VIKASH EDUCATIONAL INSTITUTIONS
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/03/2003
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None

Test_case5
    log to console  Verify by entering valid Body of Individuals (BOI) pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAABS0012L
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  SANSKAR SARJAN EDUCATION SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  SANSKAR SARJAN EDUCATION SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['dob']}  27/07/1972
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None

Test_case6
    log to console  Verify by entering valid Government Agency pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAAGM0289C
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  MINISTRY OF RAILWAYS
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  MINISTRY OF RAILWAYS
    Should Be Equal As Strings  ${response.json()['result']['dob']}  25/01/1950
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None

Test_case7
    log to console  Verify by entering valid Artificial Juridical Person pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAAJJ0849E
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  J K LAKSHMIPAT UNIVERSITY
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  J K LAKSHMIPAT UNIVERSITY
    Should Be Equal As Strings  ${response.json()['result']['dob']}  07/06/2011
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None

Test_case8
    log to console  Verify by entering valid Local Authority pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAALS0235R
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  SURYA NAGAR EDUCATIONAL SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  SURYA NAGAR EDUCATIONAL SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['dob']}  28/07/1982
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None

Test_case9
    log to console  Verify by entering valid Trust pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAATN2208D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  NATIONAL KANNADA EDUCATION SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  NATIONAL KANNADA EDUCATION SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['dob']}  12/10/1939
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None


Test_case10
    log to console  Verify by entering valid Company pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAXCS5428G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  SPRINGHOUSE COWORKING PRIVATE LIMITED
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  SPRINGHOUSE COWORKING PRIVATE LIMITED
    Should Be Equal As Strings  ${response.json()['result']['dob']}  05/09/2016
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None


Test_case11
    log to console  Verify by entering in-valid pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case12
    log to console  Verify by entering pan number as numeric char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case13
    log to console  Verify by entering pan number as alpha char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
Test_case14
    log to console  Verify by entering pan number as special char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case15
    log to console  Verify by entering pan number as mixed of alpha numeric special char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case16
    log to console  Verify by entering pan number less than 10 char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case17
    log to console  Verify by entering pan number more than 10 char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case18
    log to console  Verify by leaving pan number empty
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case19
    log to console  Verify by leaving pan number empty space
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case20
    log to console  Verify by valid client ref number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True

Test_case21
    log to console  Verify by in-valid client ref number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    !@#$%

Test_case22
    log to console  Verify by leaving client ref number empty
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}

Test_case23
    log to console  Verify by leaving client ref number empty space
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${SPACE}

Test_case24
    log to console  Verify by entering client ref number as 45 char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashD
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True


Test_case25
    log to console  Verify by entering client ref number more than 45 char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashDCC

Test_case26
    log to console  Verify by changing the 5th char of the pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103

Test_case27
    log to console  Verify by entering pan number in lower case char
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True


Test_case28
    log to console  Verify by entering e pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BQXPL8246B
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  Namagiri Lakshmanan
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  Namagiri
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  Lakshmanan
    Should Be Equal As Strings  ${response.json()['result']['dob']}  16/07/1940
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True

Test_case29
    log to console  Verify by entering Valid authentication
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True


Test_case32
    log to console  Verify by entering in-Valid authentication
    ${auth}=    create list    5265263150$$    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case33
    log to console  Verify by Leaving client user name as empty
    ${auth}=    create list    ${EMPTY}    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case34
    log to console  Verify by leaving client password as empty
    ${auth}=    create list    740513625625012    ${EMPTY}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case35
    log to console  Verify by leaving client username and password as empty
    ${auth}=    create list    ${EMPTY}    ${EMPTY}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire

Test_case36
    log to console  Verify by entering authentication which don't having pan details service
    ${auth}=    create list    21717999    XiNLt8vtsRXoKWkcelzHIAsBfZx7O9XB
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case37
    log to console  Verify by entering Deleted pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['message']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AIUPI8924P
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}

Test_case38
    log to console  Verify by entering Deactivated pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['message']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['result']['pan']}  LJKPK2266E
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}



Test_case39
    log to console  Verify by entering Fake pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  DZLPD6077D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  CHANDAN SATENDRANATH DAS
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  CHANDAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  SATENDRANATH
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  DAS
    Should Be Equal As Strings  ${response.json()['result']['dob']}  13/03/1992
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True


Test_case40
    log to console  Verify by entering No record found pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['message']}    No record found for the given input
    Should Be Equal As Strings  ${response.json()['result']['pan']}  HAHPS7571R
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}


Test_case41
    log to console  Verify by entering Invalid (Regex) pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire


Test_case42
    log to console  Verify by entering Valid (Different PAN Display Name) pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    35    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  NWNPS0264Q
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  NATTHANNAGARI SEETHARAMAIAH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  NATTHANNAGARI
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  SEETHARAMAIAH
    Should Be Equal As Strings  ${response.json()['result']['dob']}  01/01/1986
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True

Test_case43
    log to console  Entering IT registered transgender pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    36    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  CVVPS3636N

Test_case44
    log to console  Entering Non IT registered transgender pan number
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  FYJPR1333F

Test_case45
    log to console  Verify that the result code 101 is stored in DB
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BJPPC6837G", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  DEVARAJAN CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  DEVARAJAN
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  CHANDRA PRAKASH
    Should Be Equal As Strings  ${response.json()['result']['dob']}  26/02/1999
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  True


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

Test_case46
    log to console  Verify that the result code 102 is stored in DB
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"LJKPK2266E", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
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
    Should Be Equal As Strings  ${response.json()['result']['fullname']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}  ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['aadhaar_linked']}  None


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

Test_case47
    log to console  Verify by entering father name input
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}", "father_name": "true" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case48
    log to console  Verify by entering skip validate pan input
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}", "skip_validate_pan": "true" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}

Test_case49
    log to console  Verify by entering pan display name input
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"BRZPP3047H", "client_ref_num":"${random_client_ref_num}", "pan_display_name": True }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}


    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${random_client_ref_num}
    
Test_case50
    log to console  Verify by hitting the reqeust with get method

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Get Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['error']}   API running successfully!

Test_case51
    log to console  Verify by hitting the request with OPTIONS method

    ${auth}=    Create List    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true

    ${header}=    Create Dictionary    Content-Type=application/json
    ${response}=    Options Request    mysession    /validation/kyc/v3/pan_details    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    Convert To String    ${response.content}
    Should Be Equal As Strings  ${response.json()['message']}    API running successfully!

Test_case52
    log to console  Verify by hitting the request with http method

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url_http}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"255305008943", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

Test_case53
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
    ${response}=    Post Request    mysession     /validation/kyc/v3/pan_details
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


Test_case54
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

    ${response}=    Options Request    mysession    /validation/kyc/v3/pan_details    headers=${header}

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

Test_case55
    log to console  Verify by hitting reqeust with additional data in the endpoint

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_detailss   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

Test_case56
    log to console  Verify by hitting the reqeust without authentication

    ${auth}=    create list    740513625625005    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}     verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]
    ${body}=   Evaluate    { "pan":"EBQPP7566F", "client_ref_num":"${random_client_ref_num}" }

    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
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