# App Store Submission Requirements Checklist

## Issues to Resolve:

### 1. Age Rating Section
**Required:** Select frequency levels for Apple content descriptions

**For Warm Light Calculator (Calculator App):**
- **Age Rating:** 4+ (All ages)
- **Content Descriptions:** Select "None" or "Infrequent/Mild" for all categories:
  - **Unrestricted Web Access:** None
  - **User Generated Content:** None
  - **Cartoon or Fantasy Violence:** None
  - **Realistic Violence:** None
  - **Profanity or Crude Humor:** None
  - **Sexual Content or Nudity:** None
  - **Alcohol, Tobacco, or Drug Use:** None
  - **Gambling and Contests:** None
  - **Horror/Fear Themes:** None
  - **Mature/Suggestive Themes:** None
  - **Medical/Treatment Information:** None (unless you have medical calculations, which you don't)
  - **Unrestricted Web Access:** None

**Steps:**
1. Go to App Store Connect → Your App → App Information
2. Click "Age Rating" section
3. Answer all questions - for a calculator app, everything should be "None" or the lowest rating
4. This should result in a 4+ rating

---

### 2. Privacy Policy URL
**Required:** Enter a Privacy Policy URL in App Privacy section

**Options:**

**Option A: Create a Simple GitHub Pages Site**
1. Create a file `privacy-policy.html` in your repository
2. Enable GitHub Pages
3. Use URL: `https://freshducky.github.io/warm_light_calculator/privacy-policy.html`

**Option B: Use a Simple Text File on GitHub**
- Create `PRIVACY_POLICY.md` in your repo
- Use raw GitHub URL: `https://raw.githubusercontent.com/freshducky/warm_light_calculator/main/PRIVACY_POLICY.md`
- Or create a simple HTML file and host it

**Option C: Create a Simple Landing Page**
- Use a free hosting service (Netlify, Vercel, GitHub Pages)
- Host a simple HTML page with your privacy policy

**Quick Privacy Policy Template:**
Since your app is an offline calculator with no data collection, your privacy policy can be very simple.

---

### 3. Choose a Build
**Required:** Select a build for review

**Steps:**
1. Make sure your Codemagic build completed successfully
2. The build should appear in App Store Connect → TestFlight → iOS Builds
3. If it's not showing:
   - Check that Codemagic successfully published to App Store Connect
   - Wait a few minutes for Apple to process the build
   - Click "Refresh" in App Store Connect
4. Once the build appears:
   - Go to App Store → Your Version → Build
   - Click "+" next to Build
   - Select your build from the list

---

### 4. Select Primary Category
**Required:** Choose a primary category for your app

**Recommended:**
- **Primary Category:** Utilities
- **Secondary Category (Optional):** Productivity

**Steps:**
1. Go to App Store Connect → Your App → App Information
2. Scroll to "Categories"
3. Select "Utilities" as Primary Category
4. Optionally select "Productivity" as Secondary Category

---

### 5. App Privacy Section
**Required:** Admin must provide information about app's privacy practices

**For Warm Light Calculator (Offline Calculator):**

Since your app:
- Operates entirely offline
- Doesn't collect user data
- Doesn't track users
- Doesn't use analytics
- Doesn't share data with third parties

**Privacy Practices Configuration:**

1. Go to App Store Connect → Your App → App Privacy
2. Click "Get Started" or "Edit"
3. Answer the questions:

**Data Collection:**
- **Does your app collect data?** → **No**
  - Since your calculator is offline and doesn't collect any data, select "No"
  - This will simplify the entire process

**If you must select "Yes" (some prompts require it):**
- **What types of data does your app collect?** → Select "None" or skip
- **How is data used?** → Not applicable
- **Is data linked to user identity?** → No
- **Is data used for tracking?** → No

**Data Sharing:**
- **Does your app share data with third parties?** → **No**
- **Does your app use data for tracking?** → **No**

**Privacy Policy:**
- Enter your Privacy Policy URL (from step 2 above)

---

## Quick Action Items:

1. ✅ **Age Rating:** Set to 4+ with all content descriptions as "None"
2. ✅ **Privacy Policy URL:** Create and host a simple privacy policy
3. ✅ **Build:** Select your build from TestFlight after Codemagic publishes
4. ✅ **Category:** Select "Utilities" as primary category
5. ✅ **App Privacy:** Mark as "No data collection" since it's an offline calculator

---

## Privacy Policy Template

Here's a simple privacy policy you can use:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Privacy Policy - Warm Light Calculator</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; }
        h1 { color: #8B4513; }
        h2 { color: #CA7C3A; margin-top: 30px; }
    </style>
</head>
<body>
    <h1>Privacy Policy for Warm Light Calculator</h1>
    <p><strong>Last Updated:</strong> [Current Date]</p>
    
    <h2>Introduction</h2>
    <p>Warm Light Calculator ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle information when you use our mobile application.</p>
    
    <h2>Data Collection</h2>
    <p><strong>We do not collect, store, or transmit any personal information or user data.</strong></p>
    <p>Warm Light Calculator operates entirely offline. All calculations are performed locally on your device. No data leaves your device at any time.</p>
    
    <h2>Information We Don't Collect</h2>
    <ul>
        <li>Personal information</li>
        <li>Usage data</li>
        <li>Device information</li>
        <li>Location data</li>
        <li>Analytics data</li>
        <li>Calculation history</li>
    </ul>
    
    <h2>Third-Party Services</h2>
    <p>Warm Light Calculator does not use any third-party services, analytics tools, or advertising networks. We do not share data with any third parties because we do not collect any data.</p>
    
    <h2>Children's Privacy</h2>
    <p>Our app is safe for users of all ages. Since we do not collect any data, we do not knowingly collect personal information from children under 13.</p>
    
    <h2>Changes to This Privacy Policy</h2>
    <p>We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated revision date.</p>
    
    <h2>Contact Us</h2>
    <p>If you have any questions about this Privacy Policy, please contact us at:</p>
    <p>GitHub: <a href="https://github.com/freshducky/warm_light_calculator">https://github.com/freshducky/warm_light_calculator</a></p>
    
    <p><em>This privacy policy is effective as of the date of app publication.</em></p>
</body>
</html>
```

Save this as `privacy-policy.html` and host it on GitHub Pages or another hosting service.

---

## Next Steps:

1. Create the privacy policy file and host it
2. Complete the Age Rating section in App Store Connect
3. Complete the App Privacy section (mark as "No data collection")
4. Select "Utilities" as your primary category
5. Wait for your build to appear in TestFlight, then select it
6. Submit for review!

Good luck with your submission! 🚀

