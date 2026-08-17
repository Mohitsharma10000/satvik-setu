import urllib.request
import json
import time

PROJECT_ID = "service-60f49"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

categories = [
    {"id": "cat_1", "name": "Electrician", "icon": "57790", "order": 1, "isActive": True},
    {"id": "cat_2", "name": "Plumber", "icon": "58696", "order": 2, "isActive": True},
    {"id": "cat_3", "name": "Mechanic", "icon": "57553", "order": 3, "isActive": True},
    {"id": "cat_4", "name": "Carpenter", "icon": "57678", "order": 4, "isActive": True},
    {"id": "cat_5", "name": "Painter", "icon": "57923", "order": 5, "isActive": True},
    {"id": "cat_6", "name": "AC Repair", "icon": "57416", "order": 6, "isActive": True},
    {"dict_id": "cat_7", "name": "RO Service", "icon": "59288", "order": 7, "isActive": True},
    {"dict_id": "cat_8", "name": "Refrigerator Repair", "icon": "58170", "order": 8, "isActive": True},
    {"dict_id": "cat_9", "name": "Washing Machine Repair", "icon": "58254", "order": 9, "isActive": True},
    {"dict_id": "cat_10", "name": "TV Repair", "icon": "59227", "order": 10, "isActive": True},
    {"dict_id": "cat_11", "name": "Mobile Repair", "icon": "58655", "order": 11, "isActive": True},
    {"dict_id": "cat_12", "name": "Laptop Repair", "icon": "58236", "order": 12, "isActive": True},
    {"dict_id": "cat_13", "name": "CCTV Installation", "icon": "59406", "order": 13, "isActive": True},
    {"dict_id": "cat_14", "name": "Driver", "icon": "57811", "order": 14, "isActive": True},
    {"dict_id": "cat_15", "name": "Gardener", "icon": "57955", "order": 15, "isActive": True},
    {"dict_id": "cat_16", "name": "House Cleaning", "icon": "57710", "order": 16, "isActive": True},
    {"dict_id": "cat_17", "name": "Pest Control", "icon": "61677", "order": 17, "isActive": True},
    {"dict_id": "cat_18", "name": "Mason", "icon": "57931", "order": 18, "isActive": True},
    {"dict_id": "cat_19", "name": "Welder", "icon": "58077", "order": 19, "isActive": True},
    {"dict_id": "cat_20", "name": "Internet Technician", "icon": "59438", "order": 20, "isActive": True},
    {"dict_id": "cat_21", "name": "Computer Repair", "icon": "57731", "order": 21, "isActive": True},
]

subcategories = [
    # Electrician
    {"categoryId": "cat_1", "name": "House Wiring", "order": 1, "isActive": True},
    {"categoryId": "cat_1", "name": "Fan Repair & Installation", "order": 2, "isActive": True},
    {"categoryId": "cat_1", "name": "Switchboard & MCB Repair", "order": 3, "isActive": True},
    {"categoryId": "cat_1", "name": "Inverter Repair & Battery Service", "order": 4, "isActive": True},
    {"categoryId": "cat_1", "name": "Light Fitting & Chandelier", "order": 5, "isActive": True},
    
    # Plumber
    {"categoryId": "cat_2", "name": "Pipe Fitting & Leakage Repair", "order": 1, "isActive": True},
    {"categoryId": "cat_2", "name": "Tap & Mixer Repair", "order": 2, "isActive": True},
    {"categoryId": "cat_2", "name": "Toilet & Sink Unblocking", "order": 3, "isActive": True},
    {"categoryId": "cat_2", "name": "Water Tank Cleaning & Installation", "order": 4, "isActive": True},
    {"categoryId": "cat_2", "name": "Water Heater / Geyser Service", "order": 5, "isActive": True},

    # Mechanic
    {"categoryId": "cat_3", "name": "Car General Service", "order": 1, "isActive": True},
    {"categoryId": "cat_3", "name": "Bike & Scooter Service", "order": 2, "isActive": True},
    {"categoryId": "cat_3", "name": "Puncture & Tyre Service", "order": 3, "isActive": True},
    {"categoryId": "cat_3", "name": "Battery Jumpstart & Replacement", "order": 4, "isActive": True},

    # AC Repair
    {"categoryId": "cat_6", "name": "AC Servicing & Cleaning", "order": 1, "isActive": True},
    {"categoryId": "cat_6", "name": "AC Gas Refilling", "order": 2, "isActive": True},
    {"categoryId": "cat_6", "name": "AC Installation & Uninstallation", "order": 3, "isActive": True},

    # RO Service
    {"categoryId": "cat_7", "name": "RO Filter Replacement", "order": 1, "isActive": True},
    {"categoryId": "cat_7", "name": "RO Full Repair & Maintenance", "order": 2, "isActive": True},
]

def seed_categories():
    print("Seeding Categories into Firestore...")
    for idx, c in enumerate(categories, 1):
        doc_id = f"cat_{idx}"
        data = {
            "fields": {
                "name": {"stringValue": c["name"]},
                "icon": {"stringValue": c["icon"]},
                "order": {"integerValue": str(c["order"])},
                "isActive": {"booleanValue": c["isActive"]}
            }
        }
        url = f"{BASE_URL}/categories?documentId={doc_id}"
        req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers={'Content-Type': 'application/json'}, method='POST')
        try:
            with urllib.request.urlopen(req) as resp:
                print(f"✅ Added Category: {c['name']}")
        except Exception as e:
            # If doc exists, update via PATCH
            patch_url = f"{BASE_URL}/categories/{doc_id}"
            patch_req = urllib.request.Request(patch_url, data=json.dumps(data).encode('utf-8'), headers={'Content-Type': 'application/json'}, method='PATCH')
            try:
                with urllib.request.urlopen(patch_req) as resp:
                    print(f"🔄 Updated Category: {c['name']}")
            except Exception as ex:
                print(f"❌ Failed Category {c['name']}: {ex}")

def seed_subcategories():
    print("Seeding Subcategories into Firestore...")
    for sub in subcategories:
        data = {
            "fields": {
                "categoryId": {"stringValue": sub["categoryId"]},
                "name": {"stringValue": sub["name"]},
                "order": {"integerValue": str(sub["order"])},
                "isActive": {"booleanValue": sub["isActive"]}
            }
        }
        url = f"{BASE_URL}/subcategories"
        req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers={'Content-Type': 'application/json'}, method='POST')
        try:
            with urllib.request.urlopen(req) as resp:
                print(f"✅ Added Subcategory: {sub['name']}")
        except Exception as e:
            print(f"❌ Failed Subcategory {sub['name']}: {e}")

if __name__ == "__main__":
    seed_categories()
    seed_subcategories()
    print("🎉 Seeding complete!")
