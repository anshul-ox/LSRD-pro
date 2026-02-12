import requests
import os
import time

# Create a dummy text file
dummy_filename = "test_document.txt"
with open(dummy_filename, "w") as f:
    f.write("This is a test document. It is an invoice for $500 from Acme Corp to John Doe.")

url = "http://127.0.0.1:8000/analyze-documents"
history_url = "http://127.0.0.1:8000/api/history/"
health_url = "http://127.0.0.1:8000/health"

user_id = "test_user_123"

# 1. Check Health
print("Checking health...")
try:
    health_resp = requests.get(health_url)
    print("Health Status:", health_resp.json())
except Exception as e:
    print(f"Health check failed: {e}")

# 2. Analyze Document
print(f"\nSending analysis request for user: {user_id}...")
files = [
    ('files', (dummy_filename, open(dummy_filename, 'rb'), 'text/plain'))
]
headers = {"user-id": user_id}

try:
    response = requests.post(url, files=files, headers=headers)
    print(f"Analysis Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Validation ID: {data.get('validation_id')}")
    else:
        print("Analysis failed:", response.text)
except Exception as e:
    print(f"Analysis request failed: {e}")

# Wait a bit for DB update (async in theory, though code is sync here)
time.sleep(1)

# 3. Check History
print(f"\nChecking history for user: {user_id}...")
try:
    history_resp = requests.get(history_url + user_id)
    print(f"History Status Code: {history_resp.status_code}")
    if history_resp.status_code == 200:
        history_data = history_resp.json()
        validations = history_data.get("validations", [])
        print(f"Found {len(validations)} validations.")
        for v in validations:
            print(f"- {v['validation_id']} | Status: {v['status']} | Risk: {v['risk_level']}")
    else:
        print("History check failed:", history_resp.text)

except Exception as e:
    print(f"History request failed: {e}")

# Cleanup
try:
    os.remove(dummy_filename)
except:
    pass
