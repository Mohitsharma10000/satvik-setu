// Firestore Seed Data — Run this script to populate categories and subcategories
// Usage: Open Firebase Console > Firestore > Import this data manually
// OR use the Admin Panel to add categories/subcategories via the UI

// This file documents the recommended initial data for the platform.
// Copy this JSON structure into Firestore or use the Admin Panel.

const seedData = {
  "categories": [
    { "name": "Electrician", "icon": "electrical_services", "order": 1, "isActive": true },
    { "name": "Plumber", "icon": "plumbing", "order": 2, "isActive": true },
    { "name": "Mechanic", "icon": "build", "order": 3, "isActive": true },
    { "name": "Carpenter", "icon": "carpenter", "order": 4, "isActive": true },
    { "name": "Painter", "icon": "format_paint", "order": 5, "isActive": true },
    { "name": "AC Repair", "icon": "ac_unit", "order": 6, "isActive": true },
    { "name": "RO Service", "icon": "water_drop", "order": 7, "isActive": true },
    { "name": "Refrigerator Repair", "icon": "kitchen", "order": 8, "isActive": true },
    { "name": "Washing Machine Repair", "icon": "local_laundry_service", "order": 9, "isActive": true },
    { "name": "TV Repair", "icon": "tv", "order": 10, "isActive": true },
    { "name": "Mobile Repair", "icon": "phone_android", "order": 11, "isActive": true },
    { "name": "Laptop Repair", "icon": "laptop", "order": 12, "isActive": true },
    { "name": "Computer Repair", "icon": "computer", "order": 13, "isActive": true },
    { "name": "CCTV Installation", "icon": "videocam", "order": 14, "isActive": true },
    { "name": "Internet Technician", "icon": "wifi", "order": 15, "isActive": true },
    { "name": "Driver", "icon": "directions_car", "order": 16, "isActive": true },
    { "name": "Welder", "icon": "hardware", "order": 17, "isActive": true },
    { "name": "Gardener", "icon": "grass", "order": 18, "isActive": true },
    { "name": "Mason", "icon": "foundation", "order": 19, "isActive": true },
    { "name": "House Cleaning", "icon": "cleaning_services", "order": 20, "isActive": true },
    { "name": "Pest Control", "icon": "pest_control", "order": 21, "isActive": true }
  ],
  
  "subcategories": {
    "Electrician": [
      "House Wiring", "Fan Installation", "Switch Board Repair", "MCB Repair",
      "Meter Repair", "Inverter Installation", "Generator Repair", "Light Installation"
    ],
    "Plumber": [
      "Tank Washer", "Pipe Fitting", "Pipe Leakage", "Tap Repair",
      "Toilet Repair", "Bathroom Fittings", "Water Tank Cleaning", "Water Motor Repair"
    ],
    "Mechanic": [
      "Bike Repair", "Car Repair", "Tractor Repair", "Truck Repair",
      "Engine Repair", "Battery Service", "Puncture Repair"
    ],
    "Carpenter": [
      "Furniture Repair", "Door Repair", "Window Fitting", "Cabinet Making",
      "Bed Repair", "Table Repair", "Wardrobe Installation", "Wood Polishing"
    ],
    "Painter": [
      "Interior Painting", "Exterior Painting", "Wall Texture", "Waterproofing",
      "POP Ceiling", "Wall Putty", "Spray Painting", "Wood Painting"
    ],
    "AC Repair": [
      "AC Installation", "AC Service", "AC Gas Refill", "AC Compressor Repair",
      "Split AC Repair", "Window AC Repair", "AC PCB Repair", "AC Duct Cleaning"
    ],
    "RO Service": [
      "RO Installation", "RO Service", "RO Filter Change", "RO Membrane Change",
      "Water Purifier Repair", "UV Filter Service", "TDS Check", "RO AMC"
    ],
    "Refrigerator Repair": [
      "Fridge Repair", "Fridge Gas Refill", "Compressor Repair", "Thermostat Repair",
      "Door Seal Repair", "Deep Freezer Repair", "Fridge Service"
    ],
    "Washing Machine Repair": [
      "Front Load Repair", "Top Load Repair", "Motor Repair", "Drum Repair",
      "PCB Repair", "Water Pump Repair", "Machine Installation"
    ],
    "TV Repair": [
      "LED TV Repair", "LCD TV Repair", "Smart TV Repair", "TV Panel Repair",
      "TV Installation", "TV Wall Mount", "Sound System Repair"
    ],
    "Mobile Repair": [
      "Screen Replacement", "Battery Replacement", "Software Repair", "Charging Port Repair",
      "Speaker Repair", "Camera Repair", "Water Damage Repair"
    ],
    "Laptop Repair": [
      "Screen Repair", "Keyboard Replacement", "Battery Replacement", "Motherboard Repair",
      "RAM Upgrade", "SSD Upgrade", "Virus Removal", "OS Installation"
    ],
    "Computer Repair": [
      "Desktop Assembly", "Hardware Repair", "Software Installation", "Virus Removal",
      "Data Recovery", "Network Setup", "Printer Setup", "UPS Repair"
    ],
    "CCTV Installation": [
      "Camera Installation", "DVR Setup", "Cable Laying", "Camera Repair",
      "Night Vision Camera", "IP Camera Setup", "Remote Monitoring Setup"
    ],
    "Internet Technician": [
      "WiFi Installation", "Router Setup", "Cable Networking", "Fiber Setup",
      "Network Troubleshooting", "Speed Optimization", "Modem Repair"
    ],
    "Driver": [
      "Car Driver", "Bike Rider", "Truck Driver", "Auto Driver",
      "Taxi Driver", "Bus Driver", "Personal Driver"
    ],
    "Welder": [
      "Arc Welding", "Gas Welding", "MIG Welding", "TIG Welding",
      "Gate Fabrication", "Railing Work", "Grill Work", "Structural Welding"
    ],
    "Gardener": [
      "Garden Maintenance", "Lawn Mowing", "Plant Installation", "Tree Trimming",
      "Irrigation Setup", "Landscaping", "Pest Treatment", "Garden Design"
    ],
    "Mason": [
      "Brick Work", "Plastering", "Tile Fitting", "Flooring",
      "Wall Construction", "RCC Work", "Renovation", "Demolition"
    ],
    "House Cleaning": [
      "Deep Cleaning", "Kitchen Cleaning", "Bathroom Cleaning", "Sofa Cleaning",
      "Carpet Cleaning", "Window Cleaning", "Floor Scrubbing", "Move-in Cleaning"
    ],
    "Pest Control": [
      "Termite Control", "Cockroach Control", "Bed Bug Treatment", "Mosquito Control",
      "Rat Control", "Ant Treatment", "Lizard Control", "General Pest Control"
    ]
  }
};
