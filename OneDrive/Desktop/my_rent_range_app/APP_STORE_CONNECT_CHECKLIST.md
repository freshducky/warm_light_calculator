# App Store Connect Checklist - Fix Rejection Issues

## ✅ Code Changes Completed

All code changes have been implemented:
- ✅ Fixed IAP product ID: `remove_ads` → `remove.ads`
- ✅ Removed Cash App donation link (violates IAP policy)
- ✅ Added IAP donation tiers ($1, $5, $10)
- ✅ Enhanced IAP error handling and logging
- ✅ Improved UI error messages with retry functionality
- ✅ Incremented build number: 1.0.0+3 → 1.0.0+4

---

## 📋 App Store Connect Actions Required

### 1. Fix App Subtitle (Guideline 2.3.7)

**Current Issue:** Subtitle "Free Affordability Calculator" contains price reference ("Free")

**Action Required:**
1. Go to App Store Connect → Your App → App Information
2. Find the **Subtitle** field
3. **Change from:** "Free Affordability Calculator"
4. **Change to:** One of these options:
   - "Rent Affordability Calculator"
   - "Calculate Your Rent Range"
   - "Affordability Calculator"
5. **Save changes**

**Note:** Remove ALL price references from subtitle (no "Free", "$0.99", etc.)

---

### 2. Submit IAP Products for Review (Guideline 2.1.0)

#### 2a. Verify "Remove Ads" Product

**Action Required:**
1. Go to App Store Connect → Your App → In-App Purchases
2. Find or create the "Remove Ads" product
3. **Verify Product ID is exactly:** `remove.ads` (must match code exactly)
4. **Product Type:** Non-Consumable
5. **Price:** $0.99
6. **Add Required Metadata:**
   - Screenshot (required for review)
   - Description: "Remove banner ads from MyRentRange"
   - Review Notes: "This is a one-time purchase to remove banner ads"
7. **Status:** Must be "Ready to Submit" or "Waiting for Review"
8. **Submit for Review** if not already submitted

#### 2b. Create Donation Tier Products

**Action Required:**
Create 3 new IAP products for donations:

**Product 1: $1 Donation**
- **Product ID:** `donation.tier.1`
- **Product Type:** Consumable (recommended - allows multiple donations)
- **Price:** $1.00
- **Display Name:** "Support MyRentRange - $1"
- **Description:** "Support MyRentRange development with a $1 donation"
- **Screenshot:** Required (can use same screenshot for all tiers)
- **Review Notes:** "This is a donation to support app development"

**Product 2: $5 Donation**
- **Product ID:** `donation.tier.5`
- **Product Type:** Consumable
- **Price:** $4.99 or $5.00
- **Display Name:** "Support MyRentRange - $5"
- **Description:** "Support MyRentRange development with a $5 donation"
- **Screenshot:** Required
- **Review Notes:** "This is a donation to support app development"

**Product 3: $10 Donation**
- **Product ID:** `donation.tier.10`
- **Product Type:** Consumable
- **Price:** $9.99 or $10.00
- **Display Name:** "Support MyRentRange - $10"
- **Description:** "Support MyRentRange development with a $10 donation"
- **Screenshot:** Required
- **Review Notes:** "This is a donation to support app development"

**Important Notes:**
- All donation products must be **submitted for review**
- Screenshot is **required** for each IAP product
- Ensure **Paid Apps Agreement** is accepted in Business section
- All products must be in "Ready to Submit" or "Waiting for Review" status

---

### 3. Fix iPad Screenshots (Guideline 2.3.3)

**Current Issue:** 13-inch iPad screenshots show iPhone device frames

**Action Required:**
1. **Generate iPad Screenshots:**
   - Use Xcode Simulator
   - Run app on **iPad Pro (12.9-inch)** simulator
   - Capture screenshots using Cmd+S or Screenshot feature
   - Required sizes:
     - Portrait: 2048 x 2732 pixels (12.9" iPad Pro)
     - Landscape: 2732 x 2048 pixels (12.9" iPad Pro)
     - OR 2064 x 2752 pixels for 13" iPad Pro

2. **Upload Screenshots:**
   - Go to App Store Connect → Your App → App Store → iOS App
   - Scroll to **Screenshots** section
   - Click **"View All Sizes in Media Manager"**
   - Upload new iPad screenshots (replace existing ones)
   - Ensure screenshots show actual iPad UI (not iPhone frames)

**Note:** Screenshots should show app functionality clearly on iPad-sized screens

---

### 4. Submit New Build

**Action Required:**
1. After completing all above steps, build and upload new version
2. **Version:** 1.0.0
3. **Build Number:** 4 (1.0.0+4)
4. Submit for review after all IAP products are approved

---

## 📝 Verification Checklist

Before resubmitting, verify:

- [ ] App subtitle changed (no price references)
- [ ] IAP product ID `remove.ads` matches exactly in App Store Connect
- [ ] "Remove Ads" IAP product is submitted for review
- [ ] All 3 donation tier IAP products created and submitted
- [ ] All IAP products have required screenshots
- [ ] Paid Apps Agreement is accepted
- [ ] iPad screenshots uploaded (proper iPad frames, not iPhone)
- [ ] New build (1.0.0+4) uploaded
- [ ] All IAP products show "Ready to Submit" or "Waiting for Review"

---

## 🚨 Important Notes

1. **IAP Products Must Be Approved First:**
   - Apple requires IAP products to be approved before the app can be approved
   - Submit IAP products for review first
   - Wait for IAP approval, then submit app

2. **Product ID Matching:**
   - The product ID in code (`remove.ads`) MUST match exactly what's in App Store Connect
   - Case-sensitive and character-sensitive

3. **Screenshot Requirements:**
   - Each IAP product needs a screenshot (can be the same for all)
   - Screenshot should show the IAP purchase screen or app functionality

4. **Timeline:**
   - IAP reviews typically take 24-48 hours
   - App review typically takes 24-48 hours after IAP approval
   - Plan for 2-4 days total review time

---

## 📞 Support Resources

- [Apple IAP Documentation](https://developer.apple.com/in-app-purchase/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [IAP Troubleshooting Guide](https://developer.apple.com/documentation/storekit/in-app_purchase)


