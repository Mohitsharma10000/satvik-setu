'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  Container,
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  CircularProgress,
} from '@mui/material';
import GoogleIcon from '@mui/icons-material/Google';
import { signInWithGoogle } from '@/lib/firebase/auth';
import { useAuthStore } from '@/store/authStore';
import { toast } from 'react-toastify';

export default function WelcomePage() {
  const router = useRouter();
  const { setUser } = useAuthStore();
  const [loading, setLoading] = useState(false);

  const handleGoogleSignIn = async () => {
    try {
      setLoading(true);
      const user = await signInWithGoogle();
      setUser(user);
      toast.success('Welcome to Service Finder!');
      router.push('/dashboard');
    } catch (error: any) {
      console.error('Sign in error:', error);
      toast.error(error.message || 'Failed to sign in');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ minHeight: '100vh', py: 8 }}>
        {/* Header */}
        <Box textAlign="center" mb={8}>
          <Typography variant="h2" gutterBottom fontWeight="bold" color="primary">
            Service Finder
          </Typography>
          <Typography variant="h5" color="text.secondary" mb={4}>
            Connect with Verified Local Service Providers
          </Typography>
        </Box>

        {/* Features Grid */}
        <Grid container spacing={4} mb={6}>
          <Grid item xs={12} md={4}>
            <Card elevation={3}>
              <CardContent>
                <Typography variant="h5" gutterBottom color="primary">
                  🔍 Easy Search
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  Find verified service providers in your area with just a few clicks
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card elevation={3}>
              <CardContent>
                <Typography variant="h5" gutterBottom color="primary">
                  ✅ Verified Providers
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  All service providers are thoroughly verified for your safety
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card elevation={3}>
              <CardContent>
                <Typography variant="h5" gutterBottom color="primary">
                  💳 Secure Payments
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  Safe and secure online payments through Razorpay
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Sign In Section */}
        <Box textAlign="center">
          <Card elevation={4} sx={{ maxWidth: 500, mx: 'auto', p: 4 }}>
            <CardContent>
              <Typography variant="h4" gutterBottom>
                Get Started
              </Typography>
              <Typography variant="body1" color="text.secondary" mb={4}>
                Sign in to find and book local services
              </Typography>
              <Button
                variant="contained"
                size="large"
                fullWidth
                startIcon={loading ? <CircularProgress size={20} color="inherit" /> : <GoogleIcon />}
                onClick={handleGoogleSignIn}
                disabled={loading}
                sx={{ py: 1.5 }}
              >
                {loading ? 'Signing in...' : 'Continue with Google'}
              </Button>
            </CardContent>
          </Card>
        </Box>

        {/* Footer */}
        <Box textAlign="center" mt={6}>
          <Typography variant="body2" color="text.secondary">
            By signing in, you agree to our Terms of Service and Privacy Policy
          </Typography>
        </Box>
      </Box>
    </Container>
  );
}
