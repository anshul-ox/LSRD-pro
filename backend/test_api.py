import requests
import os

# Create a dummy text file
dummy_filename = "test_document.txt"
with open(dummy_filename, "w") as f:
    f.write("This is a test document. It is an invoice for $500 from Acme Corp to John Doe.")

url = "http://127.0.0.1:8000/analyze-documents"

files = [
    ('files', (dummy_filename, open(dummy_filename, 'rb'), 'text/plain'))
]

print(f"Sending request to {url}...")
try:
    response = requests.post(url, files=files)
    print(f"Status Code: {response.status_code}")
    print("Response JSON:")
    print(response.json())
except Exception as e:
    print(f"Error: {e}")
finally:
    # Cleanup
    pass
