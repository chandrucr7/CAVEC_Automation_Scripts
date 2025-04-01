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
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    7s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case2
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by entering in-valid mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=90590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case3
    Log To Console    CMD Request URL
    Log To Console    Test case 3: Verify by leaving mobile as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=${EMPTY}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case4
    Log To Console    CMD Request URL
    Log To Console    Test case 4: Verify by giving mobile as empty space
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=${SPACE}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case5
    Log To Console    CMD Request URL
    Log To Console    Test case 5: Verify by entering mobile as alpha char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=QWERTYUIOP   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case6
    Log To Console    CMD Request URL
    Log To Console    Test case 6: Verify by entering mobile as special char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=!@#$%^&*()   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case7
    Log To Console    CMD Request URL
    Log To Console    Test case 7: Verify by entering mobile mixed with alpha and numbers
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=QWERT1234   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case8
    Log To Console    CMD Request URL
    Log To Console    Test case 8: Verify by entering mobile mixed with special and numbers

    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=1234!@#$%^   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case9
    Log To Console    CMD Request URL
    Log To Console    Test case 9: Verify by entering mobile mixed with num & special char & alphas
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=QWE979!@#$   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case10
    Log To Console    CMD Request URL
    Log To Console    Test case 10: Verify by giving empty space inbetween mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=97905 90318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case11
    Log To Console    CMD Request URL
    Log To Console    Test case 11: Verify by entering mobile number as 0000000000
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=0000000000   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case12
    Log To Console    CMD Request URL
    Log To Console    Test case 12: Verify by entering mobile number as 1111111111
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=1111111111   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case13
    Log To Console    CMD Request URL
    Log To Console    Test case 13: Verify by entering mobile number as 1234567890
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=1234567890   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case14
    Log To Console    CMD Request URL
    Log To Console    Test case 14: Verify by entering mobile number starting from 0
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=0790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case15
    Log To Console    CMD Request URL
    Log To Console    Test case 15: Verify by entering mobile number starting from 1
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=1790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case16
    Log To Console    CMD Request URL
    Log To Console    Test case 16: Verify by entering mobile number starting from 2
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=2790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case17
    Log To Console    CMD Request URL
    Log To Console    Test case 17: Verify by entering mobile number starting from 3
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=3790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case18
    Log To Console    CMD Request URL
    Log To Console    Test case 18: Verify by entering mobile number starting from 4
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=4790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case19
    Log To Console    CMD Request URL
    Log To Console    Test case 19: Verify by entering mobile number starting from 5
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=5790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 20
    Log To Console    CMD Request URL
    Log To Console    Test case 20: Verify by entering mobile number starting from 6
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=6790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}
    Sleep    4s
    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  6790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 21
    Log To Console    CMD Request URL
    Log To Console    Test case 21: Verify by entering mobile number starting from 91
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=919790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  919790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 22
    Log To Console    CMD Request URL
    Log To Console    Test case 22: Verify by entering mobile number starting from +91
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=+919790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  +919790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 23
    Log To Console    CMD Request URL
    Log To Console    Test case 24: Verify by entering mobile number starting from 09790590318
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=09790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep   20s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  09790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 24
    Log To Console    CMD Request URL
    Log To Console    Test case 24: Verify by entering foreign mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=+447850226627   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case25
    Log To Console    CMD Request URL
    Log To Console    Test case 25: Verify by entering mobile number starting from !91
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=!919790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case26
    Log To Console    CMD Request URL
    Log To Console    Test case 26: Verify by entering mobile number starting from @91
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=@919790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case27
    Log To Console    CMD Request URL
    Log To Console    Test case 27: Verify by entering mobile number starting from %91
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=%919790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case28
    Log To Console    CMD Request URL
    Log To Console    Test case 28: Verify by entering mobile number starting from &91
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=&919790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case29
    Log To Console    CMD Request URL
    Log To Console    Test case 29: Verify by entering mobile number starting from $91
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=$919790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case30
    Log To Console    CMD Request URL
    Log To Console    Test case 30: Verify by entering email instead of mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=chandraprakashcr7@gmail.com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case31
    Log To Console    CMD Request URL
    Log To Console    Test case 31: Verify by giving space infront of mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=${SPACE}9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case32
    Log To Console    CMD Request URL
    Log To Console    Test case 32: Verify by giving space at end of mobile number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318${SPACE}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


# -------------------- Email FLow ------------------------------------#

Test Case 33
    Log To Console    CMD Request URL
    Log To Console    Test Case33: Verify by entering valid email id
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail.com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_email_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_email_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['email']}  chandraprakashcr7@gmail.com
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case34
    Log To Console    CMD Request URL
    Log To Console    Test case 34: Verify by entering in-valid email id without @ in it
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7gmail.com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case35
    Log To Console    CMD Request URL
    Log To Console    Test case 35: Verify by entering in-valid email id without dot in it
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmailcom   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case36
    Log To Console    CMD Request URL
    Log To Console    Test case 36: Verify by entering in-valid email id by adding comma in it
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail,com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case37
    Log To Console    CMD Request URL
    Log To Console    Test case 37: verify by leaving the email id as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=${EMPTY}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case38
    Log To Console    CMD Request URL
    Log To Console    Test case 38: verify by giving empty space in the email
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=${SPACE}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case39
    Log To Console    CMD Request URL
    Log To Console    Test case 39: verify by giving empty space instead of @ in the email
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7${SPACE}gmail.com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case40
    Log To Console    CMD Request URL
    Log To Console    Test case 40: verify by giving empty space instead of dot in the email
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail${SPACE}com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case41
    Log To Console    CMD Request URL
    Log To Console    Test case 41: verify by giving empty space instead of dot and @ in the email
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7${SPACE}gmail${SPACE}com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test_case42
    Log To Console    CMD Request URL
    Log To Console    Test case 42: verify by entering mobile number instead of email
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 43
    Log To Console    CMD Request URL
    Log To Console    Test Case43: Verify by entering mobile and email together
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    email=9790590318@gmail.com   requested_services=whatsapp,paytm
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_email_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_email_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['email']}  9790590318@gmail.com
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

#--------------------Email and mobile at same time------------------------#

Test_case44
    Log To Console    CMD Request URL
    Log To Console    Test case 44: verify by entering valid mobile number and email at same time
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail.com    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case45
    Log To Console    CMD Request URL
    Log To Console    Test case 45: verify by entering invalid mobile number and valid email at same time
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail.com    mobile=90590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case46
    Log To Console    CMD Request URL
    Log To Console    Test case 46: verify by entering valid mobile number and invalid email at same time
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7gmail.com    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case47
    Log To Console    CMD Request URL
    Log To Console    Test case 47: verify by entering invalid mobile number and invalid email at same time
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail.com    mobile=90590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case48
    Log To Console    CMD Request URL
    Log To Console    Test case 48: verify by entering leaving mobile number as empty and valid email at same time
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr@7gmail.com    mobile=${EMPTY}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case49
    Log To Console    CMD Request URL
    Log To Console    Test case 48: verify by entering leaving email as empty and valid mobile at same timme
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=${EMPTY}    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case50
    Log To Console    CMD Request URL
    Log To Console    Test case 49: verify by entering leaving email and mobile as empty at same timme
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=${EMPTY}    mobile=${EMPTY}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case51
    Log To Console    CMD Request URL
    Log To Console    Test case 50: verify by entering leaving email and mobile as empty space at same timme
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=${SPACE}    mobile=${SPACE}   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

#-------------client ref number ----------------------#

Test Case 52
    Log To Console    CMD Request URL
    Log To Console    Test Case51: Verify by entering valid client ref number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case53
    Log To Console    CMD Request URL
    Log To Console    Test Case52: Verify by entering in-valid client ref number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=!@#$%    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case54
    Log To Console    CMD Request URL
    Log To Console    Test Case53: Verify by entering leaving client ref number as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=${EMPTY}    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case55
    Log To Console    CMD Request URL
    Log To Console    Test Case54: Verify by entering leaving client ref number as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=${SPACE}    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 56
    Log To Console    CMD Request URL
    Log To Console    Test Case55: Verify by entering client ref number as 45 char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=chandraprakashDchandraprakashDchandraprakashD    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
        Run Keyword If    '${result1}' == 'In-Progress'   Continue For Loop
        Exit For Loop
    END
    Log To Console    ${EMPTY}
    Log To Console    the status_response output is : ${status_response.content}

    #Validations
    ${status_response_results}=     Convert To String    ${status_response.content}
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  200
    Should Be Equal As Strings    ${status_response.json()['message']}  Success
    Should Be Equal As Strings    ${status_response.json()['client_ref_num']}  chandraprakashDchandraprakashDchandraprakashD
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case57
    Log To Console    CMD Request URL
    Log To Console    Test Case56: Verify by entering client ref number more than 45 char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=chandraprakashDchandraprakashDchandraprakashDD    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test_cas58
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space at middle of client ref number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":"Vamp ire", "mobile":"9790590318", "requested_services": "whatsapp,paytm,amazon" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_cas59
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space at end of client ref number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":"Vampire ", "mobile":"9790590318", "requested_services": "whatsapp,paytm,amazon" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_cas60
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space in front of client ref number
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":" Vampire", "mobile":"9790590318", "requested_services": "whatsapp,paytm,amazon" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

#-----------------Requested service------------------------#

Test Case 61
    Log To Console    CMD Request URL
    Log To Console    Test Case57: Verify by entering valid requested service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case62
    Log To Console    CMD Request URL
    Log To Console    Test Case58: Verify by entering in-valid requested service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=amazona,flipkart,paytm,facebook,instagram,twitter,whatsapp
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    402
    Should Be Equal As Strings  ${response.json()['message']}    Unknown Service Requested
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case63
    Log To Console    CMD Request URL
    Log To Console    Test Case59: Verify by entering duplicate service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=amazon,amazon,paytm,instagram,twitter,whatsapp
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    422
    Should Be Equal As Strings  ${response.json()['message']}    Duplicate Service Requested
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case64
    Log To Console    CMD Request URL
    Log To Console    Test Case60: Verify by entering unknown service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=amazon,gpay,paytm,instagram,twitter,whatsapp
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    402
    Should Be Equal As Strings  ${response.json()['message']}    Unknown Service Requested
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 65
    Log To Console    CMD Request URL
    Log To Console    Test Case61: Verify by entering services in upper case all char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=WHATSAPP,PAYTM,AMAZON,FLIPKART,FACEBOOK,TWITTER,INSTAGRAM,APPLE,LINKEDIN
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    ${request_body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 66
    Log To Console    CMD Request URL
    Log To Console    Test Case61: Verify by entering services in upper case first char
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=Whatsapp,Paytm,Amazon,Flipkart,Facebook,Twitter,Instagram,Apple,Linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    ${request_body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 67
    Log To Console    CMD Request URL
    Log To Console    Test Case61: Verify by entering services in upper case at any char of the service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whAtsapp
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    ${request_body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_cas68
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space infront of the overall service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":"Vampire", "mobile":"9790590318", "requested_services": " whatsapp,paytm,amazon" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_cas69
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space end the single service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":"Vampire", "mobile":"9790590318", "requested_services": "whatsapp ,paytm,amazon" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_cas70
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space front and end the separate service
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":"Vampire", "mobile":"9790590318", "requested_services": " whatsapp ,paytm,amazon" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_cas71
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space front and end at all services
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":"Vampire", "mobile":"9790590318", "requested_services": " whatsapp , paytm , amazon " }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_cas72
    Log To Console    CMD Request URL
    Log To Console    Test Case2: Verify by giving space middle of any one of the serive
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=   Evaluate    { "client_ref_num":"Vampire", "mobile":"9790590318", "requested_services": "whatsapp,pay tm,amazon" }
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case73
    Log To Console    CMD Request URL
    Log To Console    Test Case59: Verify by entering services as empty
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=${EMPTY}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case74
    Log To Console    CMD Request URL
    Log To Console    Test Case59: Verify by entering services as empty space
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=${SPACE}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

#-----------End point changes------------------#

Test_case75
    Log To Console    CMD Request URL
    Log To Console    Test Case63: Verify by entering mobile endpoint for email flow
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail.com   requested_services=amazon,paytm,facebook,instagram,twitter,whatsapp,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test_case76
    Log To Console    CMD Request URL
    Log To Console    Test Case63: Verify by entering email endpoint for mobile number flow
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    create list    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=amazon,Gpay,paytm,facebook,instagram,twitter,whatsapp,linkedin
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_email_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 77
    Log To Console    CMD Request URL
    Log To Console    Test Case65: Verify by entering wrong endpoint in status endpoint
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    ${status_response}=  Post Request    myrequestsession   ${cmd_email_status_url}  json=${status_input}  headers=${headers}

    Log To Console    the status_response output is : ${status_response.content}

    # Validations
    Should Be Equal As Strings    ${status_response.json()['http_response_code']}  406
    Should Be Equal As Strings    ${status_response.json()['message']}  Wrong Request ID for this Endpoint
    Should Be Equal As Strings    ${status_response.json()['status']}  Error

    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    # ${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the request is : ${elapsed_time} seconds

Test Case 78
    Log To Console    CMD Request URL
    Log To Console    Test Case1: Verify by entering valid mobile number in account check endpoint
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_Account_request_url}   json=${request_bod y}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_Account_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 79
    Log To Console    CMD Request URL
    Log To Console    Test Case33: Verify by entering valid email id in account check endpoint
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${request_body}=  create dictionary    client_ref_num=Vampire    email=chandraprakashcr7@gmail.com   requested_services=whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_Account_request_url}   json=${request_body}   headers=${headers}

    Log To Console    The request body input is : ${request_body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
         ${status_response}=  Post Request    myrequestsession   ${cmd_Account_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}
        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['email']}  chandraprakashcr7@gmail.com
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case80
    log to console  Verify by hitting the 200 response code with JWE format

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '1' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    #------------------------------------------ Request endpoint encryption-----------------------------------------------
    ${encrypt_body}=   Evaluate    { "plain_payload": { "mobile": "9790590318", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}

    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    #CAD Endpoint ---------------------------------------------------------
    Log To Console    Calling CAD mobile check request endpoint...

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    CAD Link Request Body: ${pan_aadhaar_body}

    ${CAD_Request_Response}=    Post Request     mysession     /dp/account_check/v1/request   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    CAD Link Response Status: ${CAD_Request_Response.status_code}
    Log To Console    CAD Response Content: ${CAD_Request_Response.content}

    ${encrypted_data_output}=  Set Variable    ${CAD_Request_Response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    #Decrypt Endpoint -------------------------------------------------------------------
    Log To Console    Calling Decryption Endpoint...

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    Should Be Equal As Strings  ${decrypt_response.status_code}    200

    ${encrypted_data_output1}=  Set Variable    ${decrypt_response.json()['plain_response']['request_id']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output1}

    #------------------------------------------ Status endpoint encryption-----------------------------------------------
    ${encrypt_body}=   Evaluate    { "plain_payload": { "request_id": "${encrypted_data_output1}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}

    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input1}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input1}

    Sleep    4s
    #CAD Endpoint ---------------------------------------------------------
    Log To Console    Calling CAD mobile check request endpoint...

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input1}
    Log To Console    CAD Link Request Body: ${pan_aadhaar_body}

    ${CAD_Request_Response}=    Post Request     mysession     /dp/account_check/v1/status   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    CAD Link Response Status: ${CAD_Request_Response.status_code}
    Log To Console    CAD Response Content: ${CAD_Request_Response.content}

    ${encrypted_data_output}=  Set Variable    ${CAD_Request_Response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    #Decrypt Endpoint -------------------------------------------------------------------
    Log To Console    Calling Decryption Endpoint...

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    Should Be Equal As Strings  ${decrypt_response.status_code}    200


Test_case81
    log to console  Verify by hitting the 402 unknown service requested response code with JWE format with JSON format

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '1' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    #------------------------------------------ Request endpoint encryption-----------------------------------------------
    ${encrypt_body}=   Evaluate    { "plain_payload": { "mobile": "9790590318", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,link", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}

    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    #CAD Endpoint ---------------------------------------------------------
    Log To Console    Calling CAD mobile check request endpoint...

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    CAD Link Request Body: ${pan_aadhaar_body}

    ${CAD_Request_Response}=    Post Request     mysession     /dp/account_check/v1/request   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    CAD Link Response Status: ${CAD_Request_Response.status_code}
    Log To Console    CAD Response Content: ${CAD_Request_Response.content}

    ${encrypted_data_output}=  Set Variable    ${CAD_Request_Response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    #Decrypt Endpoint -------------------------------------------------------------------
    Log To Console    Calling Decryption Endpoint...

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    Should Be Equal As Strings  ${decrypt_response.status_code}    200

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Not Be Empty      ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    402
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['message']}    Unknown Service Requested

Test_case82
    log to console  Verify by hitting the 422 duplicate service requested response code with JWE format

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '1' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    #------------------------------------------ Request endpoint encryption-----------------------------------------------
    ${encrypt_body}=   Evaluate    { "plain_payload": { "mobile": "9790590318", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,whatsapp", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}

    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    #CAD Endpoint ---------------------------------------------------------
    Log To Console    Calling CAD mobile check request endpoint...

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    CAD Link Request Body: ${pan_aadhaar_body}

    ${CAD_Request_Response}=    Post Request     mysession     /dp/account_check/v1/request   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    CAD Link Response Status: ${CAD_Request_Response.status_code}
    Log To Console    CAD Response Content: ${CAD_Request_Response.content}

    ${encrypted_data_output}=  Set Variable    ${CAD_Request_Response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    #Decrypt Endpoint -------------------------------------------------------------------
    Log To Console    Calling Decryption Endpoint...

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    Should Be Equal As Strings  ${decrypt_response.status_code}    200

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Not Be Empty      ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    422
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['message']}    Duplicate Service Requested

Test_case83
    log to console  Verify by hitting the 400 response in jwe format

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '1' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    #------------------------------------------ Request endpoint encryption-----------------------------------------------
    ${encrypt_body}=   Evaluate    { "plain_payload": { "mobile": "", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}

    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    #CAD Endpoint ---------------------------------------------------------
    Log To Console    Calling CAD mobile check request endpoint...

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    CAD Link Request Body: ${pan_aadhaar_body}

    ${CAD_Request_Response}=    Post Request     mysession     /dp/account_check/v1/request   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    CAD Link Response Status: ${CAD_Request_Response.status_code}
    Log To Console    CAD Response Content: ${CAD_Request_Response.content}

    ${encrypted_data_output}=  Set Variable    ${CAD_Request_Response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

    #Decrypt Endpoint -------------------------------------------------------------------
    Log To Console    Calling Decryption Endpoint...

    ${decrypt_body}=   Evaluate    { "encrypted_response": "${encrypted_data_output}", "secret_name": "cavec_test_suite_secrets", "secret_key": "740513625625006_private", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    Log To Console    Decrypt Request Body: ${decrypt_body}

    ${decrypt_response}=    Post Request     mysession     /validation/v1/decrypt   json=${decrypt_body}    headers=${headers}
    Log To Console    Decrypt Response Status: ${decrypt_response.status_code}
    Log To Console    Decrypt Response Content: ${decrypt_response.content}

    Should Be Equal As Strings  ${decrypt_response.status_code}    200

    Should Be Equal As Strings  ${decrypt_response.json()['https_response_code']}    200
    Should Not Be Empty      ${decrypt_response.json()['request_id']}
    Should Be Equal As Strings  ${decrypt_response.json()['message']}    Successfully Decrypted!
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['http_response_code']}    400
    Should Be Equal As Strings  ${decrypt_response.json()['plain_response']['error']}    One or more parameters format is wrong

Test_case84
    log to console  Verify by hitting jwe request when jwe encryption disabled

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '0' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    encrypted_data=${Encrypted_test_data}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case85
    log to console  Verify by hitting normal request when jwe encryption disabled but enabled in KMS

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '0' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whatsapp,paytm,amazon
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case86
    log to console  Verify by hitting empty JWE encrypted data

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '1' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    encrypted_data=${EMPTY}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Invalid Encryption
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test_case87
    log to console  Verify by hitting Invalid JWE encrypted data

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '1' WHERE (`id` = '5');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="5";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    Create List    740513625625006    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    encrypted_data=${Encrypted_test_data}
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_Account_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    401
    Should Be Equal As Strings  ${response.json()['error']}    Invalid Encryption
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test_case88
    log to console  Verify by hitting the encrypted request with jwe enabled but disabled in KMS manager

    ${update_output}=    Execute SQL String    UPDATE `dg_cmd_stage`.`cmd_client` SET `is_jwe_enabled` = '1' WHERE (`id` = '1');
    Log To Console    SQL Update Output: ${update_output}
    Should Be Equal As Strings    ${update_output}    None

    ${query_result1}=    Query    SELECT is_jwe_enabled FROM dg_cmd_stage.cmd_client WHERE id="1";
    FOR    ${row}    IN    @{query_result1}
        Log To Console   CAD_JWE = ${row[0]}
    END

    ${auth}=    Create List    70288539    c0LXWi1lUGWv8bvSno0jRKzmiMloLAot
    Create Session    mysession    ${base_url}    auth=${auth}    verify=true
    ${random_client_ref_num}=    Generate Random String    10    [LETTERS]

    #------------------------------------------ Request endpoint encryption-----------------------------------------------
    ${encrypt_body}=   Evaluate    { "plain_payload": { "mobile": "", "requested_services": "whatsapp,paytm,amazon", "client_ref_num": "${random_client_ref_num}" }, "secret_name": "cavec_test_suite_secrets", "secret_key": "digitap_public", "kms_id": "effe95b1-f8c6-48c5-8fa3-ea135d5eafb6", "encryption_type": "jwe" }
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log To Console    Encrypt Request Body: ${encrypt_body}

    ${encrypt_response}=    Post Request     mysession     /validation/v1/encrypt   json=${encrypt_body}    headers=${headers}
    Log To Console    Encrypt Response Status: ${encrypt_response.status_code}
    Log To Console    Encrypt Response Content: ${encrypt_response.content}

    Should Be Equal As Strings  ${encrypt_response.json()['https_response_code']}    200
    Should Be Equal As Strings  ${encrypt_response.json()['message']}    Successfully Encrypted!

    ${encrypted_input}=  Set Variable    ${encrypt_response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data: ${encrypted_input}

    #CAD Endpoint ---------------------------------------------------------
    Log To Console    Calling CAD mobile check request endpoint...

    ${pan_aadhaar_body}=  Create Dictionary    encrypted_data=${encrypted_input}
    Log To Console    CAD Link Request Body: ${pan_aadhaar_body}

    ${CAD_Request_Response}=    Post Request     mysession     /dp/account_check/v1/request   json=${pan_aadhaar_body}    headers=${headers}
    Log To Console    CAD Link Response Status: ${CAD_Request_Response.status_code}
    Log To Console    CAD Response Content: ${CAD_Request_Response.content}

    ${encrypted_data_output}=  Set Variable    ${CAD_Request_Response.json()['encrypted_data']}
    Log To Console    Extracted Encrypted Data Output: ${encrypted_data_output}

Test_case89
    log to console  Verify by hitting the normal request with jwe enabled but disabled in KMS manager


    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=    Create List    70288539    c0LXWi1lUGWv8bvSno0jRKzmiMloLAot
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    ${body}=    create dictionary    client_ref_num=Vampire    mobile=9790590318   requested_services=whatsapp,paytm,amazon
    ${header}=    create dictionary    Content-Type=application/json
    ${response}=    Post Request     mysession     ${cmd_mobile_request_url}   json=${body}    headers=${header}
    Log To Console    ${body}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    # Validations
    ${result_body}=    convert to string    ${response.content}
    Should Be Equal As Strings  ${response.json()['http_response_code']}    400
    Should Be Equal As Strings  ${response.json()['error']}    One or more parameters format is wrong
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 90
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as true
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": True }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    Should Not Be Empty        ${status_response.json()['model']['score']}
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 91
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as false
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": False }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 92
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as string true
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": "true" }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    Should Be Equal As Strings    ${response.json()['http_response_code']}  400
    Should Be Equal As Strings    ${response.json()['client_ref_num']}  Vampire
    Should Be Equal As Strings    ${response.json()['error']}  One or more parameters format is wrong


    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds

Test Case 93
    Log To Console    CMD Status URL
    Log To Console    Verify by entering unknown request id
Test Case 91
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as false
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": False }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 94
    Log To Console    CMD Status URL
    Log To Console    Verify by entering empty request id
Test Case 91
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as false
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": False }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 95
    Log To Console    CMD Status URL
    Log To Console    Verify by entering empty space request id
Test Case 91
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as false
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": False }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 96
    Log To Console    CMD Status URL
    Log To Console    Verify by entering empty space end of request id
Test Case 91
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as false
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": False }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 97
    Log To Console    CMD Status URL
    Log To Console    Verify by entering empty space front of request id
Test Case 91
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as false
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": False }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds


Test Case 98
    Log To Console    CMD Status URL
    Log To Console    Verify by entering empty space front and end of request id
Test Case 91
    Log To Console    CMD Request URL
    Log To Console    Verify by entering generate score as false
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${auth}=  Create List    5265263150471    EA6F34B4B3B618A10CF5C22232290778
    Create Session    myrequestsession    ${base_url}   auth=${auth}   verify=True
    ${body}=   Evaluate    { "mobile":"9790590318", "client_ref_num":"Vampire", "requested_services": "whatsapp,paytm,amazon,flipkart,facebook,twitter,instagram,apple,linkedin", "generate_score": False }
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${response}=  Post Request    myrequestsession   ${cmd_mobile_request_url}   json=${body}   headers=${headers}

    Log To Console    The request body input is : ${body}
    Log To Console    The response body output is :${response.content}

    ${request_id}=  Set Variable    ${response.json()['request_id']}
    Log To Console    the request_id is : ${request_id}

    Log To Console    CMD Status URL:
    ${status_input}=  Create Dictionary    request_id=${request_id}
    Sleep    4s
    FOR    ${i}    IN RANGE    10
        ${status_response}=  Post Request    myrequestsession   ${cmd_mobile_status_url}  json=${status_input}  headers=${headers}
        ${result1}=    Set Variable    ${status_response.json()['status']}

        Log To Console    ${status_response.content}
        Run Keyword If    '${result1}' == 'In-Progress'   Log To Console    Test case waiting for 10 secs
        Sleep    10s
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
    Should Be Equal As Strings    ${status_response.json()['mobile']}  9790590318
    Should Be Equal As Strings    ${status_response.json()['status']}  Completed
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['whatsapp']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['paytm']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['amazon']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['flipkart']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['instagram']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['twitter']}  Multiple Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['facebook']}  Account Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['apple']}  Account Not Found
    Should Be Equal As Strings    ${status_response.json()['model']['summary']['linkedin']}  Error
    Should Be Equal As Strings    ${status_response.json()['model']['whatsapp_data']['is_business']}  0
    ${end_time}=   Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${time_difference}=    Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M:%S
    ${elapsed_time}=    Subtract Date From Date    ${time_difference}    ${start_time}
    #${elapsed_time}=    Evaluate    ${end_time} - ${start_time}
    Log To Console    time taken for the reqeust is : ${elapsed_time} seconds