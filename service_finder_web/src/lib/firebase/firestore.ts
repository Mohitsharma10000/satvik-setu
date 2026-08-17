import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  where,
  orderBy,
  addDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
  Timestamp,
} from 'firebase/firestore';
import { db } from './config';
import { Category, Subcategory, Provider, ServiceRequest, Payment } from '@/types';

// ==================== CATEGORIES ====================
export const getCategories = async (): Promise<Category[]> => {
  const categoriesRef = collection(db, 'categories');
  const q = query(categoriesRef, where('isActive', '==', true), orderBy('order'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
    createdAt: (doc.data().createdAt as Timestamp)?.toDate(),
  })) as Category[];
};

export const getCategoryById = async (categoryId: string): Promise<Category | null> => {
  const docRef = doc(db, 'categories', categoryId);
  const docSnap = await getDoc(docRef);
  if (!docSnap.exists()) return null;
  return { id: docSnap.id, ...docSnap.data() } as Category;
};

// ==================== SUBCATEGORIES ====================
export const getSubcategories = async (categoryId: string): Promise<Subcategory[]> => {
  const subcategoriesRef = collection(db, 'subcategories');
  const q = query(
    subcategoriesRef,
    where('categoryId', '==', categoryId),
    where('isActive', '==', true),
    orderBy('order')
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })) as Subcategory[];
};

export const getSubcategoryById = async (subcategoryId: string): Promise<Subcategory | null> => {
  const docRef = doc(db, 'subcategories', subcategoryId);
  const docSnap = await getDoc(docRef);
  if (!docSnap.exists()) return null;
  return { id: docSnap.id, ...docSnap.data() } as Subcategory;
};

// ==================== PROVIDERS ====================
export const getProviders = async (
  categoryId: string,
  subcategoryId: string
): Promise<Provider[]> => {
  const providersRef = collection(db, 'approved_providers');
  const q = query(
    providersRef,
    where('categoryId', '==', categoryId),
    where('subcategoryId', '==', subcategoryId)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    providerId: doc.id,
    ...doc.data(),
    verifiedAt: (doc.data().verifiedAt as Timestamp)?.toDate(),
  })) as Provider[];
};

export const getProviderById = async (providerId: string): Promise<Provider | null> => {
  const docRef = doc(db, 'approved_providers', providerId);
  const docSnap = await getDoc(docRef);
  if (!docSnap.exists()) return null;
  return {
    providerId: docSnap.id,
    ...docSnap.data(),
    verifiedAt: (docSnap.data().verifiedAt as Timestamp)?.toDate(),
  } as Provider;
};

// ==================== SERVICE REQUESTS ====================
export const createServiceRequest = async (
  requestData: Omit<ServiceRequest, 'requestId'>
): Promise<string> => {
  const requestsRef = collection(db, 'service_requests');
  const docRef = await addDoc(requestsRef, {
    ...requestData,
    requestedAt: serverTimestamp(),
    scheduledDate: requestData.scheduledDate
      ? Timestamp.fromDate(requestData.scheduledDate)
      : null,
  });
  return docRef.id;
};

export const getUserServiceRequests = async (userId: string): Promise<ServiceRequest[]> => {
  const requestsRef = collection(db, 'service_requests');
  const q = query(requestsRef, where('userId', '==', userId), orderBy('requestedAt', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    requestId: doc.id,
    ...doc.data(),
    requestedAt: (doc.data().requestedAt as Timestamp)?.toDate(),
    scheduledDate: (doc.data().scheduledDate as Timestamp)?.toDate(),
  })) as ServiceRequest[];
};

export const getProviderServiceRequests = async (
  providerId: string
): Promise<ServiceRequest[]> => {
  const requestsRef = collection(db, 'service_requests');
  const q = query(
    requestsRef,
    where('providerId', '==', providerId),
    orderBy('requestedAt', 'desc')
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    requestId: doc.id,
    ...doc.data(),
    requestedAt: (doc.data().requestedAt as Timestamp)?.toDate(),
    scheduledDate: (doc.data().scheduledDate as Timestamp)?.toDate(),
  })) as ServiceRequest[];
};

export const updateServiceRequestStatus = async (
  requestId: string,
  status: ServiceRequest['status']
): Promise<void> => {
  const docRef = doc(db, 'service_requests', requestId);
  await updateDoc(docRef, { status });
};

// ==================== PAYMENTS ====================
export const createPayment = async (paymentData: Omit<Payment, 'paymentId'>): Promise<string> => {
  const paymentsRef = collection(db, 'payments');
  const docRef = await addDoc(paymentsRef, {
    ...paymentData,
    createdAt: serverTimestamp(),
  });
  return docRef.id;
};

export const updatePayment = async (
  paymentId: string,
  updates: Partial<Payment>
): Promise<void> => {
  const docRef = doc(db, 'payments', paymentId);
  await updateDoc(docRef, updates);
};
