# ⚡ Quick Reference Guide

## 🎯 Project Location
```
c:\Users\ms164\OneDrive\Desktop\app\service_finder_web\
```

## 🚀 Quick Commands

### Installation
```bash
cd c:\Users\ms164\OneDrive\Desktop\app\service_finder_web
npm install
```

### Development
```bash
npm run dev
# Opens: http://localhost:3000
```

### Production Build
```bash
npm run build
npm start
```

### Linting
```bash
npm run lint
```

---

## 📂 Important Files

| File | Purpose | Action Needed |
|------|---------|---------------|
| `.env.local.example` | Environment template | Copy to `.env.local` and fill |
| `SETUP_GUIDE.md` | Detailed setup instructions | Read first! |
| `README.md` | Project documentation | Reference |
| `quick-start.bat` | Auto-install script | Double-click to run |
| `PROJECT_SUMMARY.md` | What's been built | Overview |
| `package.json` | Dependencies | Auto-managed |

---

## 🔥 Firebase Setup (Required)

### 1. Create Project
```
https://console.firebase.google.com/ → Add Project
```

### 2. Enable Services
- ✅ Authentication → Google Sign-In
- ✅ Firestore Database → Create Database
- ✅ Storage → Enable

### 3. Get Config
```
Project Settings → Your Apps → Web App → Copy firebaseConfig
```

### 4. Add to .env.local
```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_key_here
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456
NEXT_PUBLIC_FIREBASE_APP_ID=1:123456:web:abc123
```

---

## 📱 Available Pages

| Page | URL | Description |
|------|-----|-------------|
| Home | `/` | Auto-redirect |
| Welcome | `/welcome` | Login page |
| Dashboard | `/dashboard` | Categories |
| Category | `/category/:id` | Subcategories |
| Providers | `/category/:id/subcategory/:id` | Provider list |
| My Requests | `/my-requests` | Request history |

---

## 🗂️ Firestore Collections Needed

Minimum data to test app:

### categories
```javascript
{
  name: "CCTV Installation",
  icon: "📹",
  order: 1,
  isActive: true,
  advanceFee: 10,
  createdAt: [timestamp]
}
```

### subcategories
```javascript
{
  categoryId: "cat_id_here",
  name: "Home CCTV",
  order: 1,
  isActive: true
}
```

### approved_providers
```javascript
{
  name: "John Doe",
  phone: "+91XXXXXXXXXX",
  profileImage: "https://...",
  category: "CCTV Installation",
  subcategory: "Home CCTV",
  categoryId: "cat_id",
  subcategoryId: "sub_id",
  verifiedAt: [timestamp],
  serviceRate: 500,
  city: "Mumbai",
  state: "Maharashtra",
  pincode: "400001"
}
```

---

## 🐛 Troubleshooting Quick Fixes

### "npm install" fails
```bash
npm cache clean --force
npm install
```

### App shows blank page
```bash
# Check console (F12) for errors
# Verify .env.local exists and has correct values
```

### "Failed to load categories"
```bash
# 1. Check Firebase config in .env.local
# 2. Verify Firestore has data
# 3. Check Firestore security rules
```

### Authentication not working
```bash
# 1. Firebase Console → Authentication → Enable Google
# 2. Add 'localhost' to authorized domains
# 3. Clear browser cache
```

---

## 📊 Project Structure Quick View

```
service_finder_web/
├── src/
│   ├── app/              # Pages (Next.js 14 App Router)
│   ├── components/       # Reusable UI components
│   ├── lib/firebase/     # Firebase integration
│   ├── store/            # Zustand state management
│   ├── types/            # TypeScript definitions
│   └── theme/            # MUI theme
├── public/               # Static files (images, icons)
├── .env.local           # Environment variables (YOU CREATE THIS)
└── package.json         # Dependencies
```

---

## 🔐 Security Checklist

- [ ] `.env.local` created with Firebase config
- [ ] `.env.local` NOT committed to Git (in .gitignore)
- [ ] Firestore security rules configured
- [ ] Google Sign-In authorized domains added
- [ ] Test with dummy data first

---

## 🎨 Customization Quick Tips

### Change Colors
```typescript
// Edit: src/theme/index.ts
palette: {
  primary: { main: '#YOUR_COLOR' }
}
```

### Change Logo/Name
```typescript
// Edit: src/components/layout/Navbar.tsx
<Typography>Your App Name</Typography>
```

### Add New Page
```bash
# Create: src/app/your-page/page.tsx
export default function YourPage() {
  return <div>Your content</div>
}
# Access: http://localhost:3000/your-page
```

---

## 💻 VS Code Extensions (Recommended)

- ES7+ React/Redux/React-Native snippets
- Prettier - Code formatter
- ESLint
- TypeScript and JavaScript Language Features

---

## 📦 Deployment Options

### Vercel (Easiest)
```bash
npm install -g vercel
vercel
```

### Netlify
```bash
npm run build
# Drag 'out' folder to Netlify
```

### Firebase Hosting
```bash
npm run build
firebase deploy
```

---

## 🆘 Getting Help

1. **Check browser console** (F12) for errors
2. **Read error messages** carefully
3. **Check Firebase Console** for quota/errors
4. **Review SETUP_GUIDE.md** for detailed steps
5. **Check Network tab** for failed requests

---

## ✅ Success Indicators

When everything works:
- ✅ `npm run dev` starts without errors
- ✅ Browser opens http://localhost:3000
- ✅ Welcome page shows "Continue with Google"
- ✅ After login, dashboard shows categories
- ✅ Clicking category shows subcategories
- ✅ Clicking subcategory shows providers
- ✅ My Requests page accessible

---

## 📞 Essential URLs

- **Local Dev:** http://localhost:3000
- **Firebase Console:** https://console.firebase.google.com/
- **Next.js Docs:** https://nextjs.org/docs
- **Material-UI:** https://mui.com/
- **Razorpay Dashboard:** https://dashboard.razorpay.com/

---

## 🎯 Next Actions (In Order)

1. ⏰ **NOW:** Run `quick-start.bat` or `npm install`
2. ⏰ **5 min:** Create `.env.local` with Firebase config
3. ⏰ **10 min:** Setup Firebase (follow SETUP_GUIDE.md)
4. ⏰ **2 min:** Add test category in Firestore
5. ⏰ **1 min:** Run `npm run dev`
6. ⏰ **Test:** Login with Google and browse app

**Total Time: ~20 minutes to get running! 🚀**

---

**Keep this file handy for quick reference!**
