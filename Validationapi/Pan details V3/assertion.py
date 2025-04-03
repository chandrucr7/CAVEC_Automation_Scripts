def assert_pan_details(response, pan):
    """
    Asserts the expected values for the given PAN response.

    Args:
        response: The API response object.
        pan: The PAN number being validated.

    Raises:
        AssertionError: If any of the assertions fail.
    """

    if pan in ('AAAGM0289C', 'AAAJJ0849E'):  # Valid PANs
        assert response.json()['http_response_code'] == '200'
        assert response.json()['result_code'] == '101'
        assert response.json()['client_ref_num'] == "Vampire"  # Assuming this is the expected value
        assert response.json()['result']['first_name'] == ""
        assert response.json()['result']['middle_name'] == ""
        assert response.json()['result']['aadhaar_linked'] is None

        if pan == 'AAAGM0289C':
            assert response.json()['result']['fullname'] == "MINISTRY OF RAILWAYS"
            assert response.json()['result']['last_name'] == "MINISTRY OF RAILWAYS"
            assert response.json()['result']['dob'] == "25/01/1950"
        elif pan == 'AAAJJ0849E':
            assert response.json()['result']['fullname'] == "J K LAKSHMIPAT UNIVERSITY"
            assert response.json()['result']['last_name'] == "J K LAKSHMIPAT UNIVERSITY"
            assert response.json()['result']['dob'] == "07/06/2011"
    else:  # Invalid PAN
        assert response.json()['http_response_code'] == '400'
        assert response.json()['error'] == "Invalid ID number or combination of inputs"
        assert response.json()['client_ref_num'] == "Vampire"