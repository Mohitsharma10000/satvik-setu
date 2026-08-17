import {
  signInWithPopup,
  GoogleAuthProvider,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  User as FirebaseUser,
} from 'firebase/auth';
import { doc, getDoc, setDoc, serverTimestamp } from 'firebase/firestore';
import { auth, db } from './config';
import { User } from '@/types';

const googleProvider = new GoogleAuthProvider();

export const signInWithGoogle = async (): Promise<User> => {
  try {
    const result = await signInWithPopup(auth, googleProvider);
    const firebaseUser = result.user;

    // Check if user exists in Firestore
    const userRef = doc(db, 'users', firebaseUser.uid);
    const userSnap = await getDoc(userRef);

    let userData: User;

    if (!userSnap.exists()) {
      // Create new user document
      userData = {
        userId: firebaseUser.uid,
        email: firebaseUser.email || undefined,
        displayName: firebaseUser.displayName || undefined,
        photoUrl: firebaseUser.photoURL || undefined,
        isVerified: true,
        createdAt: new Date(),
        lastLoginAt: new Date(),
      };

      await setDoc(userRef, {
        ...userData,
        createdAt: serverTimestamp(),
        lastLoginAt: serverTimestamp(),
      });
    } else {
      // Update last login
      userData = userSnap.data() as User;
      await setDoc(userRef, { lastLoginAt: serverTimestamp() }, { merge: true });
    }

    return userData;
  } catch (error: any) {
    console.error('Google Sign-In Error:', error);
    throw new Error(error.message || 'Failed to sign in with Google');
  }
};

export const signOut = async (): Promise<void> => {
  try {
    await firebaseSignOut(auth);
  } catch (error: any) {
    console.error('Sign Out Error:', error);
    throw new Error(error.message || 'Failed to sign out');
  }
};

export const onAuthStateChange = (callback: (user: User | null) => void) => {
  return onAuthStateChanged(auth, async (firebaseUser: FirebaseUser | null) => {
    if (firebaseUser) {
      const userRef = doc(db, 'users', firebaseUser.uid);
      const userSnap = await getDoc(userRef);

      if (userSnap.exists()) {
        const userData = userSnap.data() as User;
        callback(userData);
      } else {
        callback(null);
      }
    } else {
      callback(null);
    }
  });
};
