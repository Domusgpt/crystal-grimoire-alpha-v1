# Crystal Grimoire - Production Setup Guide

🔮 Complete setup guide for deploying Crystal Grimoire with working authentication, payments, ads, and mobile apps.

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/Domusgpt/crystal-grimoire-alpha-v1.git
cd crystal-grimoire-alpha-v1/crystal_grimoire_flutter

# Install dependencies
flutter pub get

# Run the build script
./scripts/build_production.sh
```

## 📋 Prerequisites

### Required Tools
- Flutter SDK (3.10.0+)
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)
- Firebase CLI
- Git

### Required Accounts
- [Firebase Console](https://console.firebase.google.com)
- [RevenueCat Dashboard](https://app.revenuecat.com)
- [Google AdMob](https://admob.google.com)
- [Google Play Console](https://play.google.com/console) (for Android)
- [Apple Developer](https://developer.apple.com) (for iOS)

## 🔥 Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name: `crystal-grimoire`
4. Enable Google Analytics

### 2. Configure Authentication

1. In Firebase Console → Authentication → Sign-in method
2. Enable:
   - Email/Password
   - Google
   - Apple (iOS only)

### 3. Configure Firestore Database

1. Firestore Database → Create database
2. Start in production mode
3. Choose region closest to your users

### 4. Get Configuration Files

**For Web:**
1. Project Settings → Web apps → Add app
2. Copy the config object to `lib/firebase_options.dart`

**For Android:**
1. Project Settings → Android apps → Add app
2. Package name: `com.domusgpt.crystalgrimoire`
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

**For iOS:**
1. Project Settings → iOS apps → Add app
2. Bundle ID: `com.domusgpt.crystalgrimoire`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/GoogleService-Info.plist`

### 5. Update Firebase Configuration

Edit `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-web-api-key',
  appId: 'your-web-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'crystal-grimoire',
  authDomain: 'crystal-grimoire.firebaseapp.com',
  storageBucket: 'crystal-grimoire.appspot.com',
  measurementId: 'your-measurement-id',
);
```

## 💰 RevenueCat Setup

### 1. Create RevenueCat Project

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create new project: "Crystal Grimoire"
3. Copy the API key

### 2. Configure Products

Create these products in RevenueCat:
- `crystal_premium_monthly` - $8.99/month
- `crystal_pro_monthly` - $19.99/month  
- `crystal_founders_lifetime` - $499 lifetime

### 3. Update API Key

Edit `lib/services/payment_service.dart`:

```dart
static const String _revenueCatApiKey = 'your-revenuecat-api-key';
```

### 4. Configure Entitlements

In RevenueCat Dashboard:
- Create entitlement: `premium`
- Create entitlement: `pro`  
- Create entitlement: `founders`

## 📱 AdMob Setup

### 1. Create AdMob Account

1. Go to [Google AdMob](https://admob.google.com)
2. Create account and add app

### 2. Get Ad Unit IDs

Create ad units for:
- Banner ads
- Interstitial ads
- Rewarded ads

### 3. Update Ad Configuration

Edit `lib/services/ads_service.dart`:

```dart
// Replace test IDs with production IDs
static const String _androidBannerId = 'ca-app-pub-YOUR-PUBLISHER-ID/BANNER-ID';
static const String _iosBannerId = 'ca-app-pub-YOUR-PUBLISHER-ID/BANNER-ID';
```

### 4. Update Manifest Files

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR-PUBLISHER-ID~YOUR-APP-ID"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR-PUBLISHER-ID~YOUR-APP-ID</string>
```

## 🤖 Android Setup

### 1. Generate Signing Key

```bash
keytool -genkey -v -keystore android/app/crystalgrimoire-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias crystalgrimoire
```

### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=crystalgrimoire
storeFile=crystalgrimoire-keystore.jks
```

### 3. Update Package Name

Ensure all files use `com.domusgpt.crystalgrimoire`:
- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/.../MainActivity.kt`

### 4. Build Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

## 🍎 iOS Setup

### 1. Configure Xcode Project

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Set Bundle Identifier: `com.domusgpt.crystalgrimoire`
4. Set Team and Signing Certificate

### 2. Configure Capabilities

Enable in Xcode:
- Sign in with Apple
- Push Notifications (optional)
- In-App Purchase

### 3. Add URL Schemes

In `ios/Runner/Info.plist`, update:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

### 4. Build iOS

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Then archive in Xcode for App Store
```

## 🌐 Web Deployment

### GitHub Pages (Current)

1. Build: `flutter build web --base-href "/crystal-grimoire-alpha-v1/"`
2. Copy `build/web` to `docs/`
3. Push to GitHub
4. Enable GitHub Pages in repo settings

### Custom Domain (Optional)

1. Update base href: `flutter build web --base-href "/"`
2. Deploy to your hosting provider
3. Update Firebase Auth domains

## 🔧 Backend Integration

### Update Backend for Authentication

If using the Python backend, update to validate Firebase tokens:

```python
import firebase_admin
from firebase_admin import auth, credentials

# Initialize Firebase Admin
cred = credentials.Certificate("path/to/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

def verify_firebase_token(token):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token['uid']
    except Exception as e:
        return None
```

### API Endpoint Protection

```python
from functools import wraps

def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'error': 'No token provided'}), 401
        
        token = token.replace('Bearer ', '')
        user_id = verify_firebase_token(token)
        if not user_id:
            return jsonify({'error': 'Invalid token'}), 401
        
        request.user_id = user_id
        return f(*args, **kwargs)
    return decorated

@app.route('/api/identify', methods=['POST'])
@require_auth
def identify_crystal():
    user_id = request.user_id
    # Process with authenticated user
```

## 🚀 Deployment Checklist

### Pre-Launch
- [ ] Firebase project configured
- [ ] RevenueCat products created
- [ ] AdMob ads configured
- [ ] App store listings prepared
- [ ] Privacy policy and terms created
- [ ] Beta testing completed

### Android Play Store
- [ ] Developer account created ($25 fee)
- [ ] App Bundle uploaded
- [ ] Store listing completed
- [ ] Content rating completed
- [ ] App reviewed and approved

### iOS App Store
- [ ] Developer account created ($99/year)
- [ ] App archived and uploaded
- [ ] Store listing completed
- [ ] App reviewed and approved

### Web Deployment
- [ ] Domain configured (if custom)
- [ ] SSL certificate (if custom)
- [ ] Analytics configured
- [ ] SEO optimized

## 🔒 Security Considerations

### API Keys
- Never commit API keys to version control
- Use environment variables in production
- Rotate keys regularly

### Authentication
- Enable multi-factor authentication
- Use secure password policies
- Implement rate limiting

### Data Protection
- Encrypt sensitive data
- Implement proper CORS
- Use HTTPS everywhere

## 📊 Monitoring & Analytics

### Firebase Analytics
- Track user engagement
- Monitor crash reports
- A/B test features

### RevenueCat Analytics
- Monitor subscription metrics
- Track conversion rates
- Optimize pricing

### AdMob Analytics
- Track ad performance
- Optimize ad placement
- Monitor revenue

## 🐛 Troubleshooting

### Common Issues

**Firebase Auth not working:**
- Check domain whitelist in Firebase Console
- Verify API keys are correct
- Ensure proper platform configuration

**Payments not working:**
- Verify RevenueCat configuration
- Check product IDs match
- Test with sandbox accounts

**Ads not showing:**
- Verify AdMob configuration
- Check test device setup
- Ensure proper consent management

### Support Resources
- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [RevenueCat Documentation](https://docs.revenuecat.com)
- [AdMob Documentation](https://developers.google.com/admob)

## 📞 Support

For technical support or questions:
- Email: phillips.paul.email@gmail.com
- GitHub: @domusgpt

---

🔮 **Crystal Grimoire is ready to enchant users worldwide!** ✨