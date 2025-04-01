import requests
import pytest
import csv
import json
import os

# Constants (Variables in Robot Framework)
DB_NAME = "validation"
DB_USER = "qa.chandraprakash.d"
DB_PASS = "KrG3yfPY"
DB_HOST = "digitap-dev-db.chjy1zjdr74q.ap-south-1.rds.amazonaws.com"
DB_PORT = 3306
BASE_URL = "https://svcstage.digitap.work"
FILE_PATH = "C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\PanFname_Data.csv"
JSON_SCHEMA_FILE = "C:\\Users\\ChandraprakashD\\PycharmProjects\\KYCValidations\\Validationapi\\Pan to fName\\Json_schema.json"


# Function to connect to the database (not used directly here, but as a placeholder)
def connect_to_db():
    # Placeholder for DB connection logic
    pass


# Function to disconnect from the database
def disconnect_from_db():
    # Placeholder for DB disconnection logic
    pass


# Function to read test data from the CSV
def read_test_data_from_csv(file_path):
    test_data = []
    with open(file_path, newline='') as csvfile:
        csvreader = csv.reader(csvfile)
        next(csvreader)  # Skip header line
        for row in csvreader:
            data = {
                "Test Cases": row[0],
                "pan": row[1],
                "client_ref_num": row[2]
            }
            test_data.append(data)
    return test_data


# Function to validate the JSON response
def validate_json_response(expected_json, actual_json):
    expected_keys = list(expected_json.keys())
    actual_keys = list(actual_json.keys())

    # Remove ignored keys (like request_id)
    expected_keys = [key for key in expected_keys if key != "request_id"]
    actual_keys = [key for key in actual_keys if key != "request_id"]

    missing_keys = [key for key in expected_keys if key not in actual_keys]
    if missing_keys:
        pytest.fail(f"Missing keys in response: {missing_keys}")

    extra_keys = [key for key in actual_keys if key not in expected_keys]
    if extra_keys:
        pytest.fail(f"Unexpected extra keys in response: {extra_keys}")

    for key in expected_keys:
        expected_value = expected_json.get(key)
        actual_value = actual_json.get(key)
        assert expected_value == actual_value, f"Mismatch for key {key}"


# Function to send the POST request and validate the response
def send_post_request_and_validate(auth, body, expected_schema_file, case_key):
    headers = {"Content-Type": "application/json"}
    response = requests.post(f"{BASE_URL}/validation/kyc/v1/pan_to_fname", json=body, headers=headers, auth=auth)

    assert response.status_code == 200, f"Request failed with status code {response.status_code}"

    # Parse the actual response JSON
    actual_json = response.json()

    # Load expected JSON schema
    with open(expected_schema_file, 'r') as schema_file:
        expected_json = json.load(schema_file)

    expected_case_json = expected_json.get(case_key)

    # Validate the JSON response
    validate_json_response(expected_case_json, actual_json)


# Function to write results to a CSV file
def write_results_to_csv(status, test_case_name, error_message, output_csv_file):
    data = [test_case_name, status, error_message]
    file_exists = os.path.exists(output_csv_file)

    with open(output_csv_file, mode='a', newline='') as file:
        writer = csv.writer(file)
        if not file_exists:
            writer.writerow(['Test Case Name', 'Status', 'Error Message'])
        writer.writerow(data)


# Test function that runs all test cases from the CSV
@pytest.mark.parametrize("auth, file_path, expected_schema_file", [
    (["526526315047", "EA6F34B4B3B618A10CF5C22232290778"], FILE_PATH, JSON_SCHEMA_FILE)
])
def test_run_all_test_cases(auth, file_path, expected_schema_file):
    test_data = read_test_data_from_csv(file_path)
    failures = []

    for index, row in enumerate(test_data):
        test_case_name = row["Test Cases"]
        print(f"--------------------------Running Test Case: {test_case_name}--------------------------------------")

        body = {
            "pan": row['pan'],
            "client_ref_num": row['client_ref_num']
        }
        case_key = f"case{index + 1}"

        # Run the test case and capture the result
        try:
            send_post_request_and_validate(auth, body, expected_schema_file, case_key)
            status = "PASS"
            error = ""
        except AssertionError as e:
            status = "FAIL"
            error = str(e)
            failures.append(f'Test case "{test_case_name}" failed: {error}')

        write_results_to_csv(status, test_case_name, error, "test_results.csv")
        print()

    # Log all failures at the end
    if failures:
        pytest.fail(f"The following test cases failed:\n{failures}")
