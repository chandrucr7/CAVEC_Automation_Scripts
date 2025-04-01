import pytest
import requests
import csv
import allure
from datetime import datetime
import time

# Base URL and API endpoints
BASE_URL = "https://svcstage.digitap.work"
REQUEST_API = "/validation/kyc/v4/pan_details/request"
STATUS_API = "/validation/kyc/v4/pan_details/status"
CSV_FILE_PATH = r"C:\Users\ChandraprakashD\PycharmProjects\KYCValidations\Validationapi\Pan Details V4\PanDetails_V4_Data.csv"

# Authentication Credentials
AUTH_HEADERS = {
    "Authorization": "Basic 740513625625015:9C0nUX3hNT0D0JHHOWGmuNxihkIRCGyG",
    "Content-Type": "application/json"
}


@pytest.fixture
def read_csv_data():
    """Reads test data from CSV file."""
    test_data = []
    with open(CSV_FILE_PATH, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            test_data.append(row)
    return test_data


def send_post_request(endpoint, payload):
    """Helper function to send POST request."""
    url = f"{BASE_URL}{endpoint}"
    response = requests.post(url, json=payload, headers=AUTH_HEADERS, verify=True)
    return response


@pytest.mark.parametrize("test_data", [
    {"client_ref_num": "Vampire", "pan": "DBJPJ2587N"},
    {"client_ref_num": "Vampire", "pan": "AWQPK3219B"}
])
@allure.feature("PAN Details API")
@allure.story("Validate PAN Number")
def test_pan_details_api(test_data):
    """Test PAN details request and status check."""
    start_time = datetime.now()

    with allure.step("Send PAN Details Request"):
        response = send_post_request(REQUEST_API, test_data)
        allure.attach(str(test_data), name="Request Payload", attachment_type=allure.attachment_type.JSON)
        allure.attach(response.text, name="Response Payload", attachment_type=allure.attachment_type.JSON)
        assert response.status_code == 200
        response_data = response.json()
        assert response_data["result_code"] == 101
        assert response_data["client_ref_num"] == test_data["client_ref_num"]
        assert "request_id" in response_data

    request_id = response_data["request_id"]

    with allure.step("Check PAN Details Status"):
        status_payload = {"request_id": request_id}
        for _ in range(10):
            status_response = send_post_request(STATUS_API, status_payload)
            allure.attach(status_response.text, name="Status Response", attachment_type=allure.attachment_type.JSON)
            status_data = status_response.json()

            if status_data["api_status"] == "In-Progress":
                time.sleep(5)
                continue
            break

    with allure.step("Validate Response Status"):
        assert status_data["http_response_code"] == 200
        assert status_data["client_ref_num"] == test_data["client_ref_num"]
        assert status_data["result_code"] == 101
        assert status_data["api_status"] == "Completed"

    elapsed_time = (datetime.now() - start_time).total_seconds()
    allure.attach(f"{elapsed_time} seconds", name="Execution Time", attachment_type=allure.attachment_type.TEXT)
