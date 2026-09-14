# Store submission checklist (Crypto Pay)

## Android — Google Play
- [x] Application ID: `com.carthigan.cryptopay`
- [x] Release signing keystore (`android/upload-keystore/upload-keystore.jks`)
- [x] `android/key.properties` wired in `app/build.gradle.kts` (gitignored)
- [ ] **Back up keystore + passwords** offline (losing them blocks updates)
- [ ] Build release AAB: `flutter build appbundle --release`
- [ ] Restrict Alchemy API key to your package + SHA-1/256 in Alchemy dashboard
- [ ] Set Reown Project ID metadata / allowlisted domains in Reown Cloud
- [ ] Real HTTPS domain for App Links (`assetlinks.json`) if you use universal links
- [ ] Play Console listing: title, short/full description, screenshots (phone), feature graphic
- [ ] Data safety form: public blockchain data; no personal account required; link privacy policy
- [ ] Content rating questionnaire
- [ ] Privacy policy URL hosted publicly (publish `store/privacy_policy.md`)

## MoonPay (fiat on-ramp)
- [ ] Create account at moonpay.com → get **publishable** key `pk_...`
- [ ] Allow package `com.carthigan.cryptopay` / your domain in MoonPay dashboard
- [ ] Build/run with `--dart-define=MOONPAY_API_KEY=pk_...`
- [ ] Complete MoonPay KYC if required in your region

### Release build command
```bat
flutter build appbundle --release ^
  --dart-define=ALCHEMY_API_KEY=alch_... ^
  --dart-define=REOWN_PROJECT_ID=6e15... ^
  --dart-define=MOONPAY_API_KEY=pk_... ^
  --dart-define=UNIVERSAL_LINK=https://your-domain.com
```

### Keystore backup (do this now)
Copy these to a password manager / offline drive:
- `android/upload-keystore/upload-keystore.jks`
- `android/key.properties` (passwords)

## iOS — App Store (when ready)
- [x] Bundle ID: `com.carthigan.cryptopay`
- [ ] Apple Developer account + certificates
- [ ] Xcode signing team
- [ ] App Privacy labels in App Store Connect
- [ ] Hosted privacy policy URL
- [ ] Universal Links domain + `apple-app-site-association`

## Alchemy dashboard (manual)
1. Open app → Security / Allowed networks
2. Restrict by package name `com.carthigan.cryptopay` if supported for your plan
3. Or put RPC behind your own proxy before shipping widely

## Reown Cloud (manual)
1. Project → Settings → Allowed domains / metadata
2. Set name, description, URL, icon to match store listing
3. Use the same universal link as `UNIVERSAL_LINK`
