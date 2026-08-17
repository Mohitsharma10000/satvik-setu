'use client';

import {
  Container,
  Box,
  Typography,
  Card,
  CardContent,
  Avatar,
  Grid,
  Divider,
  Button,
} from '@mui/material';
import EmailIcon from '@mui/icons-material/Email';
import PhoneIcon from '@mui/icons-material/Phone';
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth';
import VerifiedIcon from '@mui/icons-material/Verified';
import Navbar from '@/components/layout/Navbar';
import { useAuthStore } from '@/store/authStore';
import { format } from 'date-fns';
import { useRouter } from 'next/navigation';

export default function ProfilePage() {
  const router = useRouter();
  const { user } = useAuthStore();

  if (!user) {
    return (
      <>
        <Navbar />
        <Container>
          <Box textAlign="center" py={8}>
            <Typography variant="h5">Please sign in to view profile</Typography>
            <Button variant="contained" onClick={() => router.push('/welcome')} sx={{ mt: 2 }}>
              Sign In
            </Button>
          </Box>
        </Container>
      </>
    );
  }

  return (
    <>
      <Navbar />
      <Container maxWidth="md" sx={{ py: 4 }}>
        <Typography variant="h3" gutterBottom fontWeight="bold">
          My Profile
        </Typography>

        <Card elevation={3} sx={{ mt: 3 }}>
          <CardContent sx={{ p: 4 }}>
            {/* Profile Header */}
            <Box display="flex" flexDirection="column" alignItems="center" mb={4}>
              <Avatar
                src={user.photoUrl}
                alt={user.displayName || 'User'}
                sx={{ width: 120, height: 120, mb: 2 }}
              />
              <Typography variant="h4" fontWeight="bold" gutterBottom>
                {user.displayName || 'User'}
              </Typography>
              {user.isVerified && (
                <Box display="flex" alignItems="center" gap={0.5} color="success.main">
                  <VerifiedIcon fontSize="small" />
                  <Typography variant="body2">Verified Account</Typography>
                </Box>
              )}
            </Box>

            <Divider sx={{ mb: 3 }} />

            {/* Profile Details */}
            <Grid container spacing={3}>
              {user.email && (
                <Grid item xs={12}>
                  <Box display="flex" alignItems="center" gap={2}>
                    <EmailIcon color="action" />
                    <Box>
                      <Typography variant="body2" color="text.secondary">
                        Email
                      </Typography>
                      <Typography variant="body1">{user.email}</Typography>
                    </Box>
                  </Box>
                </Grid>
              )}

              {user.phone && (
                <Grid item xs={12}>
                  <Box display="flex" alignItems="center" gap={2}>
                    <PhoneIcon color="action" />
                    <Box>
                      <Typography variant="body2" color="text.secondary">
                        Phone
                      </Typography>
                      <Typography variant="body1">{user.phone}</Typography>
                    </Box>
                  </Box>
                </Grid>
              )}

              <Grid item xs={12}>
                <Box display="flex" alignItems="center" gap={2}>
                  <CalendarMonthIcon color="action" />
                  <Box>
                    <Typography variant="body2" color="text.secondary">
                      Member Since
                    </Typography>
                    <Typography variant="body1">
                      {format(new Date(user.createdAt), 'MMMM dd, yyyy')}
                    </Typography>
                  </Box>
                </Box>
              </Grid>

              <Grid item xs={12}>
                <Box display="flex" alignItems="center" gap={2}>
                  <CalendarMonthIcon color="action" />
                  <Box>
                    <Typography variant="body2" color="text.secondary">
                      Last Login
                    </Typography>
                    <Typography variant="body1">
                      {format(new Date(user.lastLoginAt), 'PPp')}
                    </Typography>
                  </Box>
                </Box>
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />

            {/* Actions */}
            <Grid container spacing={2}>
              <Grid item xs={12} sm={6}>
                <Button
                  fullWidth
                  variant="outlined"
                  onClick={() => router.push('/my-requests')}
                >
                  View My Requests
                </Button>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Button
                  fullWidth
                  variant="outlined"
                  onClick={() => router.push('/register')}
                >
                  Become Provider
                </Button>
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      </Container>
    </>
  );
}
