*** Settings ***
Library    RequestsLibrary
Library    CSVLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DatabaseLibrary
Library    urllib3
Library    random
Library    pan_assertions.py

Suite Setup     Connect To Database     pymysql     ${DBName}   ${DBUser}   ${DBPass}   ${DBHost}   ${DBPort}
Suite Teardown      Disconnect From Database


*** Variables ***
${DBName}   validation
${DBUser}   qa.chandraprakash.d
${DBPass}   KrG3yfPY
${DBHost}   digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com
${DBPort}   3306
${base_url}=    https://svcstage.digitap.work
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
Test_case
    log to console  Verify pan details for Government Agency, Artificial Juridical Person and Invalid PAN
    ${auth}=    create list    740513625625012    9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG
    create session    mysession    ${base_url}    auth=${auth}    verify=true

    # Read test data from CSV file
    ${test_data}=    Read Test Data From CSV    ${file_path}

    FOR    ${index}    ${row}    IN ENUMERATE    ${test_data}
        # Get pan and client_ref_num from each row
        ${pan}=    Get From Dictionary    ${row}    pan
        ${client_ref_num}=    Get From Dictionary    ${row}    client_ref_num

        log to console  Iteration: ${index} - PAN: ${pan}

        ${body}=    create dictionary    pan=${pan}    client_ref_num=${client_ref_num}
        ${header}=    create dictionary    Content-Type=application/json
        ${response}=    Post Request     mysession     /validation/kyc/v3/pan_details   json=${body}    headers=${header}
        Log To Console    ${body}
        Log To Console    ${response.status_code}
        Log To Console    ${response.content}

        # Import and call the assertion function
        ${module_name}=    Evaluate    import pan_assertions
        ${module}=    Get Library Instance    ${module_name}
        ${module}.assert_pan_details(${response}, ${pan})

    END