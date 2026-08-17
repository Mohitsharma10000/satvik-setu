# Service Finder - Web Application

A modern, responsive web application for connecting customers with verified local service providers.

## 🚀 Tech Stack

- **Framework:** Next.js 14 (React 18)
- **Language:** TypeScript
- **UI Library:** Material-UI (MUI)
- **State Management:** Zustand
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Payments:** Razorpay
- **Styling:** Emotion + CSS-in-JS
- **Forms:** React Hook Form
- **Notifications:** React Toastify
- **Animations:** Framer Motion

## 📋 Features

### Customer Features
- ✅ Google Sign-In authentication
- ✅ Browse service categories and subcategories
- ✅ Search for local service providers
- ✅ View provider details with ratings and location
- ✅ Book services with advance payment
- ✅ Track service request status
- ✅ View request history
- ✅ Real-time notifications

### Provider Features
- ✅ Provider registration and verification
- ✅ Dashboard for managing service requests
- ✅ Accept/reject service requests
- ✅ Upload completion proof (photos + notes)
- ✅ Track earnings and payment history

### Admin Features (Future)
- ⏳ Category management
- ⏳ Provider verification
- ⏳ Payment management
- ⏳ Analytics dashboard

## 📁 Project Structure

```
service_finder_web/
├── src/
│   ├── app/                      # Next.js app directory (pages)
│   │   ├── layout.tsx           # Root layout with providers
│   │   ├── page.tsx             # Home page (redirect logic)
│   │   ├── globals.css          # Global styles
│   │   ├── welcome/             # Welcome/login page
│   │   ├── dashboard/           # Main dashboard
│   │   ├── category/[id]/       # Category details
│   │   ├── my-requests/         # User's service requests
│   │   ├── search/              # Search page
│   │   └── provider/            # Provider dashboard
│   │
│   ├── components/              # Reusable components
│   │   ├── layout/              # Layout components (Navbar, Footer)
│   │   ├── providers/           # Context providers
│   │   └── ui/                  # UI components (cards, buttons, etc.)
│   │
│   ├── lib/                     # Library code
│   │   ├── firebase/            # Firebase configuration and services
│   │   │   ├── config.ts        # Firebase initialization
│   │   │   ├── auth.ts          # Authentication functions
│   │   │   └── firestore.ts     # Firestore CRUD operations
│   │   └── utils/               # Utility functions
│   │
│   ├── store/                   # State management
│   │   ├── authStore.ts         # Authentication state
│   │   └── appStore.ts          # Global app state
│   │
│   ├── types/                   # TypeScript type definitions
│   │   └── index.ts             # All interfaces and types
│   │
│   └── theme/                   # MUI theme configuration
│       └── index.ts             # Theme customization
│
├── public/                      # Static assets
│   ├── images/
│   └── icons/
│
├── .env.local.example           # Environment variables template
├── next.config.mjs              # Next.js configuration
├── tsconfig.json                # TypeScript configuration
└── package.json                 # Dependencies and scripts
```

## 🛠️ Setup Instructions

### Prerequisites
- Node.js 18+ installed
- Firebase project created
- Razorpay account (for payments)

### Installation

1. **Install dependencies:**
```bash
cd service_finder_web
npm install
```

2. **Configure Firebase:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing
   - Enable Authentication (Google Sign-In)
   - Enable Firestore Database
   - Enable Storage
   - Copy your Firebase config

3. **Set up environment variables:**
```bash
cp .env.local.example .env.local
```

Edit `.env.local` and add your credentials:
```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
NEXT_PUBLIC_RAZORPAY_KEY=your_razorpay_key
```

4. **Configure Firestore Security Rules:**

Copy the rules from `firestore.rules` in the parent directory to your Firebase console.

5. **Seed initial data (optional):**

You can use the existing `seed_firestore.py` or `firestore_seed_data.js` from the parent directory to populate initial categories and test data.

### Running the Application

**Development mode:**
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000)

**Production build:**
```bash
npm run build
npm start
```

**Linting:**
```bash
npm run lint
```

## 🔥 Firebase Collections Structure

```
collections/
├── users/                  # User accounts
├── categories/             # Service categories
├── subcategories/         # Subcategories under each category
├── approved_providers/    # Verified service providers
├── applications/          # Pending provider applications
├── service_requests/      # Service bookings
├── payments/              # Payment transactions
├── donation/              # Donation settings
└── app_settings/         # App configuration
```

## 🎨 Customization

### Theme
Edit `src/theme/index.ts` to customize colors, typography, and component styles.

### Components
All reusable components are in `src/components/`. Modify or add new components as needed.

### Routes
Add new pages in `src/app/` directory following Next.js 14 App Router conventions.

## 📦 Key Dependencies

```json
{
  "next": "^14.2.0",           // React framework
  "react": "^18.3.0",          // UI library
  "firebase": "^11.1.0",       // Backend services
  "@mui/material": "^5.16.0",  // UI components
  "zustand": "^4.5.0",         // State management
  "react-toastify": "^10.0.0", // Notifications
  "framer-motion": "^11.11.0"  // Animations
}
```

## 🚀 Deployment

### Vercel (Recommended)
```bash
npm install -g vercel
vercel
```

### Other Platforms
- **Netlify:** Connect GitHub repo and deploy
- **Firebase Hosting:** `npm run build && firebase deploy`
- **AWS Amplify:** Connect repo and configure build settings

## 🔒 Security Notes

- All Firebase credentials should be in `.env.local` (never commit!)
- Firestore security rules must be properly configured
- Razorpay keys should be kept secure
- Enable CORS properly for production domains

## 📱 Responsive Design

The application is fully responsive and works on:
- 📱 Mobile (320px+)
- 📱 Tablet (768px+)
- 💻 Desktop (1024px+)
- 🖥️ Large screens (1440px+)

## 🐛 Troubleshooting

### Loading Issues (Infinite Skeleton)
If you see endless loading:
1. Check Firebase config in `.env.local`
2. Verify Firestore rules allow authenticated reads
3. Check browser console for errors
4. Ensure user is authenticated

### Authentication Issues
1. Enable Google Sign-In in Firebase Console
2. Add authorized domains in Firebase
3. Check if `NEXT_PUBLIC_FIREBASE_*` variables are set

### Build Errors
```bash
rm -rf .next node_modules
npm install
npm run dev
```

## 📄 License

This project is private and proprietary.

## 👨‍💻 Development

For questions or support, contact the development team.

---

**Made with ❤️ using Next.js and Firebase**
