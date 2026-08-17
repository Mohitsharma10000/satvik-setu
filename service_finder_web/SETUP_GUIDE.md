# 🚀 Service Finder Web - Complete Setup Guide

## Step-by-Step Installation

### 1️⃣ Install Dependencies

```bash
cd c:\Users\ms164\OneDrive\Desktop\app\service_finder_web
npm install
```

**Dependencies being installed:**
- Next.js 14 (React framework)
- Material-UI (UI components)
- Firebase SDK (Backend)
- Zustand (State management)
- React Toastify (Notifications)
- TypeScript (Type safety)

### 2️⃣ Firebase Setup

#### A. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `service-finder-web`
4. Disable Google Analytics (optional)
5. Click "Create Project"

#### B. Enable Authentication
1. In Firebase Console, go to **Authentication** → **Get Started**
2. Click **Sign-in method** tab
3. Enable **Google** provider
4. Add your support email
5. Save

#### C. Create Firestore Database
1. Go to **Firestore Database** → **Create Database**
2. Select **Production mode** (we'll add rules later)
3. Choose closest region
4. Click **Enable**

#### D. Enable Storage
1. Go to **Storage** → **Get Started**
2. Use default security rules
3. Choose same region as Firestore
4. Click **Done**

#### E. Get Firebase Config
1. Go to **Project Settings** (gear icon)
2. Scroll to **Your apps**
3. Click **Web app** icon (</> symbol)
4. Register app name: `service-finder-web`
5. Copy the `firebaseConfig` object

### 3️⃣ Environment Variables

Create `.env.local` file in project root:

```bash
cp .env.local.example .env.local
```

Edit `.env.local` and paste your Firebase config:

```env
# Firebase Configuration (from step 2E)
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789012
NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789012:web:abcdef123456

# Razorpay (get from https://dashboard.razorpay.com/)
NEXT_PUBLIC_RAZORPAY_KEY=rzp_test_XXXXXXXXXXXX

# Optional: Google Maps
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_maps_key_here
```

### 4️⃣ Configure Firestore Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. Copy content from `../firestore.rules` file in parent directory
3. Paste and **Publish** rules

**Important Rules:**
- Authenticated users can read their own data
- Public can read categories, subcategories, providers
- Only authenticated users can create service requests
- Admin operations require authentication

### 5️⃣ Seed Initial Data (Optional but Recommended)

You have two options:

#### Option A: Use existing seed script
```bash
cd ..
python seed_firestore.py
```

#### Option B: Manually add test category
1. Go to Firestore Console
2. Create collection: `categories`
3. Add document:
```json
{
  "name": "CCTV Installation",
  "icon": "📹",
  "order": 1,
  "isActive": true,
  "advanceFee": 10,
  "createdAt": [current timestamp]
}
```

4. Create collection: `subcategories`
5. Add document:
```json
{
  "categoryId": "[category_doc_id_from_step_3]",
  "name": "Home CCTV",
  "order": 1,
  "isActive": true
}
```

### 6️⃣ Run Development Server

```bash
npm run dev
```

Open browser: [http://localhost:3000](http://localhost:3000)

### 7️⃣ Test the Application

1. **Welcome Page** → Click "Continue with Google"
2. **Sign In** → Select your Google account
3. **Dashboard** → You should see categories (if seeded)
4. **Browse** → Click category → subcategory → providers

---

## 🔧 Troubleshooting

### Issue: "Failed to load categories"

**Solution:**
1. Check `.env.local` has correct Firebase config
2. Verify Firestore rules allow public read on `categories`
3. Check browser console for specific error
4. Ensure at least 1 category exists in Firestore

### Issue: "Authentication failed"

**Solution:**
1. Enable Google Sign-In in Firebase Console
2. Add authorized domain:
   - Firebase Console → Authentication → Settings → Authorized domains
   - Add: `localhost`
3. Clear browser cache and try again

### Issue: "Infinite loading / skeleton showing forever"

**Solution:**
1. Open browser DevTools (F12) → Console tab
2. Look for Firebase errors
3. Common causes:
   - Wrong Firebase config in `.env.local`
   - Firestore rules blocking reads
   - User not authenticated but trying to access protected data
4. Check Network tab for failed requests

### Issue: Build errors with TypeScript

**Solution:**
```bash
rm -rf .next node_modules package-lock.json
npm install
npm run dev
```

### Issue: Firebase quota exceeded

**Solution:**
- Firebase free tier has daily limits
- Check Firebase Console → Usage tab
- Upgrade to Blaze (pay-as-you-go) if needed

---

## 🎯 Next Steps

### 1. Add Razorpay Integration
- Sign up at [Razorpay](https://razorpay.com/)
- Get test API keys
- Add to `.env.local`

### 2. Add More Categories
- Go to Firestore Console
- Add more documents in `categories` collection
- Add corresponding subcategories

### 3. Add Test Providers
- Create documents in `approved_providers` collection
- Include required fields: name, phone, categoryId, subcategoryId, etc.

### 4. Customize Theme
- Edit `src/theme/index.ts`
- Change colors, fonts, button styles

### 5. Deploy to Production
```bash
npm run build
# Deploy to Vercel/Netlify/Firebase Hosting
```

---

## 📊 Firebase Collections Structure

After setup, your Firestore should have:

```
📁 categories
  📄 [auto-id]
    ├── name: "CCTV Installation"
    ├── icon: "📹"
    ├── order: 1
    ├── isActive: true
    ├── advanceFee: 10
    └── createdAt: Timestamp

📁 subcategories
  📄 [auto-id]
    ├── categoryId: "xyz123"
    ├── name: "Home CCTV"
    ├── order: 1
    └── isActive: true

📁 approved_providers
  📄 [auto-id]
    ├── name: "John Doe"
    ├── phone: "+91XXXXXXXXXX"
    ├── categoryId: "xyz123"
    ├── subcategoryId: "abc456"
    ├── category: "CCTV Installation"
    ├── subcategory: "Home CCTV"
    ├── profileImage: "https://..."
    ├── verifiedAt: Timestamp
    ├── serviceRate: 500
    ├── city: "Mumbai"
    └── state: "Maharashtra"

📁 users
  📄 [user-uid]
    ├── userId: "user-uid"
    ├── email: "user@example.com"
    ├── displayName: "User Name"
    ├── photoUrl: "https://..."
    ├── isVerified: true
    ├── createdAt: Timestamp
    └── lastLoginAt: Timestamp

📁 service_requests (created when user books service)
📁 payments (created when payment is made)
```

---

## 🔐 Security Checklist

- [ ] Firebase config in `.env.local` (not committed to Git)
- [ ] `.env.local` added to `.gitignore`
- [ ] Firestore security rules configured
- [ ] Google Sign-In authorized domains set
- [ ] Storage security rules configured
- [ ] Razorpay keys kept private (test mode for development)

---

## 📞 Support

If you encounter issues:
1. Check browser console (F12)
2. Check Firebase Console for errors
3. Verify all environment variables are set
4. Review this guide again

---

**Happy Coding! 🎉**
