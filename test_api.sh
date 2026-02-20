#!/usr/bin/env bash

# AgroGuard AI - Backend API Testing Script
# Quick reference for testing all API endpoints
# Usage: ./test_api.sh

API_URL="http://localhost:5000"
ECHO_PREFIX="📌"

echo "🌾 AgroGuard AI - API Testing Script"
echo "======================================"
echo ""

# Color functions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_test() {
    echo -e "${YELLOW}${ECHO_PREFIX} Testing: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ Success: $1${NC}"
}

print_error() {
    echo -e "${RED}❌ Error: $1${NC}"
}

# Test 1: Health Check
print_test "Health Check Endpoint"
response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/health")
if [ "$response" = "200" ]; then
    print_success "Health check passed"
    curl -s "$API_URL/health" | jq .
else
    print_error "Health check failed with status $response"
fi
echo ""

# Test 2: API Status
print_test "API Status Endpoint"
response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/api/status")
if [ "$response" = "200" ]; then
    print_success "API status check passed"
    curl -s "$API_URL/api/status" | jq .
else
    print_error "API status check failed with status $response"
fi
echo ""

# Test 3: Crop Prediction - Good Input
print_test "Crop Prediction - Valid Input"
crop_response=$(curl -s -X POST "$API_URL/api/predict_crop" \
  -H "Content-Type: application/json" \
  -d '{
    "nitrogen": 40,
    "phosphorus": 30,
    "potassium": 35,
    "temperature": 25,
    "humidity": 70,
    "ph": 7.0,
    "rainfall": 200
  }')

echo "$crop_response" | jq .
echo ""

# Test 4: Crop Prediction - Edge Case (High NPK)
print_test "Crop Prediction - High NPK Values"
crop_response=$(curl -s -X POST "$API_URL/api/predict_crop" \
  -H "Content-Type: application/json" \
  -d '{
    "nitrogen": 100,
    "phosphorus": 80,
    "potassium": 90,
    "temperature": 28,
    "humidity": 75,
    "ph": 7.2,
    "rainfall": 250
  }')

echo "$crop_response" | jq .
echo ""

# Test 5: Crop Prediction - Edge Case (Low NPK)
print_test "Crop Prediction - Low NPK Values"
crop_response=$(curl -s -X POST "$API_URL/api/predict_crop" \
  -H "Content-Type: application/json" \
  -d '{
    "nitrogen": 10,
    "phosphorus": 5,
    "potassium": 8,
    "temperature": 15,
    "humidity": 40,
    "ph": 6.0,
    "rainfall": 100
  }')

echo "$crop_response" | jq .
echo ""

# Test 6: Sensor Data
print_test "Real-Time Sensor Data"
response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/api/sensor_data")
if [ "$response" = "200" ]; then
    print_success "Sensor data retrieval passed"
    curl -s "$API_URL/api/sensor_data" | jq .
else
    print_error "Sensor data retrieval failed with status $response"
fi
echo ""

# Test 7: Sensor Data History
print_test "Sensor Data History (Last 10 readings)"
response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/api/sensor_data/history?limit=10")
if [ "$response" = "200" ]; then
    print_success "Sensor history retrieval passed"
    curl -s "$API_URL/api/sensor_data/history?limit=10" | jq .
else
    print_error "Sensor history retrieval failed with status $response"
fi
echo ""

# Test 8: Sensor Average Data
print_test "Sensor Data Averages"
response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/api/sensor_data/average")
if [ "$response" = "200" ]; then
    print_success "Sensor average retrieval passed"
    curl -s "$API_URL/api/sensor_data/average" | jq .
else
    print_error "Sensor average retrieval failed with status $response"
fi
echo ""

# Test 9: Crop Prediction - Missing Field
print_test "Crop Prediction - Missing Required Field"
missing_response=$(curl -s -X POST "$API_URL/api/predict_crop" \
  -H "Content-Type: application/json" \
  -d '{
    "nitrogen": 40,
    "phosphorus": 30
  }')

echo "Expected error response:"
echo "$missing_response" | jq .
echo ""

# Test 10: Disease Detection - Test Image
print_test "Disease Detection - Sample Image"
echo "Note: Please have a test image file (e.g., 'leaf.jpg') in the current directory"
if [ -f "leaf.jpg" ]; then
    disease_response=$(curl -s -X POST "$API_URL/api/predict_disease" \
      -F "image=@leaf.jpg")
    echo "$disease_response" | jq .
else
    echo "ℹ️  Skipping - test image 'leaf.jpg' not found"
    echo "To test, provide an image file and run:"
    echo "curl -X POST $API_URL/api/predict_disease -F 'image=@your-image.jpg'"
fi
echo ""

# Summary
echo "======================================"
echo "🎉 API Testing Complete!"
echo ""
echo "📊 Summary:"
echo "  • Health Check: GET /health"
echo "  • API Status: GET /api/status"
echo "  • Crop Prediction: POST /api/predict_crop"
echo "  • Sensor Data: GET /api/sensor_data"
echo "  • Sensor History: GET /api/sensor_data/history"
echo "  • Sensor Average: GET /api/sensor_data/average"
echo "  • Disease Detection: POST /api/predict_disease"
echo ""
echo "📚 Full documentation: See smartcrop_backend/README.md"
echo "======================================"
