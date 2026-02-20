# AgroGuard AI - Production Deployment Guide

Complete step-by-step guide for deploying AgroGuard AI to production environments.

---

## Table of Contents

1. [Backend Deployment](#backend-deployment)
2. [Mobile App Deployment](#mobile-app-deployment)
3. [Web Deployment](#web-deployment)
4. [Environment Configuration](#environment-configuration)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [Monitoring & Logging](#monitoring--logging)
7. [Scaling](#scaling)
8. [Cost Optimization](#cost-optimization)

---

## Backend Deployment

### Option 1: Heroku Deployment (Easiest)

**Prerequisites:**
- Heroku account (free tier available)
- Heroku CLI installed

**Steps:**

1. **Prepare project:**
```bash
cd smartcrop_backend

# Create Procfile (tells Heroku how to run the app)
echo "web: python app.py" > Procfile

# Requirements already exist, verify:
cat requirements.txt
```

2. **Initialize git repository:**
```bash
git init
git add .
git commit -m "Initial commit"
```

3. **Create and deploy:**
```bash
# Install Heroku CLI from: https://devcenter.heroku.com/articles/heroku-cli

heroku login
heroku create smartcrop-api
heroku addons:create heroku-postgresql:hobby-dev  # For future database

# Deploy
git push heroku main
```

4. **Configure environment variables:**
```bash
heroku config:set FLASK_ENV=production
heroku config:set FLASK_DEBUG=0
heroku config:set SECRET_KEY=your-secret-key-here
```

5. **View logs:**
```bash
heroku logs --tail
```

**Backend URL:** `https://smartcrop-api.herokuapp.com`

### Option 2: AWS Elastic Beanstalk

**Prerequisites:**
- AWS account
- AWS CLI installed
- EB CLI installed

**Steps:**

1. **Install EB CLI:**
```bash
pip install awsebcli
```

2. **Initialize project:**
```bash
cd smartcrop_backend
eb init -p python-3.9 smartcrop-api --region us-east-1
```

3. **Create environment and deploy:**
```bash
eb create smartcrop-env
eb deploy
```

4. **Configure environment variables:**
```bash
eb setenv FLASK_ENV=production SECRET_KEY=your-secret-key
```

5. **View logs:**
```bash
eb logs
```

**Backend URL:** `https://smartcrop-env.us-east-1.elasticbeanstalk.com`

### Option 3: Google Cloud Run

**Prerequisites:**
- Google Cloud account
- Google Cloud SDK installed
- Docker installed

**Steps:**

1. **Authenticate:**
```bash
gcloud auth login
gcloud config set project smartcrop-ai
```

2. **Build and deploy:**
```bash
cd smartcrop_backend

gcloud run deploy smartcrop-api \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

3. **Configure environment:**
```bash
gcloud run services update smartcrop-api \
  --set-env-vars FLASK_ENV=production,SECRET_KEY=your-secret-key
```

**Backend URL:** `https://smartcrop-api-xxxxx.run.app`

### Option 4: Docker + Custom Server

**Create Dockerfile:**
```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "120", "app:app"]
```

**Build and run:**
```bash
docker build -t smartcrop-api:latest .
docker run -p 5000:5000 smartcrop-api:latest
```

**Requirements.txt addition (for Gunicorn):**
```
gunicorn==21.2.0
```

---

## Mobile App Deployment

### Android Deployment

#### Google Play Store

1. **Prepare for release:**
```bash
cd smartcrop_mobile

# Clean previous builds
flutter clean

# Build release APK (for testing)
flutter build apk --release
```

2. **Generate signed APK:**
```bash
# Create keystore (one-time)
keytool -genkey -v -keystore ~/smartcrop-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias smartcrop

# Update pubspec.yaml with keystore info
```

3. **Create App Bundle (required for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

4. **Upload to Google Play:**
- Go to: https://play.google.com/console
- Create new app "AgroGuard AI"
- Upload app-release.aab
- Fill app details, screenshots, description
- Submit for review (24-48 hours typically)

#### Internal / Beta Testing:

```bash
# Build APK for direct installation
flutter build apk --release

# Upload to Firebase App Distribution or share directly
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### iOS Deployment

#### Apple App Store

1. **Prerequisites:**
- Apple Developer account ($99/year)
- Mac with Xcode
- provisioning profiles, certificates

2. **Prepare for release:**
```bash
cd smartcrop_mobile

ios/Runner.xcworkspace # Open in Xcode
```

3. **In Xcode:**
- Set Team ID
- Update build version/number
- Archive app: Product > Archive
- Validate and Upload

4. **In App Store Connect:**
- Create new app version
- Upload with Xcode (or Transporter)
- Fill app details
- Submit for review (1-3 days)

### Web Deployment

#### Firebase Hosting (Recommended)

1. **Build web app:**
```bash
cd smartcrop_mobile
flutter build web --release
```

2. **Setup Firebase:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

firebase login
firebase init hosting
```

3. **Deploy:**
```bash
firebase deploy
```

**Live URL:** `https://your-project.web.app`

#### Netlify Deployment

1. **Build:**
```bash
flutter build web --release
```

2. **Deploy:**
```bash
# Install Netlify CLI
npm install -g netlify-cli

netlify deploy --prod --dir=build/web
```

#### AWS S3 + CloudFront

1. **Build:**
```bash
flutter build web --release
```

2. **Upload to S3:**
```bash
aws s3 sync build/web s3://smartcrop-frontend-bucket/
```

3. **Setup CloudFront distribution** for CDN caching

---

## Environment Configuration

### Backend Environment Variables

**Production (.env file):**
```bash
# Flask
FLASK_APP=app.py
FLASK_ENV=production
DEBUG=False
SECRET_KEY=your-very-secure-random-key

# Database (if adding)
DATABASE_URL=postgresql://user:password@host:5432/smartcrop

# API Settings
MAX_CONTENT_LENGTH=16777216  # 16MB max upload
API_TIMEOUT=30

# Logging
LOG_LEVEL=INFO
LOG_FILE=smartcrop.log

# CORS
ALLOWED_ORIGINS=https://smartcrop-frontend.web.app,https://yourdomain.com

# ML Models
MODEL_PATH=./models/
CROP_MODEL=crop_model.pkl
DISEASE_MODEL=disease_model.h5
```

**Load environment variables:**
```python
# app.py modification
import os
from dotenv import load_dotenv

load_dotenv()

app.config['MAX_CONTENT_LENGTH'] = int(os.getenv('MAX_CONTENT_LENGTH', 16777216))
```

### Mobile App Configuration

Update backend URL in screens:

**For development:**
```dart
const baseUrl = 'http://localhost:5000';
```

**For production:**
```dart
const baseUrl = 'https://smartcrop-api.herokuapp.com';
```

**Better approach - Create config file:**

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );
}
```

Build with config:
```bash
flutter run --dart-define=API_BASE_URL=https://smartcrop-api.herokuapp.com
```

---

## CI/CD Pipeline

### GitHub Actions Example

**Create .github/workflows/deploy.yml:**

```yaml
name: Deploy AgroGuard AI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  backend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: 3.9
      - run: |
          cd smartcrop_backend
          pip install -r requirements.txt
          python -m pytest  # Add tests

  backend-deploy:
    runs-on: ubuntu-latest
    needs: backend-test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Heroku
        run: |
          cd smartcrop_backend
          echo "Deploying to production..."
          # Add Heroku deploy step

  mobile-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: |
          cd smartcrop_mobile
          flutter pub get
          flutter build apk --release
      - uses: actions/upload-artifact@v2
        with:
          name: smartcrop-apk
          path: smartcrop_mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## Monitoring & Logging

### Backend Monitoring

**Using Heroku:**
```bash
heroku logs --tail              # Live logs
heroku logs --num 100           # Last 100 lines
heroku logs | grep ERROR        # Filter errors
```

**Using AWS CloudWatch:**
```bash
# In Elastic Beanstalk dashboard
# View logs directly from console
```

**Application Logging:**
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Usage
logger.info("Crop prediction request received")
logger.error("Model loading failed", exc_info=True)
```

### Mobile App Crashlytics

**Add Firebase Crashlytics:**
```bash
cd smartcrop_mobile
flutter pub add firebase_core firebase_crashlytics
flutter pub get
```

**In main.dart:**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(const SmartCropAIApp());
}
```

### Monitoring Tools

- **Heroku:** Built-in dashboard
- **AWS:** CloudWatch
- **Google Cloud:** Cloud Monitoring
- **Cross-platform:** New Relic, Datadog, Sentry

---

## Scaling

### Backend Scaling

**Heroku Performance Dynos:**
```bash
heroku dyno:type upgrade web=Performance-M
heroku scale web=2  # Multiple dynos
```

**AWS Auto Scaling:**
- Set up load balancer
- Configure auto-scaling rules based on CPU/memory

**Gunicorn Workers:**
```bash
# In Procfile
web: gunicorn --workers 8 --worker-class sync --bind 0.0.0.0:5000 app:app
```

### Database Scaling

**Add PostgreSQL (if using):**
```bash
heroku addons:create heroku-postgresql:standard-0
```

**Connection pooling:**
```bash
brew install pgbouncer
# Configure connection pooling
```

### CDN for Static Assets

**CloudFlare:**
1. Point domain to CloudFlare
2. Enable caching rules
3. Set up SSL certificate

---

## Cost Optimization

### Free Tier Options

| Service | Free Tier | Cost |
|---------|-----------|------|
| Heroku | Removed (was 550 hours/month) | From $5/month |
| AWS Free | 12 months starter | From pay-as-you-go |
| Google Cloud | $300 credit | Then pay-as-you-go |
| Firebase | Limited free tier | From 0 if light usage |
| Netlify | Generous free tier | Unlimited builds |

### Cost Reduction Tips

1. **Use free tiers strategically**
   - Netlify for frontend
   - AWS free tier EC2 + RDS
   - Firebase for real-time data (if applicable)

2. **Minimize data transfer**
   - Use CDN (CloudFlare free tier)
   - Compress images/data
   - Cache aggressively

3. **Optimize compute**
   - Stop unused dynos
   - Right-size instances
   - Use containers efficiently

4. **Monitor usage**
   - Set up billing alerts
   - Review resource usage monthly
   - Remove unused services

---

## Security Checklist

- [ ] Enable HTTPS/SSL everywhere
- [ ] Set strong SECRET_KEY
- [ ] Enable database backups
- [ ] Configure firewall rules
- [ ] Use environment variables for secrets
- [ ] Enable CORS only for known domains
- [ ] Implement rate limiting
- [ ] Add input validation
- [ ] Enable API authentication (JWT)
- [ ] Regular security updates
- [ ] Monitor for suspicious activity
- [ ] Setup automated backups
- [ ] Enable two-factor authentication on accounts
- [ ] Use secrets management (AWS Secrets Manager, 1Password)

---

## Post-Deployment Checklist

- [ ] Backend API responding
- [ ] Mobile app connects to backend
- [ ] Disease detection works with real images
- [ ] Crop recommendation returns valid crops
- [ ] Sensor dashboard updates in real-time
- [ ] Error handling works correctly
- [ ] Logs are being recorded
- [ ] Performance is acceptable
- [ ] CORS is properly configured
- [ ] SSL certificates valid
- [ ] Database backups enabled
- [ ] Monitoring alerts set up
- [ ] Team has access
- [ ] Documentation updated

---

## Rollback Procedure

**Heroku:**
```bash
heroku releases  # See deployment history
heroku rollback  # Rollback to previous version
```

**AWS:**
```bash
eb swap your-env green-env  # Swap with green environment
```

**Manual:**
- Keep previous version running
- Scale new version down if issues
- Route traffic back to stable version
- Debug problems

---

## Support & Resources

- **Heroku:** https://devcenter.heroku.com/
- **AWS:** https://docs.aws.amazon.com/
- **Google Cloud:** https://cloud.google.com/docs
- **Flutter Deployment:** https://flutter.dev/docs/deployment
- **Security Best Practices:** https://owasp.org/

---

## Troubleshooting Deployments

### Backend won't start after deployment

```bash
# Check logs
heroku logs --tail

# Common issues:
# 1. Missing environment variables
heroku config

# 2. Port not available
# (Usually handled automatically)

# 3. Model files missing
# Ensure models/ directory is in repo or use external storage
```

### Mobile app can't connect to production API

1. Update API URL in code
2. Check CORS settings
3. Verify frontend is on whitelist
4. Test endpoint directly:
```bash
curl https://smartcrop-api.herokuapp.com/health
```

### High costs after deployment

1. Review AWS/Heroku dashboard
2. Scale down unnecessary resources
3. Implement caching
4. Monitor database queries
5. Use CDN for static assets

---

**Last Updated:** 2025
**Version:** 1.0.0
