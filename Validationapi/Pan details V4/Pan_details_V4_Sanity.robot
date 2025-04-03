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
Library    allure_robotframework

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

    ${reqeust_api_input}=  create dictionary    client_ref_num=Vampire   pan=AKXPY8253A
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

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

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 2
    Log To Console    Pan details request api
    Log To Console    Test Case1: Entering the purging request
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    740513625625016    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True

    ${reqeust_api_input}=  create dictionary    client_ref_num=Vampire   pan=AWQPK3219B
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${Reqeust_api}   json=${reqeust_api_input}   headers=${headers}

    Log To Console    The request body input is : ${reqeust_api_input}
    Log To Console    The response body output is :${response.content}

    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    200
    Should Be Equal As Strings  ${response.json()['result_code']}    101
    Should Be Equal As Strings  ${response.json()['client_ref_num']}    Vampire
    Should Not Be Empty  ${response.json()['request_id']}

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

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds