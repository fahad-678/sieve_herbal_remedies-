# Google Play Store Submission Guide

## Pre-Submission Checklist

### 1. App Bundle Ready ✓
- Location: `build/app/outputs/bundle/release/app-release.aab` (44 MB)
- Signed with release keystore
- Version: 1.0.0+1
- Package ID: `com.example.sieveherbalremedies`

### 2. Privacy Policy ✓
- File: `PRIVACY_POLICY.md` (local-only data disclosure)
- Update action: Replace `[your-email@example.com]` with your actual email
- Deployment: Host on a public URL (GitHub Pages, your website, or privacy policy service)

### 3. App Assets (To Prepare)
You'll need the following for your Play Store listing:

#### Required:
- **App Icon** (512×512 px, PNG)
  - Clear, recognizable design
  - Should represent herbal wellness theme
  - Can use one of the herb images as a base or create a custom icon
  
- **Feature Graphic** (1024×500 px, PNG/JPG)
  - Highlight the app's main features
  - Example: "Discover 11 Herbs with Health Benefits"
  
- **Phone Screenshots** (at least 2-5 for landscape/portrait)
  - 1080×1920 px or similar aspect ratio
  - Show key screens: home, herb detail, favorites, tracker
  - Add brief text overlays explaining each feature

- **Short Description** (80 characters max)
  - Example: "Discover herbal remedies and wellness tips"

- **Full Description** (4000 characters max)
  - Highlight features (browsing, favorites, wellness tracker)
  - Mention local storage and privacy
  - Note: "For informational purposes only"

#### Optional:
- **Promo Graphic** (180×120 px)
- **Video URL** (YouTube link if you create one)

### 4. Content Rating Questionnaire
When submitting, you'll be asked about:
- Violence: None
- Sexual content: None
- Substance use: Mentions of herbal remedies only
- Language: None
- Other restrictions: None
Rate as: **Everyone** or **3+** category

### 5. Pricing & Availability
- Set as: **Free**
- Distribute to: **All countries** (or select specific regions)
- Pricing: Free (no in-app purchases or ads)

---

## Step-by-Step Submission Process

### Step 1: Create Google Play Developer Account
```
1. Visit https://play.google.com/console
2. Sign in with your Google Account
3. Accept terms and pay $25 registration fee
4. Complete account setup with payment method
5. Add your developer name and store listing details
```

### Step 2: Create a New App
```
1. Click "Create app" in Play Console
2. App name: Sieve Herbal Remedies
3. Default language: English
4. App type: Application
5. Category: Health & Fitness (or Medical)
6. Contact email: your-email@example.com
```

### Step 3: Upload App Bundle (Internal Testing)
```
1. Go to Release > Testing > Internal testing
2. Click "Create new release"
3. Upload: build/app/outputs/bundle/release/app-release.aab
4. Release notes: "Initial release - Discover and track herbal remedies"
5. Save and review
```

### Step 4: Complete App Details
**Store Listing > App details:**
- Title: Sieve Herbal Remedies
- Short description: Discover herbal remedies and daily wellness tips
- Full description:
  ```
  Sieve Herbal Remedies is your personal guide to natural wellness.
  
  Features:
  • Browse 11 comprehensive herbs with detailed information
  • Learn about health benefits and traditional uses
  • Mark your favorite herbs for quick access
  • Daily wellness tracker to log your journey
  • Herb of the day feature with actionable tips
  • Completely offline - no internet required
  
  All data is stored locally on your device. This app is for informational 
  purposes only and does not replace professional medical advice.
  
  Contact: your-email@example.com
  ```

### Step 5: Add Graphics and Content Rating
**Store Listing > Graphics:**
- Upload app icon, feature graphic, and screenshots
- Add text overlays if needed

**Store Listing > Content rating:**
- Complete the rating questionnaire
- Result should be "Everyone" or "3+" (no harmful content)

### Step 6: Add Privacy Policy
**Store Listing > App details > Privacy policy (URL):**
1. Host `PRIVACY_POLICY.md` publicly (e.g., GitHub Pages)
2. Add the public URL to your Play Store listing
3. Ensure it mentions local-only storage

### Step 7: Test on Internal Track
```
1. Share the internal testing link with yourself or a test user
2. Install the app on a real Android device or emulator
3. Test:
   - App launches and displays herbs
   - Favorites marking works
   - Tracker logging works
   - JSON data is accessible
   - Navigation between tabs works
4. Verify no crashes or errors
```

### Step 8: Submit to Production
```
1. Create a new release in Production track
2. Upload the same AAB file
3. Add release notes
4. Review all store listing details
5. Accept agreements and submit for review
```

---

## Important Notes

- **Review Time**: Google Play typically reviews apps within 1-3 hours
- **First Release**: May take longer (up to 24 hours) due to more thorough review
- **Rejection Risk**: Low for simple informational apps, but check all policies
- **Update Process**: Future updates follow the same AAB upload process

## Troubleshooting Common Issues

### Issue: "Invalid keystore" during upload
- Solution: Keystore is already correct; just upload the AAB file

### Issue: "Target API level too low"
- Solution: Already set to API 35 (latest); should be fine

### Issue: "Missing required permission"
- Solution: App doesn't need special permissions; this should pass

### Issue: "Policy violation detected"
- Solution: Ensure privacy policy clearly states "informational purposes only"

---

## After Launch

1. **Monitor ratings and reviews** - Respond to user feedback
2. **Update version regularly** - Add more herbs or features
3. **Keep privacy policy current** - Update if you add data collection
4. **Gather analytics** (optional) - Add Firebase or similar if desired

Good luck with your submission! 🌿
