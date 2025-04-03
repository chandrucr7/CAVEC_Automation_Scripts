*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DatabaseLibrary
Library    urllib3
Library    random
Library    DateTime

Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Disconnect From Database


*** Variables ***
${DBName}   validation
${DBUser}   qa.chandraprakash.d
${DBPass}   KrG3yfPY
${DBHost}   dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
${Reqeust_api}=    /validation/kyc/v4/pan_details/request
${Status_api}=    /validation/kyc/v4/pan_details/status
${file_path}=   C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan Details V4\\PanDetails_V4_Data.csv

*** Keywords ***
Read Test Data From CSV for Generate otp api
    [Arguments]    ${file_path}
    ${test_data}=    Create List
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}[1:]    # Skip the header line
        ${columns}=    Split String    ${line}    separator=,
        ${data}=    Create Dictionary    pan=${columns[1]}    client_ref_num=${columns[2]}   name=${columns[3]}   name_match_method=${columns[4]}   father_name=${columns[5]}   pan_display_name=${columns[6]}
        Append To List    ${test_data}    ${data}
    END
    [Return]    ${test_data}


*** Test Cases ***
Test Case 1
    Log To Console    Pan details request api
    Log To Console    Test Case1: Entering the registered individual pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BPXPV0239M
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    AMIT VINOD
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    AMIT
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    VINOD
    Should Be Equal As Strings  ${response.json()['result']['dob']}    14/03/1997

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Not Be Empty        ${status_response.json()['request_id']}
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
    Should Be Equal As Strings    ${status_response.json()['api_status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['result']['pan']}  BPXPV0239M
    Should Be Equal As Strings    ${status_response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings    ${status_response.json()['result']['gender']}  male
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_number']}  XXXXXXXX8745
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings    ${status_response.json()['result']['address']['building_name']}  C-52
    Should Be Equal As Strings    ${status_response.json()['result']['address']['locality']}  Inderpuri
    Should Be Equal As Strings    ${status_response.json()['result']['address']['street_name']}  BUDH NAGAR, J.J. COLONY, INDERPURI
    Should Be Equal As Strings    ${status_response.json()['result']['address']['pincode']}  110012
    Should Be Equal As Strings    ${status_response.json()['result']['address']['city']}  Inderpuri
    Should Be Equal As Strings    ${status_response.json()['result']['address']['state']}  Delhi
    Should Be Equal As Strings    ${status_response.json()['result']['address']['country']}  India
    Should Be Equal As Strings    ${status_response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['email']}  ${EMPTY}



    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 2
    Log To Console    Pan details request api
    Log To Console    Test Case2: Entering the non registered individual pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    1    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    FLYPS6380D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    RAJENDRA SHARMA
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    RAJENDRA
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SHARMA
    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/12/1987

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
    Should Not Be Empty        ${status_response.json()['request_id']}
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
    Should Be Equal As Strings    ${status_response.json()['api_status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['result']['pan']}  FLYPS6380D
    Should Be Equal As Strings    ${status_response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings    ${status_response.json()['result']['gender']}  male
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_linked']}  False
    Should Be Equal As Strings    ${status_response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['country']}  India
    Should Be Equal As Strings    ${status_response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['email']}  ${EMPTY}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 3
    Log To Console    Pan details request api
    Log To Console    Test Case3: Entering the Firm/Limited Liability Partnership pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    2    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AATFV2323C
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    VEDANT CONSULTANCY SERVICES
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    VEDANT CONSULTANCY SERVICES
    Should Be Equal As Strings  ${response.json()['result']['dob']}    24/09/2020

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 4
    Log To Console    Pan details request api
    Log To Console    Test Case4: Entering the Hindu Undivided Family (HUF) pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    3    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAQHS2176D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    SANJAY V AGARWAL HUF
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SANJAY V AGARWAL HUF
    Should Be Equal As Strings  ${response.json()['result']['dob']}    01/04/2006

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 5
    Log To Console    Pan details request api
    Log To Console    Test Case5: Entering the Association of Persons (AOP) pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    4    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAAAV2459D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    VIKASH EDUCATIONAL INSTITUTIONS
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    VIKASH EDUCATIONAL INSTITUTIONS
    Should Be Equal As Strings  ${response.json()['result']['dob']}    27/03/2003

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 6
    Log To Console    Pan details request api
    Log To Console    Test Case6: Entering the Body of Individuals (BOI) pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    5    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAABS0012L
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    SANSKAR SARJAN EDUCATION SOCIETY
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SANSKAR SARJAN EDUCATION SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['dob']}    27/07/1972

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 7
    Log To Console    Pan details request api
    Log To Console    Test Case7: Entering the Government Agency pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    6    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAAGM0289C
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    MINISTRY OF RAILWAYS
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    MINISTRY OF RAILWAYS
    Should Be Equal As Strings  ${response.json()['result']['dob']}    25/01/1950

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 8
    Log To Console    Pan details request api
    Log To Console    Test Case8: Entering the Artificial Juridical Person pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    7    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAAJJ0849E
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    J K LAKSHMIPAT UNIVERSITY
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    J K LAKSHMIPAT UNIVERSITY
    Should Be Equal As Strings  ${response.json()['result']['dob']}    07/06/2011

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 9
    Log To Console    Pan details request api
    Log To Console    Test Case9: Entering the Local Authority pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    8    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAALS0235R
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    SURYA NAGAR EDUCATIONAL SOCIETY
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SURYA NAGAR EDUCATIONAL SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['dob']}    28/07/1982

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 10
    Log To Console    Pan details request api
    Log To Console    Test Case10: Entering the Trust pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    9    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAATN2208D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    NATIONAL KANNADA EDUCATION SOCIETY
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    NATIONAL KANNADA EDUCATION SOCIETY
    Should Be Equal As Strings  ${response.json()['result']['dob']}    12/10/1939

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 11
    Log To Console    Pan details request api
    Log To Console    Test Case11: Entering the Company pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    10    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AAXCS5428G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    SPRINGHOUSE COWORKING PRIVATE LIMITED
    Should Be Empty      ${response.json()['result']['first_name']}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SPRINGHOUSE COWORKING PRIVATE LIMITED
    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/09/2016

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 12
    Log To Console    Pan details request api
    Log To Console    Test Case12: Entering the in-valid pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    11    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}   Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

Test Case 13
    Log To Console    Pan details request api
    Log To Console    Test Case13: Entering pan number as numeric char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    12    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

Test Case 14
    Log To Console    Pan details request api
    Log To Console    Test Case14: Entering pan number as alpha char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    13    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

Test Case 15
    Log To Console    Pan details request api
    Log To Console    Test Case15: Entering pan number as special char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    14    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

Test Case 16
    Log To Console    Pan details request api
    Log To Console    Test Case16: Entering pan number as mixed of alpha numeric special char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    15    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

Test Case 17
    Log To Console    Pan details request api
    Log To Console    Test Case17: Entering pan number less than 10 char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    16    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

Test Case 18
    Log To Console    Pan details request api
    Log To Console    Test Case18: Entering pan number more than 10 char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    17    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

Test Case 19
    Log To Console    Pan details request api
    Log To Console    Test Case19: Entering pan number empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    18    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test Case 20
    Log To Console    Pan details request api
    Log To Console    Test Case20: Entering pan number empty space
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    19    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test Case 21
    Log To Console    Pan details request api
    Log To Console    Test Case21: Entering in-valid client ref number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    20    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    !@#$%
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test Case 22
    Log To Console    Pan details request api
    Log To Console    Test Case22: Entering leaving client ref number empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    21    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${EMPTY}
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test Case 23
    Log To Console    Pan details request api
    Log To Console    Test Case23: Entering leaving client ref number empty space
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    22    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    ${SPACE}
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test Case 24
    Log To Console    Pan details request api
    Log To Console    Test Case24: Entering client ref number as 45 char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    23    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashD
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BPXPV0239M
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    AMIT VINOD
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    AMIT
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    VINOD
    Should Be Equal As Strings  ${response.json()['result']['dob']}    14/03/1997

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  chandraprakashDchandraprakashDchandraprakashD
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 25
    Log To Console    Pan details request api
    Log To Console    Test Case25: Entering client ref number more than 45 char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    24    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    chandraprakashDchandraprakashDchandraprakashDCC
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong

Test Case 26
    Log To Console    Pan details request api
    Log To Console    Test Case26: changing the 5th char of the pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    25    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BPXPX0239M
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ${EMPTY}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}    ${EMPTY}

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  103

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 27
    Log To Console    Pan details request api
    Log To Console    Test Case27: Verify by entering pan number in lower case char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    26    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BPXPV0239M
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    AMIT VINOD
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    AMIT
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    VINOD
    Should Be Equal As Strings  ${response.json()['result']['dob']}    14/03/1997

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 28
    Log To Console    Pan details request api
    Log To Console    Test Case28: Verify by entering e pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    27    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BQXPL8246B
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    NAMAGIRI LAKSHMANAN
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    NAMAGIRI
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    LAKSHMANAN
    Should Be Equal As Strings  ${response.json()['result']['dob']}    16/07/1940

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 29
    Log To Console    Pan details request api
    Log To Console    Test Case29: Verify by entering Entering Deleted pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    28    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AIUPI8924P
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ${EMPTY}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}    ${EMPTY}

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  102

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 30
    Log To Console    Pan details request api
    Log To Console    Test Case30: Verify by entering Entering Deactivated pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    29    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    LJKPK2266E
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ${EMPTY}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}    ${EMPTY}

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  102

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 31
    Log To Console    Pan details request api
    Log To Console    Test Case31: Verify by entering Entering Fake pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    30    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    DZLPD6077D
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    CHANDAN SATENDRANATH DAS
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    CHANDAN
    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     SATENDRANATH
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    DAS
    Should Be Equal As Strings  ${response.json()['result']['dob']}    13/03/1992

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 32
    Log To Console    Pan details request api
    Log To Console    Test Case32: Verify by entering Entering No Record Found pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    31    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    103
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    HAHPS7571R
    Should Be Equal As Strings  ${response.json()['result']['fullname']}     ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}     ${EMPTY}
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}     ${EMPTY}

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  103

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 33
    Log To Console    Pan details request api
    Log To Console    Test Case33: Verify by Entering Invalid (Regex) pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    32    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['error']}    Invalid ID number or combination of inputs

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 34
    Log To Console    Pan details request api
    Log To Console    Test Case34: Verify by entering Entering Valid (Different PAN Display Name) pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    33    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    NWNPS0264Q
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    NATTHANNAGARI SEETHARAMAIAH
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    NATTHANNAGARI
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SEETHARAMAIAH
    Should Be Equal As Strings  ${response.json()['result']['dob']}    01/01/1986

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 35
    Log To Console    Pan details request api
    Log To Console    Test Case35:Entering IT registered transgender pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    34    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    CVVPS3636N
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    SHAIKH SAVITHA
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    SHAIKH
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SAVITHA
    Should Be Equal As Strings  ${response.json()['result']['dob']}    23/07/1979

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 36
    Log To Console    Pan details request api
    Log To Console    Test Case36: Verify by Entering Non IT registered transgender pan number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    35    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    FYJPR1333F
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    KOLE RAGHAVI
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    KOLE
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    RAGHAVI
    Should Be Equal As Strings  ${response.json()['result']['dob']}    30/03/2002

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 37
    Log To Console    Pan details request api
    Log To Console    Test Case37: Verify by Aadhaar number present in both IT profile api and aadhaar link api
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    36    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    EDLPP4057C
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    GUNJANKUMAR PATEL
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    GUNJANKUMAR
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    PATEL
    Should Be Equal As Strings  ${response.json()['result']['dob']}    09/11/1997

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 38
    Log To Console    Pan details request api
    Log To Console    Test Case38 Verify by entering Aadhaar number not found in IT profile api and aadhaar link api
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    37    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    FHAPS9549N
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    ABHIJIT SADHUKHAN
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ABHIJIT
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SADHUKHAN
    Should Be Equal As Strings  ${response.json()['result']['dob']}    07/09/1995

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 39
    Log To Console    Pan details request api
    Log To Console    Test Case38: Verify by entering Aadhaar number not found in the IT profile and present in the aadhaar link api
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    38    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BMUPB7805B
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    RAJESHWARI YANKAPPA BARADDI
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    RAJESHWARI
    Should Be Equal As Strings  ${response.json()['result']['middle_name']}     YANKAPPA
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    BARADDI
    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/08/1990

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

#Test Case 40
#    Log To Console    Pan details request api
#    Log To Console    Test Case40: Entering the valid pan with valid name
#    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
#    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
#
#    # Read Test Data From CSV for Generate otp api file
#    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
#    ${row}=    Get From List    ${test_data}    39    # Select the first row
#
#    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
#    ${pan}=    Get From Dictionary    ${row}    pan
#    ${name}=    Get From Dictionary    ${row}    name
#    ${name_match_method}=    Get From Dictionary    ${row}    name_match_method
#
#    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=${name}     name_match_method=${name_match_method}
#    ${headers}=  Create Dictionary    Content-Type=application/json
#    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}
#
#    Log To Console    The request body input is : ${reqeust_api_input}
#    Log To Console    The response body output is :${response.content}
#
#    ${result_body}=    convert to string    ${response.content}
#    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings  ${response.json()['result_code']}    101
#    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
#    Should Not Be Empty  ${response.json()['request_id']}
#    Should Be Equal As Strings  ${response.json()['result']['pan']}    HYNPK0402G
#    Should Be Equal As Strings  ${response.json()['result']['fullname']}    PRADIP MANIBHAI KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['first_name']}    PRADIP
#    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     MANIBHAI
#    Should Be Equal As Strings  ${response.json()['result']['last_name']}    KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/11/1999
#
#    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
#    Log To Console    the reqeust_id is : ${transcation_id}
#
#
#    Log To Console    Pan details Status URL:
#    ${status_input}=  Create Dictionary    request_id=${transcation_id}
#
#    FOR    ${i}    IN RANGE    10
#        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
#        ${result1}=    Set Variable    ${status_response.json()['api_status']}
#
#        Log To Console    ${status_response.content}
#        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
#        Sleep    5s
#        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
#        Exit For Loop
#    END
#    Log To Console    ${EMPTY}
#    Log To Console    the status_response output is : ${status_response.content}
#
#
#    #Validations
#    ${result_body}=     Convert To String    ${status_response.content}
#    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
#    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
#    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
#
#    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
#    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
#    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
#    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

#Test Case 41
#    Log To Console    Pan details request api
#    Log To Console    Test Case41: Entering Name which not match to the pan number (fuzzy)
#    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
#    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
#
#    # Read Test Data From CSV for Generate otp api file
#    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
#    ${row}=    Get From List    ${test_data}    40    # Select the first row
#
#    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
#    ${pan}=    Get From Dictionary    ${row}    pan
#    ${name}=    Get From Dictionary    ${row}    name
#    ${name_match_method}=    Get From Dictionary    ${row}    name_match_method
#
#    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=${name}     name_match_method=${name_match_method}
#    ${headers}=  Create Dictionary    Content-Type=application/json
#    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}
#
#    Log To Console    The request body input is : ${reqeust_api_input}
#    Log To Console    The response body output is :${response.content}
#
#    ${result_body}=    convert to string    ${response.content}
#    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings  ${response.json()['result_code']}    101
#    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
#    Should Not Be Empty  ${response.json()['request_id']}
#    Should Be Equal As Strings  ${response.json()['result']['pan']}    HYNPK0402G
#    Should Be Equal As Strings  ${response.json()['result']['fullname']}    PRADIP MANIBHAI KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['first_name']}    PRADIP
#    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     MANIBHAI
#    Should Be Equal As Strings  ${response.json()['result']['last_name']}    KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/11/1999
#
#    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
#    Log To Console    the reqeust_id is : ${transcation_id}
#
#
#    Log To Console    Pan details Status URL:
#    ${status_input}=  Create Dictionary    request_id=${transcation_id}
#
#    FOR    ${i}    IN RANGE    10
#        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
#        ${result1}=    Set Variable    ${status_response.json()['api_status']}
#
#        Log To Console    ${status_response.content}
#        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
#        Sleep    5s
#        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
#        Exit For Loop
#    END
#    Log To Console    ${EMPTY}
#    Log To Console    the status_response output is : ${status_response.content}
#
#
#    #Validations
#    ${result_body}=     Convert To String    ${status_response.content}
#    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
#    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
#    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
#
#    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
#    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
#    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
#    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds
#
#Test Case 42
#    Log To Console    Pan details request api
#    Log To Console    Test Case42: Entering Name with space at each character (fuzzy)
#    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
#    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
#
#    # Read Test Data From CSV for Generate otp api file
#    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
#    ${row}=    Get From List    ${test_data}    41    # Select the first row
#
#    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
#    ${pan}=    Get From Dictionary    ${row}    pan
#    ${name}=    Get From Dictionary    ${row}    name
#    ${name_match_method}=    Get From Dictionary    ${row}    name_match_method
#
#    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=${name}     name_match_method=${name_match_method}
#    ${headers}=  Create Dictionary    Content-Type=application/json
#    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}
#
#    Log To Console    The request body input is : ${reqeust_api_input}
#    Log To Console    The response body output is :${response.content}
#
#    ${result_body}=    convert to string    ${response.content}
#    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings  ${response.json()['result_code']}    101
#    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
#    Should Not Be Empty  ${response.json()['request_id']}
#    Should Be Equal As Strings  ${response.json()['result']['pan']}    HYNPK0402G
#    Should Be Equal As Strings  ${response.json()['result']['fullname']}    PRADIP MANIBHAI KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['first_name']}    PRADIP
#    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     MANIBHAI
#    Should Be Equal As Strings  ${response.json()['result']['last_name']}    KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/11/1999
#
#    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
#    Log To Console    the reqeust_id is : ${transcation_id}
#
#
#    Log To Console    Pan details Status URL:
#    ${status_input}=  Create Dictionary    request_id=${transcation_id}
#
#    FOR    ${i}    IN RANGE    10
#        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
#        ${result1}=    Set Variable    ${status_response.json()['api_status']}
#
#        Log To Console    ${status_response.content}
#        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
#        Sleep    5s
#        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
#        Exit For Loop
#    END
#    Log To Console    ${EMPTY}
#    Log To Console    the status_response output is : ${status_response.content}
#
#
#    #Validations
#    ${result_body}=     Convert To String    ${status_response.content}
#    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
#    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
#    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
#
#    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
#    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
#    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
#    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds
#
#Test Case 43
#    Log To Console    Pan details request api
#    Log To Console    Test Case43: Entering last name middle name first name (Reverse order) (fuzzy)
#    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
#    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
#
#    # Read Test Data From CSV for Generate otp api file
#    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
#    ${row}=    Get From List    ${test_data}    42    # Select the first row
#
#    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
#    ${pan}=    Get From Dictionary    ${row}    pan
#    ${name}=    Get From Dictionary    ${row}    name
#    ${name_match_method}=    Get From Dictionary    ${row}    name_match_method
#
#    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=${name}     name_match_method=${name_match_method}
#    ${headers}=  Create Dictionary    Content-Type=application/json
#    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}
#
#    Log To Console    The request body input is : ${reqeust_api_input}
#    Log To Console    The response body output is :${response.content}
#
#    ${result_body}=    convert to string    ${response.content}
#    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings  ${response.json()['result_code']}    101
#    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
#    Should Not Be Empty  ${response.json()['request_id']}
#    Should Be Equal As Strings  ${response.json()['result']['pan']}    HYNPK0402G
#    Should Be Equal As Strings  ${response.json()['result']['fullname']}    PRADIP MANIBHAI KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['first_name']}    PRADIP
#    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     MANIBHAI
#    Should Be Equal As Strings  ${response.json()['result']['last_name']}    KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/11/1999
#
#    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
#    Log To Console    the reqeust_id is : ${transcation_id}
#
#
#    Log To Console    Pan details Status URL:
#    ${status_input}=  Create Dictionary    request_id=${transcation_id}
#
#    FOR    ${i}    IN RANGE    10
#        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
#        ${result1}=    Set Variable    ${status_response.json()['api_status']}
#
#        Log To Console    ${status_response.content}
#        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
#        Sleep    5s
#        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
#        Exit For Loop
#    END
#    Log To Console    ${EMPTY}
#    Log To Console    the status_response output is : ${status_response.content}
#
#
#    #Validations
#    ${result_body}=     Convert To String    ${status_response.content}
#    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
#    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
#    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
#
#    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
#    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
#    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
#    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds
#
#Test Case 44
#    Log To Console    Pan details request api
#    Log To Console    Test Case44: To verify by entering valid name (exact)
#    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
#    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
#
#    # Read Test Data From CSV for Generate otp api file
#    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
#    ${row}=    Get From List    ${test_data}    43    # Select the first row
#
#    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
#    ${pan}=    Get From Dictionary    ${row}    pan
#    ${name}=    Get From Dictionary    ${row}    name
#    ${name_match_method}=    Get From Dictionary    ${row}    name_match_method
#
#    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=${name}     name_match_method=${name_match_method}
#    ${headers}=  Create Dictionary    Content-Type=application/json
#    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}
#
#    Log To Console    The request body input is : ${reqeust_api_input}
#    Log To Console    The response body output is :${response.content}
#
#    ${result_body}=    convert to string    ${response.content}
#    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings  ${response.json()['result_code']}    101
#    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
#    Should Not Be Empty  ${response.json()['request_id']}
#    Should Be Equal As Strings  ${response.json()['result']['pan']}    HYNPK0402G
#    Should Be Equal As Strings  ${response.json()['result']['fullname']}    PRADIP MANIBHAI KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['first_name']}    PRADIP
#    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     MANIBHAI
#    Should Be Equal As Strings  ${response.json()['result']['last_name']}    KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/11/1999
#
#    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
#    Log To Console    the reqeust_id is : ${transcation_id}
#
#
#    Log To Console    Pan details Status URL:
#    ${status_input}=  Create Dictionary    request_id=${transcation_id}
#
#    FOR    ${i}    IN RANGE    10
#        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
#        ${result1}=    Set Variable    ${status_response.json()['api_status']}
#
#        Log To Console    ${status_response.content}
#        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
#        Sleep    5s
#        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
#        Exit For Loop
#    END
#    Log To Console    ${EMPTY}
#    Log To Console    the status_response output is : ${status_response.content}
#
#
#    #Validations
#    ${result_body}=     Convert To String    ${status_response.content}
#    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
#    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
#    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
#
#    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
#    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
#    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
#    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds
#
#Test Case 45
#    Log To Console    Pan details request api
#    Log To Console    Test Case45: To verify by entering valid name (dg_name_match)
#    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
#    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
#
#    # Read Test Data From CSV for Generate otp api file
#    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
#    ${row}=    Get From List    ${test_data}    44    # Select the first row
#
#    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
#    ${pan}=    Get From Dictionary    ${row}    pan
#    ${name}=    Get From Dictionary    ${row}    name
#    ${name_match_method}=    Get From Dictionary    ${row}    name_match_method
#
#    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=${name}     name_match_method=${name_match_method}
#    ${headers}=  Create Dictionary    Content-Type=application/json
#    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}
#
#    Log To Console    The request body input is : ${reqeust_api_input}
#    Log To Console    The response body output is :${response.content}
#
#    ${result_body}=    convert to string    ${response.content}
#    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings  ${response.json()['result_code']}    101
#    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
#    Should Not Be Empty  ${response.json()['request_id']}
#    Should Be Equal As Strings  ${response.json()['result']['pan']}    HYNPK0402G
#    Should Be Equal As Strings  ${response.json()['result']['fullname']}    PRADIP MANIBHAI KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['first_name']}    PRADIP
#    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     MANIBHAI
#    Should Be Equal As Strings  ${response.json()['result']['last_name']}    KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/11/1999
#
#    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
#    Log To Console    the reqeust_id is : ${transcation_id}
#
#
#    Log To Console    Pan details Status URL:
#    ${status_input}=  Create Dictionary    request_id=${transcation_id}
#
#    FOR    ${i}    IN RANGE    10
#        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
#        ${result1}=    Set Variable    ${status_response.json()['api_status']}
#
#        Log To Console    ${status_response.content}
#        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
#        Sleep    5s
#        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
#        Exit For Loop
#    END
#    Log To Console    ${EMPTY}
#    Log To Console    the status_response output is : ${status_response.content}
#
#
#    #Validations
#    ${result_body}=     Convert To String    ${status_response.content}
#    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
#    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
#    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
#
#    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
#    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
#    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
#    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds
#
#Test Case 46
#    Log To Console    Pan details request api
#    Log To Console    Test Case46: To verify by entering invalid name match method
#    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
#    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
#
#    # Read Test Data From CSV for Generate otp api file
#    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
#    ${row}=    Get From List    ${test_data}    45    # Select the first row
#
#    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
#    ${pan}=    Get From Dictionary    ${row}    pan
#    ${name}=    Get From Dictionary    ${row}    name
#    ${name_match_method}=    Get From Dictionary    ${row}    name_match_method
#
#    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=${name}     name_match_method=${name_match_method}
#    ${headers}=  Create Dictionary    Content-Type=application/json
#    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}
#
#    Log To Console    The request body input is : ${reqeust_api_input}
#    Log To Console    The response body output is :${response.content}
#
#    ${result_body}=    convert to string    ${response.content}
#    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
#    Should Be Equal As Strings  ${response.json()['result_code']}    101
#    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
#    Should Not Be Empty  ${response.json()['request_id']}
#    Should Be Equal As Strings  ${response.json()['result']['pan']}    HYNPK0402G
#    Should Be Equal As Strings  ${response.json()['result']['fullname']}    PRADIP MANIBHAI KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['first_name']}    PRADIP
#    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     MANIBHAI
#    Should Be Equal As Strings  ${response.json()['result']['last_name']}    KALARIYA
#    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/11/1999
#
#    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
#    Log To Console    the reqeust_id is : ${transcation_id}
#
#
#    Log To Console    Pan details Status URL:
#    ${status_input}=  Create Dictionary    request_id=${transcation_id}
#
#    FOR    ${i}    IN RANGE    10
#        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
#        ${result1}=    Set Variable    ${status_response.json()['api_status']}
#
#        Log To Console    ${status_response.content}
#        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
#        Sleep    5s
#        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
#        Exit For Loop
#    END
#    Log To Console    ${EMPTY}
#    Log To Console    the status_response output is : ${status_response.content}
#
#
#    #Validations
#    ${result_body}=     Convert To String    ${status_response.content}
#    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
#    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
#    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
#
#    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
#    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
#    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
#    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Enabling father name
    Log To Console    Test Case47: To verify by enabling the father name

    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[526526315047,740513625625015,740513625625006,740513625625007,7405136256250158]' WHERE (`id` = '4');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="4";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


Test Case 47
    Log To Console    Pan details request api
    Log To Console    Test Case47: To verify by entering Father name as true individual pan
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S


    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    46    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan
    ${father_name}=    Get From Dictionary    ${row}    father_name

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    FOBPS3262E
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    ABHISHEK KUMAR SHARMA
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ABHISHEK
    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     KUMAR
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SHARMA
    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/02/1995

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
    Should Not Be Empty        ${status_response.json()['request_id']}
    Should Be Equal As Strings    ${status_response.json()['api_status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['result']['pan']}  FOBPS3262E
    Should Be Equal As Strings    ${status_response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings    ${status_response.json()['result']['father_name']}  MAHESH SHARMA
    Should Be Equal As Strings    ${status_response.json()['result']['gender']}  male
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_number']}  XXXXXXXX3466
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings    ${status_response.json()['result']['address']['building_name']}  Room No. 8, Siddhi Vinayak Building
    Should Be Equal As Strings    ${status_response.json()['result']['address']['locality']}  Mumbai
    Should Be Equal As Strings    ${status_response.json()['result']['address']['street_name']}  Patil Gully, Versova Jetty Road
    Should Be Equal As Strings    ${status_response.json()['result']['address']['pincode']}  400061
    Should Be Equal As Strings    ${status_response.json()['result']['address']['city']}  MUMBAI
    Should Be Equal As Strings    ${status_response.json()['result']['address']['state']}  Maharashtra
    Should Be Equal As Strings    ${status_response.json()['result']['address']['country']}  India
    Should Be Equal As Strings    ${status_response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['email']}  ${EMPTY}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 48
    Log To Console    Pan details request api
    Log To Console    Test Case48: To verify by entering Father name as true non individual pan
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S


    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    47    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan
    ${father_name}=    Get From Dictionary    ${row}    father_name

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    AABFM2683G
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    CHANDRA AGENCY
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ${EMPTY}
    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    CHANDRA AGENCY
    Should Be Equal As Strings  ${response.json()['result']['dob']}    01/04/1997

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
    Should Not Be Empty        ${status_response.json()['request_id']}
    Should Be Equal As Strings    ${status_response.json()['api_status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['result']['pan']}  AABFM2683G
    Should Be Equal As Strings    ${status_response.json()['result']['pan_type']}  Firm/Limited Liability Partnership
    Should Be Equal As Strings    ${status_response.json()['result']['gender']}  None
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_linked']}  None
    Should Be Equal As Strings    ${status_response.json()['result']['address']['building_name']}  NO 177 A,UPSTAIR
    Should Be Equal As Strings    ${status_response.json()['result']['address']['locality']}  Madurai South
    Should Be Equal As Strings    ${status_response.json()['result']['address']['street_name']}  NORTH VELI STREET
    Should Be Equal As Strings    ${status_response.json()['result']['address']['pincode']}  625001
    Should Be Equal As Strings    ${status_response.json()['result']['address']['city']}  MADURAI
    Should Be Equal As Strings    ${status_response.json()['result']['address']['state']}  Tamil Nadu
    Should Be Equal As Strings    ${status_response.json()['result']['address']['country']}  India
    Should Be Equal As Strings    ${status_response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['email']}  ${EMPTY}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 49
    Log To Console    Pan details request api
    Log To Console    Test Case49: To verify by entering Father name as true for invalid pan
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S


    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    48    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan
    ${father_name}=    Get From Dictionary    ${row}    father_name

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    102
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    LJKPK2266E
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ${EMPTY}
    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    ${EMPTY}
    Should Be Equal As Strings  ${response.json()['result']['dob']}    ${EMPTY}

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  102
    Should Not Be Empty        ${status_response.json()['request_id']}
    Should Be Equal As Strings    ${status_response.json()['message']}  Invalid ID number or input combination
    Should Be Equal As Strings    ${status_response.json()['api_status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['result']['pan']}  LJKPK2266E
    Should Be Equal As Strings    ${status_response.json()['result']['pan_type']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['gender']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_number']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_linked']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['building_name']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['locality']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['street_name']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['pincode']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['city']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['state']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['address']['country']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['email']}  ${EMPTY}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Disabling father name
    Log To Console    Test Case47: To verify by disabling the father name

    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[526526315047,74051362562501,740513625625006,740513625625007,7405136256250158]' WHERE (`id` = '4');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="4";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END


Test Case 50
    Log To Console    Pan details request api
    Log To Console    Test Case50: To verify by entering Father name as false individual pan
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S


    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    49    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan
    ${father_name}=    Get From Dictionary    ${row}    father_name

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    FOBPS3262E
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    ABHISHEK KUMAR SHARMA
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    ABHISHEK
    Should Be Equal As Strings      ${response.json()['result']['middle_name']}     KUMAR
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    SHARMA
    Should Be Equal As Strings  ${response.json()['result']['dob']}    05/02/1995

    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${status_input}=  Create Dictionary    request_id=${transcation_id}

    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${Status_api}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['api_status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${status_response.json()['result_code']}  101
    Should Not Be Empty        ${status_response.json()['request_id']}
    Should Be Equal As Strings    ${status_response.json()['api_status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['result']['pan']}  FOBPS3262E
    Should Be Equal As Strings    ${status_response.json()['result']['pan_type']}  Individual
    Should Be Equal As Strings    ${status_response.json()['result']['gender']}  male
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_number']}  XXXXXXXX3466
    Should Be Equal As Strings    ${status_response.json()['result']['aadhaar_linked']}  True
    Should Be Equal As Strings    ${status_response.json()['result']['address']['building_name']}  Room No. 8, Siddhi Vinayak Building
    Should Be Equal As Strings    ${status_response.json()['result']['address']['locality']}  Mumbai
    Should Be Equal As Strings    ${status_response.json()['result']['address']['street_name']}  Patil Gully, Versova Jetty Road
    Should Be Equal As Strings    ${status_response.json()['result']['address']['pincode']}  400061
    Should Be Equal As Strings    ${status_response.json()['result']['address']['city']}  MUMBAI
    Should Be Equal As Strings    ${status_response.json()['result']['address']['state']}  Maharashtra
    Should Be Equal As Strings    ${status_response.json()['result']['address']['country']}  India
    Should Be Equal As Strings    ${status_response.json()['result']['mobile']}  ${EMPTY}
    Should Be Equal As Strings    ${status_response.json()['result']['email']}  ${EMPTY}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 51
    Log To Console    Pan details request api
    Log To Console    Test Case51: Entering the one authorization in request endpoint and another authorization in status endpoint
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth1}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession1    ${base_url}   auth=${auth1}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession1   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}
    Should Be Equal As Strings  ${response.json()['result']['pan']}    BPXPV0239M
    Should Be Equal As Strings  ${response.json()['result']['fullname']}    AMIT VINOD
    Should Be Equal As Strings  ${response.json()['result']['first_name']}    AMIT
    Should Be Empty      ${response.json()['result']['middle_name']}
    Should Be Equal As Strings  ${response.json()['result']['last_name']}    VINOD
    Should Be Equal As Strings  ${response.json()['result']['dob']}    14/03/1997



    ${transcation_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the reqeust_id is : ${transcation_id}


    Log To Console    Pan details Status URL:
    ${auth_1}=  Create List    740513625625016    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    SubmitSession    ${base_url}   auth=${auth_1}   verify=True
    ${status_input}=  Create Dictionary    request_id=${transcation_id}
    ${status_response}=  Post Request    SubmitSession   ${Status_api}  json=${status_input}  headers=${headers}

    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}


    #Validations
    ${result_body}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  401
    Should Not Be Empty        ${status_response.json()['request_id']}
    Should Be Equal As Strings    ${status_response.json()['error']}  Unauthorized Access.

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 52
    Log To Console    Pan details request api
    Log To Console    Test Case52: Entering the authorization who doesn't have pan details V4 access
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth1}=  Create List    74051362562501    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession1    ${base_url}   auth=${auth1}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession1   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 53
    Log To Console    Pan details request api
    Log To Console    Test Case53: Entering the invalid client user name
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth1}=  Create List    7405136256#$&%    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession1    ${base_url}   auth=${auth1}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession1   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 54
    Log To Console    Pan details request api
    Log To Console    Test Case54: Entering the invalid client password
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth1}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRC!#%%
    Create Session    myrequestsession1    ${base_url}   auth=${auth1}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession1   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 55
    Log To Console    Pan details request api
    Log To Console    Test Case55: Verify by leaving password as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth1}=  Create List    740513625625015    ${EMPTY}
    Create Session    myrequestsession1    ${base_url}   auth=${auth1}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession1   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 56
    Log To Console    Pan details request api
    Log To Console    Test Case56: Verify by leaving user name as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth1}=  Create List    ${EMPTY}    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession1    ${base_url}   auth=${auth1}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession1   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 57
    Log To Console    Pan details request api
    Log To Console    Test Case57: Verify by leaving both the user name and password as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth1}=  Create List    ${EMPTY}    ${EMPTY}
    Create Session    myrequestsession1    ${base_url}   auth=${auth1}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    0    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession1   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Client Authentication Failed
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 58
    Log To Console    Pan details request api
    Log To Console    Test Case58: To verify by entering Father name key in the input
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S


    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    46    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan
    ${father_name}=    Get From Dictionary    ${row}    father_name

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     father_name=${father_name}
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 59
    Log To Console    Pan details request api
    Log To Console    Test Case59: To verify by entering Name key in the input
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S


    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    46    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan
    ${father_name}=    Get From Dictionary    ${row}    father_name

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     name=ABHISHEK
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}



    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 60
    Log To Console    Pan details request api
    Log To Console    Test Case60: To verify by entering callback url key in the input
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S


    ${auth}=  Create List    740513625625015    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    # Read Test Data From CSV for Generate otp api file
    ${test_data}=    Read Test Data From CSV for Generate otp api    ${file_path}
    ${row}=    Get From List    ${test_data}    46    # Select the first row

    ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num
    ${pan}=    Get From Dictionary    ${row}    pan
    ${father_name}=    Get From Dictionary    ${row}    father_name

    ${reqeust_api_input}=  create dictionary    client_ref_num=${client_ref_num}   pan=${pan}     callback_url=https://typedwebhook.tools/webhook/3151e0fc-2c10-40a6-8cfe-da64543f4e00
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}



    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Enabling back father name
    Log To Console    Test Case47: To verify by enabling the father name

    ${update_output}=    Execute SQL String    UPDATE `validation`.`validation_service_config` SET `value` = '[526526315047,740513625625015,740513625625006,740513625625007,7405136256250158]' WHERE (`id` = '4');


    Log To Console    ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT value FROM validation.validation_service_config where id="4";
    FOR    ${row}    IN    @{query_result1}
        Log To Console    vendor_list = ${row[0]}
    END