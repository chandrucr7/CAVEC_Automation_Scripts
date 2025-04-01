*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String


*** Variables ***
${base_url}=    https://svc.digitap.ai
${file_path}=   C:\\Users\\kbinm18681\\PycharmProjects\\CAVEC\\Validation api\\Pan Compliance check api\\PanComplianceData.csv

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
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  DXXXXXXXN CXXXXXA PXXXXXH
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2017-01-07
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case2
    log to console  Verify by entering valid Firm/Limited Liability Partnership pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    1    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AATFV2323C
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  VXXXXT CXXXXXXXXXY SXXXXXXS
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2020-10-02
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case3
    log to console  Verify by entering valid Hindu Undivided Family (HUF) pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    2    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAQHS2176D
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  SXXXXY V AXXXXXL HXF
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2006-07-10
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case4
    log to console  Verify by entering valid Association of Persons (AOP) pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    3    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAAAV2459D
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  VXXXXH EXXXXXXXXXL IXXXXXXXXXXS
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2004-07-23
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case5
    log to console  Verify by entering valid Body of Individuals (BOI) pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    4    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAABS0012L
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  SXXXXXR SXXXXN EXXXXXXXN SXXXXXY
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  1996-10-08
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case6
    log to console  Verify by entering valid Government Agency pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    5    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAAGM0289C
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  MXXXXXXY OF RXXXXXXS
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2017-05-31
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  Y

Test_case7
    log to console  Verify by entering valid Artificial Juridical Person pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    6    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAAJJ0849E
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  J K LXXXXXXXXT UXXXXXXXXY
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2011-07-21
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case8
    log to console  Verify by entering valid Local Authority pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    7    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAALS0235R
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  SXXXA NXXXR EXXXXXXXXXL SXXXXXY
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2003-08-01
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case9
    log to console  Verify by entering valid Trust pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    8    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAATN2208D
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  NXXXXXXL KXXXXXA EXXXXXXXN SXXXXXY
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2000-04-07
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case10
    log to console  Verify by entering valid Company pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    9    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  AAXCS5428G
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  SXXXXXXXXXE CXXXXXXXG PXXXXXE LXXXXXD
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2016-09-15
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N


Test_case11
    log to console  Verify by entering in-valid pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    10    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    Invalid ID number or combination of inputs
    Should contain   ${result_body}    Vampire

Test_case12
    log to console  Verify by entering pan number as numeric char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    11    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    Invalid ID number or combination of inputs
    Should contain   ${result_body}    Vampire

Test_case13
    log to console  Verify by entering pan number as alpha char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    12    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    Invalid ID number or combination of inputs
    Should contain   ${result_body}    Vampire

Test_case14
    log to console  Verify by entering pan number as special char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    13    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    Invalid ID number or combination of inputs
    Should contain   ${result_body}    Vampire

Test_case15
    log to console  Verify by entering pan number as mixed of alpha,numeric,special char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    14    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    Invalid ID number or combination of inputs
    Should contain   ${result_body}    Vampire

Test_case16
    log to console  Verify by entering pan number less than 10 char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    15    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    Invalid ID number or combination of inputs
    Should contain   ${result_body}    Vampire

Test_case17
    log to console  Verify by entering pan number more than 10 char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    16    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    Invalid ID number or combination of inputs
    Should contain   ${result_body}    Vampire

Test_case18
    log to console  Verify by leaving pan number empty
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    17    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    One or more parameters format is wrong
    Should contain   ${result_body}    Vampire

Test_case19
    log to console  Verify by leaving pan number empty space
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    18    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    One or more parameters format is wrong
    Should contain   ${result_body}    Vampire

Test_case20
    log to console  Verify by valid client ref number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    19    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  DXXXXXXXN CXXXXXA PXXXXXH
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2017-01-07
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case21
    log to console  Verify by in-valid client ref number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    20    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    One or more parameters format is wrong
    Should contain   ${result_body}    !@#$%

Test_case22
    log to console  Verify by leaving client ref number empty
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    21    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    One or more parameters format is wrong
    Should contain   ${result_body}    ${EMPTY}

Test_case23
    log to console  Verify by leaving client ref number empty space
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    22    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    One or more parameters format is wrong
    Should contain   ${result_body}    ${SPACE}

Test_case24
    log to console  Verify by entering client ref number as 45 char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    23    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  DXXXXXXXN CXXXXXA PXXXXXH
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2017-01-07
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case25
    log to console  Verify by entering client ref number more than 45 char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    24    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    400
    Should contain   ${result_body}    One or more parameters format is wrong
    Should contain   ${result_body}    chandraprakashDchandraprakashDchandraprakashDCC

Test_case26
    log to console  Verify by changing the 5th char of the pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    25    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    102
    Should contain   ${result_body}    Vampire
    Should contain   ${result_body}  Invalid ID Number or Combination of Inputs

Test_case27
    log to console  Verify by entering pan number in lower case char
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    26    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BJPPC6837G
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  DXXXXXXXN CXXXXXA PXXXXXH
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2017-01-07
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N

Test_case28
    log to console  Verify by entering e pan number
    ${auth}=    create list    740513625625    vpPG3WaVZlc46rx8ZmaPD5qVyGjMiT0t
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}
    ${row}=    Get From List    ${test_data}    27    # Select the first row

    ${pan}=    Get From Dictionary    ${row}    pan
    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

    ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request    mysession     /validation/kyc/v1/form206ab_compliance_status    json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should contain   ${result_body}    200
    Should contain   ${result_body}    101
    Should contain   ${result_body}    Vampire
    Should Be Equal As Strings  ${response.json()['result']['pan']}  BQXPL8246B
    Should Be Equal As Strings  ${response.json()['result']['pan_name']}  NXXXXXXi LXXXXXXXXn
    Should Be Equal As Strings  ${response.json()['result']['pan_allotment_date']}  2023-03-07
    Should Be Equal As Strings  ${response.json()['result']['fin_year']}  2023-24
    Should Be Equal As Strings  ${response.json()['result']['specified_person']}  N