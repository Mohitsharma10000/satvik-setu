'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter, useSearchParams } from 'next/navigation';
import {
  Container,
  Box,
  Typography,
  Card,
  CardContent,
  TextField,
  Button,
  Grid,
  Avatar,
  Divider,
  CircularProgress,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import Navbar from '@/components/layout/Navbar';
import { getProviderById, getCategoryById } from '@/lib/firebase/firestore';
import { useAuthStore } from '@/store/authStore';
import { Provider, Category } from '@/types';
import { toast } from 'react-toastify';

export default function BookingPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const { user } = useAuthStore();
  
  const providerId = params.providerId as string;
  const categoryId = searchParams.get('categoryId') || '';
  const subcategoryId = searchParams.get('subcategoryId') || '';

  const [provider, setProvider] = useState<Provider | null>(null);
  const [category, setCategory] = useState<Category | null>(null);
  const [loading, setLoading] = useState(true);
  const [serviceLocation, setServiceLocation] = useState('');
  const [scheduledDate, setScheduledDate] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    loadData();
  }, [providerId, categoryId]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [providerData, categoryData] = await Promise.all([
        getProviderById(providerId),
        getCategoryById(categoryId),
      ]);
      setProvider(providerData);
      setCategory(categoryData);
    } catch (error) {
      toast.error('Failed to load provider details');
    } finally {
      setLoading(false);
    }
  };

  const handlePayment = async () => {
    if (!user) {
      toast.error('Please sign in to book a service');
      router.push('/welcome');
      return;
    }

    if (!serviceLocation.trim()) {
      toast.error('Please enter service location');
      return;
    }

    setSubmitting(true);

    // TODO: Implement Razorpay payment
    // For now, simulate payment
    setTimeout(() => {
      toast.success('Booking request sent successfully!');
      router.push('/my-requests');
      setSubmitting(false);
    }, 2000);
  };

  if (loading) {
    return (
      <>
        <Navbar />
        <Container>
          <Box display="flex" justifyContent="center" alignItems="center" minHeight="50vh">
            <CircularProgress size={60} />
          </Box>
        </Container>
      </>
    );
  }

  if (!provider || !category) {
    return (
      <>
        <Navbar />
        <Container>
          <Box textAlign="center" py={8}>
            <Typography variant="h5">Provider not found</Typography>
          </Box>
        </Container>
      </>
    );
  }

  return (
    <>
      <Navbar />
      <Container maxWidth="md" sx={{ py: 4 }}>
        <Button
          startIcon={<ArrowBackIcon />}
          onClick={() => router.back()}
          sx={{ mb: 3 }}
        >
          Back
        </Button>

        <Typography variant="h3" gutterBottom fontWeight="bold">
          Book Service
        </Typography>

        {/* Provider Info */}
        <Card elevation={3} sx={{ mb: 3 }}>
          <CardContent sx={{ p: 3 }}>
            <Box display="flex" gap={2} mb={2}>
              <Avatar
                src={provider.profileImage}
                alt={provider.name}
                sx={{ width: 80, height: 80 }}
              />
              <Box>
                <Typography variant="h5" fontWeight="bold">
                  {provider.name}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {provider.category} - {provider.subcategory}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  📞 {provider.phone}
                </Typography>
              </Box>
            </Box>

            {provider.serviceRate && (
              <Box mt={2}>
                <Typography variant="h6" color="primary" fontWeight="bold">
                  Service Rate: ₹{provider.serviceRate}
                  {provider.rateDescription && (
                    <Typography component="span" variant="body2" color="text.secondary" ml={1}>
                      ({provider.rateDescription})
                    </Typography>
                  )}
                </Typography>
              </Box>
            )}
          </CardContent>
        </Card>

        {/* Booking Form */}
        <Card elevation={3}>
          <CardContent sx={{ p: 3 }}>
            <Typography variant="h5" gutterBottom fontWeight="bold">
              Service Details
            </Typography>
            <Divider sx={{ mb: 3 }} />

            <Grid container spacing={3}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Service Location *"
                  placeholder="Enter your complete address"
                  multiline
                  rows={3}
                  value={serviceLocation}
                  onChange={(e) => setServiceLocation(e.target.value)}
                  InputProps={{
                    startAdornment: <LocationOnIcon sx={{ mr: 1, color: 'action.active' }} />,
                  }}
                />
              </Grid>

              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Preferred Date & Time"
                  type="datetime-local"
                  value={scheduledDate}
                  onChange={(e) => setScheduledDate(e.target.value)}
                  InputLabelProps={{ shrink: true }}
                  InputProps={{
                    startAdornment: <CalendarMonthIcon sx={{ mr: 1, color: 'action.active' }} />,
                  }}
                />
              </Grid>

              <Grid item xs={12}>
                <Box bgcolor="info.light" p={2} borderRadius={1}>
                  <Typography variant="body2" fontWeight="bold" gutterBottom>
                    Payment Details
                  </Typography>
                  <Typography variant="body2">
                    Advance Payment: ₹{category.advanceFee}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Pay advance to confirm booking. Remaining amount after service completion.
                  </Typography>
                </Box>
              </Grid>

              <Grid item xs={12}>
                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  onClick={handlePayment}
                  disabled={submitting || !serviceLocation.trim()}
                  sx={{ py: 1.5 }}
                >
                  {submitting ? (
                    <>
                      <CircularProgress size={24} color="inherit" sx={{ mr: 1 }} />
                      Processing...
                    </>
                  ) : (
                    `Pay ₹${category.advanceFee} & Book Service`
                  )}
                </Button>
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      </Container>
    </>
  );
}
