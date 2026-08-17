'use client';

import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Chip,
  Avatar,
  Skeleton,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import PhoneIcon from '@mui/icons-material/Phone';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import Navbar from '@/components/layout/Navbar';
import { getProviders, getSubcategoryById } from '@/lib/firebase/firestore';
import { Provider, Subcategory } from '@/types';
import { toast } from 'react-toastify';

export default function ProviderListPage() {
  const router = useRouter();
  const params = useParams();
  const categoryId = params.categoryId as string;
  const subcategoryId = params.subcategoryId as string;

  const [subcategory, setSubcategory] = useState<Subcategory | null>(null);
  const [providers, setProviders] = useState<Provider[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (categoryId && subcategoryId) {
      loadData();
    }
  }, [categoryId, subcategoryId]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [subcategoryData, providersData] = await Promise.all([
        getSubcategoryById(subcategoryId),
        getProviders(categoryId, subcategoryId),
      ]);
      setSubcategory(subcategoryData);
      setProviders(providersData);
    } catch (error: any) {
      console.error('Error loading providers:', error);
      toast.error('Failed to load providers');
    } finally {
      setLoading(false);
    }
  };

  const handleBookService = (provider: Provider) => {
    router.push(
      `/booking/${provider.providerId}?categoryId=${categoryId}&subcategoryId=${subcategoryId}`
    );
  };

  return (
    <>
      <Navbar />
      <Container maxWidth="xl" sx={{ py: 4 }}>
        {/* Back Button */}
        <Button
          startIcon={<ArrowBackIcon />}
          onClick={() => router.back()}
          sx={{ mb: 3 }}
        >
          Back
        </Button>

        {/* Header */}
        <Box mb={4}>
          <Typography variant="h3" gutterBottom fontWeight="bold">
            {loading ? <Skeleton width={300} /> : subcategory?.name || 'Providers'}
          </Typography>
          <Typography variant="h6" color="text.secondary">
            Verified service providers in your area
          </Typography>
        </Box>

        {/* Providers List */}
        <Grid container spacing={3}>
          {loading ? (
            Array.from({ length: 4 }).map((_, index) => (
              <Grid item xs={12} md={6} key={index}>
                <Card>
                  <CardContent>
                    <Skeleton variant="circular" width={60} height={60} sx={{ mb: 2 }} />
                    <Skeleton variant="text" width="60%" height={30} />
                    <Skeleton variant="text" width="80%" />
                    <Skeleton variant="rectangular" width="100%" height={40} sx={{ mt: 2 }} />
                  </CardContent>
                </Card>
              </Grid>
            ))
          ) : providers.length === 0 ? (
            <Grid item xs={12}>
              <Box textAlign="center" py={8}>
                <Typography variant="h5" color="text.secondary" gutterBottom>
                  No providers available
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  Please check back later or try a different service
                </Typography>
              </Box>
            </Grid>
          ) : (
            providers.map((provider) => (
              <Grid item xs={12} md={6} key={provider.providerId}>
                <Card elevation={3}>
                  <CardContent sx={{ p: 3 }}>
                    <Box display="flex" gap={2} mb={2}>
                      <Avatar
                        src={provider.profileImage}
                        alt={provider.name}
                        sx={{ width: 64, height: 64 }}
                      />
                      <Box flex={1}>
                        <Typography variant="h5" fontWeight="bold" gutterBottom>
                          {provider.name}
                        </Typography>
                        <Chip
                          label="✓ Verified"
                          color="success"
                          size="small"
                          sx={{ mb: 1 }}
                        />
                      </Box>
                    </Box>

                    <Box display="flex" alignItems="center" gap={1} mb={1}>
                      <PhoneIcon fontSize="small" color="action" />
                      <Typography variant="body2" color="text.secondary">
                        {provider.phone}
                      </Typography>
                    </Box>

                    {provider.address && (
                      <Box display="flex" alignItems="start" gap={1} mb={2}>
                        <LocationOnIcon fontSize="small" color="action" />
                        <Typography variant="body2" color="text.secondary">
                          {provider.city}, {provider.state} {provider.pincode}
                        </Typography>
                      </Box>
                    )}

                    {provider.serviceRate && (
                      <Box mb={2}>
                        <Typography variant="h6" color="primary" fontWeight="bold">
                          ₹{provider.serviceRate}
                          {provider.rateDescription && (
                            <Typography
                              component="span"
                              variant="body2"
                              color="text.secondary"
                              ml={1}
                            >
                              {provider.rateDescription}
                            </Typography>
                          )}
                        </Typography>
                      </Box>
                    )}

                    <Button
                      variant="contained"
                      fullWidth
                      size="large"
                      onClick={() => handleBookService(provider)}
                    >
                      Book Service
                    </Button>
                  </CardContent>
                </Card>
              </Grid>
            ))
          )}
        </Grid>
      </Container>
    </>
  );
}
