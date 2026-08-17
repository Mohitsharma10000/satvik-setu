'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  Container,
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  Grid,
  TextField,
  Chip,
  CircularProgress,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import FavoriteIcon from '@mui/icons-material/Favorite';
import Navbar from '@/components/layout/Navbar';
import { toast } from 'react-toastify';

const SUGGESTED_AMOUNTS = [10, 50, 100, 500, 1000];

export default function DonationPage() {
  const router = useRouter();
  const [customAmount, setCustomAmount] = useState('');
  const [selectedAmount, setSelectedAmount] = useState<number | null>(null);
  const [processing, setProcessing] = useState(false);

  const handleAmountSelect = (amount: number) => {
    setSelectedAmount(amount);
    setCustomAmount('');
  };

  const handleCustomAmountChange = (value: string) => {
    setCustomAmount(value);
    setSelectedAmount(null);
  };

  const handleDonate = async () => {
    const amount = selectedAmount || parseFloat(customAmount);
    
    if (!amount || amount <= 0) {
      toast.error('Please enter a valid amount');
      return;
    }

    setProcessing(true);

    // TODO: Implement Razorpay payment
    setTimeout(() => {
      toast.success('Thank you for your donation! 🙏');
      router.push('/dashboard');
      setProcessing(false);
    }, 2000);
  };

  return (
    <>
      <Navbar />
      <Container maxWidth="sm" sx={{ py: 4 }}>
        <Button
          startIcon={<ArrowBackIcon />}
          onClick={() => router.back()}
          sx={{ mb: 3 }}
        >
          Back
        </Button>

        <Card elevation={3}>
          <CardContent sx={{ p: 4, textAlign: 'center' }}>
            <FavoriteIcon sx={{ fontSize: 80, color: 'error.main', mb: 2 }} />
            
            <Typography variant="h3" gutterBottom fontWeight="bold">
              Support Us
            </Typography>
            
            <Typography variant="h6" color="text.secondary" mb={4}>
              Your donation helps us maintain and improve our services
            </Typography>

            {/* Suggested Amounts */}
            <Box mb={4}>
              <Typography variant="body2" color="text.secondary" mb={2}>
                Select Amount
              </Typography>
              <Grid container spacing={2} justifyContent="center">
                {SUGGESTED_AMOUNTS.map((amount) => (
                  <Grid item key={amount}>
                    <Chip
                      label={`₹${amount}`}
                      clickable
                      color={selectedAmount === amount ? 'primary' : 'default'}
                      onClick={() => handleAmountSelect(amount)}
                      sx={{
                        fontSize: '1rem',
                        py: 2.5,
                        px: 1,
                        fontWeight: 'bold',
                      }}
                    />
                  </Grid>
                ))}
              </Grid>
            </Box>

            {/* Custom Amount */}
            <Box mb={4}>
              <Typography variant="body2" color="text.secondary" mb={2}>
                Or Enter Custom Amount
              </Typography>
              <TextField
                fullWidth
                type="number"
                placeholder="Enter amount"
                value={customAmount}
                onChange={(e) => handleCustomAmountChange(e.target.value)}
                InputProps={{
                  startAdornment: <Typography sx={{ mr: 1 }}>₹</Typography>,
                }}
              />
            </Box>

            {/* Donate Button */}
            <Button
              fullWidth
              variant="contained"
              size="large"
              color="error"
              onClick={handleDonate}
              disabled={processing || (!selectedAmount && !customAmount)}
              sx={{ py: 1.5 }}
            >
              {processing ? (
                <>
                  <CircularProgress size={24} color="inherit" sx={{ mr: 1 }} />
                  Processing...
                </>
              ) : (
                <>
                  <FavoriteIcon sx={{ mr: 1 }} />
                  Donate ₹{selectedAmount || customAmount || 0}
                </>
              )}
            </Button>

            <Typography variant="caption" color="text.secondary" mt={2} display="block">
              Secure payment powered by Razorpay
            </Typography>
          </CardContent>
        </Card>
      </Container>
    </>
  );
}
