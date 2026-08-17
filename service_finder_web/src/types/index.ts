export interface User {
  userId: string;
  email?: string;
  phone?: string;
  displayName?: string;
  photoUrl?: string;
  isVerified: boolean;
  fcmToken?: string;
  createdAt: Date;
  lastLoginAt: Date;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  order: number;
  isActive: boolean;
  advanceFee: number;
  createdAt?: Date;
}

export interface Subcategory {
  id: string;
  categoryId: string;
  name: string;
  icon?: string;
  order: number;
  isActive: boolean;
}

export interface Provider {
  providerId: string;
  name: string;
  phone: string;
  profileImage: string;
  category: string;
  subcategory: string;
  categoryId: string;
  subcategoryId: string;
  verifiedAt: Date;
  latitude?: number;
  longitude?: number;
  serviceRate?: number;
  rateDescription?: string;
  address?: string;
  city?: string;
  state?: string;
  pincode?: string;
  distanceKm?: number;
}

export interface ServiceRequest {
  requestId?: string;
  userId: string;
  userName: string;
  userPhone: string;
  providerId: string;
  providerName: string;
  providerPhone: string;
  categoryId: string;
  category: string;
  subcategoryId: string;
  subcategory: string;
  serviceLocation: string;
  latitude?: number;
  longitude?: number;
  requestedAt: Date;
  scheduledDate?: Date;
  estimatedCharge?: number;
  advancePaid: number;
  remainingAmount?: number;
  status: 'requested' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';
  paymentId: string;
  completionPhotos: string[];
  beforePhotos: string[];
  afterPhotos: string[];
  completionNotes?: string;
  invoice?: string;
  providerFcmToken?: string;
  userFcmToken?: string;
}

export interface Payment {
  paymentId: string;
  userId: string;
  amount: number;
  currency: string;
  razorpayOrderId: string;
  razorpayPaymentId?: string;
  razorpaySignature?: string;
  status: 'created' | 'paid' | 'failed';
  createdAt: Date;
  paidAt?: Date;
  purpose: 'service_advance' | 'donation' | 'remaining_payment';
  categoryId?: string;
  subcategoryId?: string;
  requestId?: string;
}

export interface Application {
  applicationId?: string;
  name: string;
  phone: string;
  email?: string;
  categoryId: string;
  subcategoryId: string;
  address: string;
  city: string;
  state: string;
  pincode: string;
  latitude?: number;
  longitude?: number;
  serviceRate?: number;
  rateDescription?: string;
  profileImage?: string;
  documents: string[];
  status: 'pending' | 'approved' | 'rejected';
  submittedAt: Date;
  reviewedAt?: Date;
  reviewedBy?: string;
  rejectionReason?: string;
}

export interface DonationSettings {
  isEnabled: boolean;
  minAmount: number;
  suggestedAmounts: number[];
  description: string;
  upiId?: string;
}
