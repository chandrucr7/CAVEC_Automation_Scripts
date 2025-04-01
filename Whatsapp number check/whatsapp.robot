*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DatabaseLibrary
Library    urllib3

Suite Setup     Connect To Database     pymysql     ${DB_Name}      ${DB_user}      ${DB_pass}      ${DB_host}     ${DB_port}
Suite Teardown      Disconnect From Database

*** Variables ***
${DB_Name}        validation
${DB_user}        qa.aishwarya
${DB_pass}        PYvHHoNKAbhYUhF
${DB_host}        digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DB_port}        3306
${file_path}=       C:\\Users\\Aishwarya S\\PycharmProjects\\pythonAPI\\data\\Whatsapp_validation.csv
${client_username}=     740513625625
${client_password}=     vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
${base_url}=    https://svc.digitap.ai
${URL}=     /dp/v1/whatsapp_number_check

*** Keywords ***
Read Test Data From CSV

    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary       mobile=${columns[1]}    client_ref_num=${columns[2]}
        Append To List    ${test_data}    ${data}
    END
    [Return]    ${test_data}


*** Test Cases ***
Test case 1

    log to console  Verify by entering mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0


Test case 2

    log to console  Verify by entering invalid mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 3
    log to console    To verify the mobile number as empty

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 4

    log to console    Empty space in the mobile number
     ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 5

    log to console    To verify the 1 digit mobile number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 6

    log to console    To verify the 2 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 7

    log to console    To verify the 3 digit mobile number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 8

    log to console    4 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 9

    log to console  5 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 10

    log to console  6 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 11

    log to console  7 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 12

    log to console  8 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 13

    log to console    9 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 14

    log to console  10 digit mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0


Test case 15

    log to console    11 digit mobile number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 16

    log to console    12 digit mobile number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 17

    log to console    13 digit mobile number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 18

    log to console    Mobile number with +91

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0


Test case 19
    log to console    Mobile number with 91
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0


Test case 20
    log to console    Alphabetic char in mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 21

    log to console    Special char in mobile number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 22

    log to console    Mobile number mixed with alpha char

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 23

    log to console    Mobile number mixed with special char

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 24
    log to console    Other country mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 25
    log to console    Empty space in front of mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0

Test case 26

    log to console    Empty space in the end of mobile number

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0

Test case 27

    log to console  Mobile number as 0000000000

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 28
    log to console    Mobile number as 1111111111

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong



Test case 29

    log to console    Mobile number as 1234567890

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    28    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong




Test case 30

    log to console    Mobile number starting from 0

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    29    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong



Test case 31

    log to console    Mobile number starting from 1

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    30    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 32

    log to console    Mobile number starting from 2

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    31    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 33

    log to console    Mobile number starting from 3
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    32    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 34

    log to console    Mobile number starting from 4

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    33    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 35

    log to console    Mobile number starting from 5

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    34    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong



Test case 36

    log to console    Mobile number starting from 6
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    35    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Not Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0



Test case 37
    log to console    Mobile number as 09790590318

    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    38    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 38

    log to console    Empty space in middle of mobile number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    37    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong



Test case 39

    log to console    Mobile number as !91
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    38    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong



Test case 40
    log to console    Mobile number as @91
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    39    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 41

    log to console    Mobile number as %91
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    40    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 42
    log to console    Mobile number as &91
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    41    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong



Test case 43

    log to console    Mobile number as $91
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    42    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 44

    log to console    Valid client ref number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    43    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0

Test case 45

    log to console    invalid client ref number
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    44    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    !@#$%
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong


Test case 46

    log to console    client number as Empty
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    45    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

Test case 47
    log to console    Client ref number as 45 char
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    46    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashD
    Should Be Equal As Strings  ${response.json()['result']['status']}     Account Found
    Should Be Equal As Strings  ${response.json()['result']['is_business']}     0

Test case 48
    log to console    Client ref num more than 45 char
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    47    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashDD
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong



Test case 49

    log to console    To verify by entering One client user name and other client password
    ${auth}=    create list    526526315047    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     Client Authentication Failed


Test case 50
    log to console    To verify by entering Empty user name
     ${auth}=    create list    ${EMPTY}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     Client Authentication Failed


Test case 51
    log to console    To verify by entering Empty password

    ${auth}=    create list    ${client_username}   ${empty}
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     Client Authentication Failed


Test case 52

    log to console    Verify by leaving client username and password as empty

    ${auth}=    create list    ${EMPTY}    ${EMPTY}
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     Client Authentication Failed



Test case 53
    log to console    Verify by entering authentication which don't having  whatsapp service

    ${auth}=    create list    21717999    sTO7pF149q5QBAexYRRSgArSptoC3Tfl
    create session    mysession    ${base_url}    auth=${auth}    verify=true
    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     Client Authentication Failed


Test case 54

    log to console    valid email
    ${auth}=    create list    ${client_username}    ${client_password}
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    48    # Select the first row

    ${mobile}=    Get From Dictionary    ${row}    mobile
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary        mobile=${mobile}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${URL}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Moon
    Should Be Equal As Strings  ${response.json()['error']}     One or more parameters format is wrong

































































