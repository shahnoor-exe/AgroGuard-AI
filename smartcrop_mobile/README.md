# AgroGuard AI - Flutter Mobile App
A beautiful, production-ready Flutter mobile application for smart agriculture powered by AI and IoT sensors.

## Features

### 🌱 Crop Recommendation
- Input soil parameters (Nitrogen, Phosphorus, Potassium)
- Input weather conditions (Temperature, Humidity, pH, Rainfall)
- Get AI-powered crop recommendations with confidence scores
- Beautifully designed UI with gradient backgrounds

### 🔍 Disease Detection
- Capture or upload leaf images from gallery or camera
- AI-powered plant disease detection using CNN
- Get treatment and prevention recommendations
- Display disease information with symptoms, treatment, and prevention

### 📊 Sensor Dashboard
- Real-time IoT sensor monitoring (9 sensors)
- Monitored metrics:
  - Nitrogen, Phosphorus, Potassium (NPK)
  - Temperature & Humidity
  - pH Level
  - Rainfall
  - Soil Moisture
  - Light Intensity
- Status indicators (Optimal/Caution/Alert)
- Active alert system with threshold-based warnings
- Auto-refresh every 5 seconds
- Manual refresh capability

### 🎨 Beautiful Material3 Design
- Green agriculture-inspired color scheme (#2ecc71 primary)
- Gradient backgrounds
- Smooth animations
- Card-based layouts with shadows
- Responsive design for all screen sizes

## Project Structure

```
smartcrop_mobile/
├── lib/
│   ├── main.dart                          # App initialization and routing
│   └── screens/
│       ├── home_screen.dart              # Main landing page
│       ├── crop_recommendation_screen.dart   # Crop prediction
│       ├── disease_detection_screen.dart     # Disease detection
│       └── sensor_dashboard_screen.dart      # Real-time sensor data
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Dart lint rules
├── .gitignore
└── README.md
```

## Dependencies

```yaml
flutter: # Flutter SDK
cupertino_icons: # iOS icons
http: ^1.1.0  # HTTP client for backend API
image_picker: ^1.0.4  # Camera and gallery image selection
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Backend API running at `http://localhost:5000`

### Installation

1. Navigate to the project directory:
```bash
cd smartcrop_mobile
```

2. Fetch dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Configuration

The app connects to the backend API at `http://localhost:5000`. If your backend is running on a different host/port, update the following in the screen files:

- **Crop Recommendation**: `lib/screens/crop_recommendation_screen.dart` line ~91
- **Disease Detection**: `lib/screens/disease_detection_screen.dart` line ~44
- **Sensor Dashboard**: `lib/screens/sensor_dashboard_screen.dart` line ~64

## API Endpoints Used

### Crop Recommendation
```
POST /api/predict_crop
Content-Type: application/json

Request:
{
  "nitrogen": 50.0,
  "phosphorus": 30.0,
  "potassium": 40.0,
  "temperature": 25.0,
  "humidity": 70.0,
  "ph": 7.0,
  "rainfall": 200.0
}

Response:
{
  "crop": "Rice",
  "confidence": 0.92
}
```

### Disease Detection
```
POST /api/predict_disease
Content-Type: multipart/form-data

Request: Image file in "image" field

Response:
{
  "disease": "Tomato_late_blight",
  "confidence": 0.95,
  "symptoms": "Water-soaked spots on leaves",
  "treatment": "Apply copper fungicide",
  "prevention": "Avoid overhead watering"
}
```

### Sensor Data
```
GET /api/sensor_data

Response:
{
  "current_data": {
    "nitrogen": 45.2,
    "phosphorus": 28.5,
    "potassium": 38.1,
    "temperature": 24.8,
    "humidity": 68.5,
    "ph": 6.95,
    "rainfall": 185.3,
    "soil_moisture": 65.2,
    "light_intensity": 5250.0
  },
  "alerts": [
    {
      "metric": "humidity",
      "value": 68.5,
      "message": "Humidity is slightly low"
    }
  ]
}
```

## Architecture

### Screens

#### HomeScreen
- Main navigation hub
- Feature cards with gradients
- Hero welcome section
- App information

#### CropRecommendationScreen
- Form with 7 input fields
- POST request to backend
- Confidence indicator with progress bar
- Error handling
- Loading state

#### DiseaseDetectionScreen
- Image picker (camera/gallery)
- Image preview
- Multipart file upload
- Disease information display
- Treatment and prevention cards
- Status indicators

#### SensorDashboardScreen
- 9-sensor grid layout
- Status color coding (Green/Orange/Red)
- Auto-refresh timer (5 seconds)
- Manual refresh button
- Alert display
- Progress bars for each sensor

### Color Scheme

- **Primary Green**: #2ecc71
- **Dark Green**: #27ae60
- **Light Green**: #c8e6c9, #e8f5e9
- **Warning**: #e74c3c
- **Info**: #27ae60

## Features in Detail

### Material3 Design System
- Uses Flutter's latest Material3 theme
- ColorScheme from seed color (#2ecc71)
- Custom AppBar styling with green theme
- Elevation and shadows throughout
- Smooth animations

### Error Handling
- Network error messages
- Connection timeout handling
- Validation feedback
- User-friendly error cards

### Loading States
- Circular progress indicators
- Disabled buttons during loading
- Loading text display
- Smooth transitions

### Data Visualization
- Progress bars for sensor values
- Status color indicators
- Confidence scores
- Real-time updates

## Deployment

### Build APK (Android)
```bash
flutter build apk --release
```

### Build AAB (Android App Bundle)
```bash
flutter build appbundle --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

### Web Deployment
```bash
flutter build web --release
```

## Browser Compatibility (Web)
- Chrome
- Firefox
- Safari
- Edge

## Performance Optimization

1. **Image Optimization**: Images are compressed before upload
2. **Network Efficiency**: Minimal API requests
3. **State Management**: Efficient StatefulWidget usage
4. **Widget Rebuilding**: Optimized to reduce unnecessary rebuilds
5. **Auto-refresh**: 5-second interval for sensor data

## Security Considerations

1. **API Communication**: HTTPS recommended for production
2. **Image Handling**: Secure file handling with validation
3. **User Data**: No sensitive data stored locally (consider adding secure storage for production)
4. **Input Validation**: All numeric inputs validated

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
Tests for individual screens and widgets

### Integration Tests
Full app flow testing

## Known Limitations

1. Requires backend API to be running
2. Backend must support CORS
3. Image picker requires camera/gallery permissions
4. Sensor data updates every 5 seconds (configurable)

## Future Enhancements

- [ ] Local data caching with Hive/SQLite
- [ ] Push notifications for alerts
- [ ] Multi-language support
- [ ] Offline mode with local storage
- [ ] Export/share reports
- [ ] Advanced analytics dashboard
- [ ] User profiles and settings
- [ ] Historical data visualization
- [ ] Recommendation history

## Contributing

This is a production-ready template. Feel free to fork and customize for your needs.

## License

© 2025 Smart Agriculture. All rights reserved.

## Support

For issues and questions:
- Check the backend API logs
- Verify network connectivity
- Ensure backend is running on localhost:5000
- Check image_picker platform configuration

## Troubleshooting

### "Connection refused" error
- Verify backend is running at http://localhost:5000
- Check firewall settings
- Ensure network connectivity

### Image picker not working
- iOS: Grant camera and photo library permissions in Info.plist
- Android: Grant READ_EXTERNAL_STORAGE and CAMERA permissions
- Web: Browser must allow camera and storage access

### "Failed to connect" on device
- Use your machine's IP address instead of localhost
- Example: `http://192.168.x.x:5000`
- Ensure device is on same network

## Version History

### v1.0.0 (Initial Release)
- Crop Recommendation with AI
- Disease Detection with CNN
- Real-time Sensor Dashboard
- Beautiful Material3 UI
- Full API integration
