*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    urllib3
Library    DateTime
Library    DatabaseLibrary

Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Disconnect From Database

*** Variables ***
${DBName}   validation
${DBUser}   qa.chandraprakash.d
${DBPass}   KrG3yfPY
${DBHost}   digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
${cmd_mobile_request_url}=    /dp/mobile_check/v1/request
${cmd_mobile_status_url}=    /dp/mobile_check/v1/status
${cmd_Account_request_url}=    /dp/account_check/v1/request
${cmd_Account_status_url}=    /dp/account_check/v1/status
${cmd_email_request_url}=    /dp/email_check/v1/request
${cmd_email_status_url}=    /dp/email_check/v1/status
${Encrypted_test_data} =   eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2R0NNIn0.Bt-jVSY9B4zmIH_itzeHLF89_9uno4RkbYkHcOz97YiT771pkThTUWHnCwszM1a_t6_ithah5o1r4szcdd4-F_asaVykxgSXdWXaKXcr4_Z1i4qO4y0SNyw5x-IncxjaK4hQLUGAz7vAjGVjVAZMzyDaltOEzJdmXKTRag5baV0.EkYX4jWFlHjQ5NhX.vU40pSv0dHVR5VjY2mACZ4GRvHoiJEJVqpLTn6SZnosenM-SL98fjH0HrDlKogl5XCUfjxf5dGOVKTzjAjXHZzMcZGJ0AV4GSa53FlsEaY9QSoi3hbr89WRjSjwUsToQf51Q7xLeCsJwwRZVIAqmUI6ozC86Scb3YGl83wO9u9_RGdntGcUxYg.5E8K4MBVTxy6AnUzj1aUX

*** Test Cases ***
# -------------------- Mobile FLow ------------------------------------#
Test Case 01
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=paytm,amazon,flipkart
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    2s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 02
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590319   requested_services=paytm,amazon,flipkart
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    2s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 03
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590310   requested_services=paytm,amazon,flipkart
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    2s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 04
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590311   requested_services=paytm,amazon,flipkart
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    2s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds
    
    
Test Case 05
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid emailID
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail.com   requested_services=paytm,amazon,flipkart
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_email_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    2s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_email_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 06
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid emailID
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    email=chandraprakashcr8@gmail.com   requested_services=paytm,amazon,flipkart
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_email_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    2s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_email_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 07
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid emailID
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    email=chandraprakashcr9@gmail.com   requested_services=paytm,amazon,flipkart
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_email_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    2s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_email_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 5 secs
        Sleep    5s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  Vampire
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds