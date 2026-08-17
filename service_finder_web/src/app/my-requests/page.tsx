'use client';

import { useEffect, useState } from 'react';
import {
  Container,
  Box,
  Typography,
  Card,
  CardContent,
  Chip,
  Grid,
  Skeleton,
} from '@mui/material';
import Navbar from '@/components/layout/Navbar';
import { getUserServiceRequests } from '@/lib/firebase/firestore';
import { useAuthStore } from '@/store/authStore';
import { ServiceRequest } from '@/types';
import { format } from 'date-fns';
import { toast } from 'react-toastify';

const statusColors: Record<ServiceRequest['status'], 'default' | 'warning' | 'info' | 'success' | 'error'> = {
  requested: 'warning',
  accepted: 'info',
  in_progress: 'info',
  completed: 'success',
  cancelled: 'error',
};

export default function MyRequestsPage() {
  const { user } = useAuthStore();
  const [requests, setRequests] = useState<ServiceRequest[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      loadRequests();
    }
  }, [user]);

  const loadRequests = async () => {
    if (!user) return;
    
    try {
      setLoading(true);
      const data = await getUserServiceRequests(user.userId);
      setRequests(data);
    } catch (error: any) {
      console.error('Error loading requests:', error);
      toast.error('Failed to load service requests');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Navbar />
      <Container maxWidth="xl" sx={{ py: 4 }}>
        {/* Header */}
        <Box mb={4}>
          <Typography variant="h3" gutterBottom fontWeight="bold">
            My Service Requests
          </Typography>
          <Typography variant="h6" color="text.secondary">
            Track all your service bookings
          </Typography>
        </Box>

        {/* Requests List */}
        {loading ? (
          <Grid container spacing={3}>
            {Array.from({ length: 3 }).map((_, index) => (
              <Grid item xs={12} key={index}>
                <Card>
                  <CardContent>
                    <Skeleton variant="text" width="40%" height={30} />
                    <Skeleton variant="text" width="60%" />
                    <Skeleton variant="text" width="80%" />
                    <Skeleton variant="rectangular" height={40} sx={{ mt: 2 }} />
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        ) : requests.length === 0 ? (
          <Box textAlign="center" py={8}>
            <Typography variant="h5" color="text.secondary" gutterBottom>
              No service requests yet
            </Typography>
            <Typography variant="body1" color="text.secondary">
              Book your first service to get started
            </Typography>
          </Box>
        ) : (
          <Grid container spacing={3}>
            {requests.map((request) => (
              <Grid item xs={12} key={request.requestId}>
                <Card elevation={3}>
                  <CardContent sx={{ p: 3 }}>
                    <Box display="flex" justifyContent="space-between" alignItems="start" mb={2}>
                      <Box>
                        <Typography variant="h5" fontWeight="bold" gutterBottom>
                          {request.category} - {request.subcategory}
                        </Typography>
                        <Chip
                          label={request.status.toUpperCase().replace('_', ' ')}
                          color={statusColors[request.status]}
                          size="small"
                        />
                      </Box>
                      <Typography variant="body2" color="text.secondary">
                        {format(new Date(request.requestedAt), 'MMM dd, yyyy')}
                      </Typography>
                    </Box>

                    <Grid container spacing={2}>
                      <Grid item xs={12} sm={6}>
                        <Typography variant="body2" color="text.secondary" gutterBottom>
                          Provider
                        </Typography>
                        <Typography variant="body1" fontWeight="bold">
                          {request.providerName}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          {request.providerPhone}
                        </Typography>
                      </Grid>

                      <Grid item xs={12} sm={6}>
                        <Typography variant="body2" color="text.secondary" gutterBottom>
                          Service Location
                        </Typography>
                        <Typography variant="body1">
                          {request.serviceLocation}
                        </Typography>
                      </Grid>

                      {request.scheduledDate && (
                        <Grid item xs={12} sm={6}>
                          <Typography variant="body2" color="text.secondary" gutterBottom>
                            Scheduled Date
                          </Typography>
                          <Typography variant="body1">
                            {format(new Date(request.scheduledDate), 'PPP')}
                          </Typography>
                        </Grid>
                      )}

                      <Grid item xs={12} sm={6}>
                        <Typography variant="body2" color="text.secondary" gutterBottom>
                          Payment
                        </Typography>
                        <Typography variant="body1" color="success.main" fontWeight="bold">
                          Advance: ₹{request.advancePaid}
                        </Typography>
                        {request.estimatedCharge && (
                          <Typography variant="body2" color="text.secondary">
                            Estimated Total: ₹{request.estimatedCharge}
                          </Typography>
                        )}
                      </Grid>

                      {request.completionNotes && (
                        <Grid item xs={12}>
                          <Typography variant="body2" color="text.secondary" gutterBottom>
                            Completion Notes
                          </Typography>
                          <Typography variant="body1">
                            {request.completionNotes}
                          </Typography>
                        </Grid>
                      )}
                    </Grid>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        )}
      </Container>
    </>
  );
}
