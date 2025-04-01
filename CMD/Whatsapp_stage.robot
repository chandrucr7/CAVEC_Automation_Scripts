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
${DBHost}   digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work

*** Test Cases ***
Test_case01
    Check If Exists In Database    SELECT * FROM validation.kyc_aadhaar_basic_verification_api where client_ref_num ='pjvxgFpJvt';
    ${result}=   query    SELECT * FROM validation.kyc_aadhaar_basic_verification_api where client_ref_num ='pjvxgFpJvt'
    log to console  ${result}

    # Validation (Database)
    ${sql_query}=    Set Variable    SELECT result_code FROM validation.kyc_aadhaar_basic_verification_api where http_status_code='200' AND client_ref_num='pjvxgFpJvt' order by id desc limit 1;
    # Execute SQL Query
    ${query_result}=    query    ${sql_query}
    Log To Console    ${query_result}


Test_case01
    Check If Exists In Database    SELECT * FROM validation.kyc_aadhaar_basic_verification_api where client_ref_num ='${random_client_ref_num}';
    ${result}=   query    SELECT * FROM validation.kyc_aadhaar_basic_verification_api where client_ref_num ='${random_client_ref_num}'
    log to console  ${result}

#Validation (Data base)

    ${sql_query}=    Set Variable    SELECT  http_status_code FROM validation.kyc_aadhaar_basic_verification_api here http_status_code='${status_code}' AND client_ref_num='${client_ref_num}' order by id desc limit 1;

# Execute SQL Query
    ${query_result}=    Query    ${sql_query}
    Log To Console    ${query_result}