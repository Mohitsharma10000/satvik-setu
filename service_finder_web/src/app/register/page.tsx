'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import {
  Container,
  Box,
  Typography,
  Card,
  CardContent,
  TextField,
  Button,
  Grid,
  MenuItem,
  CircularProgress,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import PersonIcon from '@mui/icons-material/Person';
import PhoneIcon from '@mui/icons-material/Phone';
import EmailIcon from '@mui/icons-material/Email';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import Navbar from '@/components/layout/Navbar';
import { getCategories, getSubcategories } from '@/lib/firebase/firestore';
import { Category, Subcategory } from '@/types';
import { toast } from 'react-toastify';

export default function RegistrationPage() {
  const router = useRouter();
  const [categories, setCategories] = useState<Category[]>([]);
  const [subcategories, setSubcategories] = useState<Subcategory[]>([]);
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    email: '',
    categoryId: '',
    subcategoryId: '',
    address: '',
    city: '',
    state: '',
    pincode: '',
    serviceRate: '',
    rateDescription: '',
  });

  useEffect(() => {
    loadCategories();
  }, []);

  useEffect(() => {
    if (formData.categoryId) {
      loadSubcategories(formData.categoryId);
    }
  }, [formData.categoryId]);

  const loadCategories = async () => {
    try {
      const data = await getCategories();
      setCategories(data);
    } catch (error) {
      toast.error('Failed to load categories');
    }
  };

  const loadSubcategories = async (categoryId: string) => {
    try {
      const data = await getSubcategories(categoryId);
      setSubcategories(data);
    } catch (error) {
      toast.error('Failed to load subcategories');
    }
  };

  const handleChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async () => {
    // Validation
    if (!formData.name || !formData.phone || !formData.categoryId || !formData.subcategoryId) {
      toast.error('Please fill all required fields');
      return;
    }

    setSubmitting(true);

    // TODO: Implement Firestore save
    // For now, simulate submission
    setTimeout(() => {
      toast.success('Application submitted successfully! We will review and contact you.');
      router.push('/welcome');
      setSubmitting(false);
    }, 2000);
  };

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
          Provider Registration
        </Typography>
        <Typography variant="h6" color="text.secondary" mb={4}>
          Register as a service provider
        </Typography>

        <Card elevation={3}>
          <CardContent sx={{ p: 3 }}>
            <Grid container spacing={3}>
              {/* Personal Info */}
              <Grid item xs={12}>
                <Typography variant="h6" gutterBottom fontWeight="bold">
                  Personal Information
                </Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  required
                  label="Full Name"
                  value={formData.name}
                  onChange={(e) => handleChange('name', e.target.value)}
                  InputProps={{
                    startAdornment: <PersonIcon sx={{ mr: 1, color: 'action.active' }} />,
                  }}
                />
              </Grid>

              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  required
                  label="Phone Number"
                  value={formData.phone}
                  onChange={(e) => handleChange('phone', e.target.value)}
                  InputProps={{
                    startAdornment: <PhoneIcon sx={{ mr: 1, color: 'action.active' }} />,
                  }}
                />
              </Grid>

              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleChange('email', e.target.value)}
                  InputProps={{
                    startAdornment: <EmailIcon sx={{ mr: 1, color: 'action.active' }} />,
                  }}
                />
              </Grid>

              {/* Service Info */}
              <Grid item xs={12}>
                <Typography variant="h6" gutterBottom fontWeight="bold" mt={2}>
                  Service Details
                </Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  required
                  select
                  label="Category"
                  value={formData.categoryId}
                  onChange={(e) => {
                    handleChange('categoryId', e.target.value);
                    handleChange('subcategoryId', '');
                  }}
                >
                  {categories.map((cat) => (
                    <MenuItem key={cat.id} value={cat.id}>
                      {cat.icon} {cat.name}
                    </MenuItem>
                  ))}
                </TextField>
              </Grid>

              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  required
                  select
                  label="Subcategory"
                  value={formData.subcategoryId}
                  onChange={(e) => handleChange('subcategoryId', e.target.value)}
                  disabled={!formData.categoryId}
                >
                  {subcategories.map((sub) => (
                    <MenuItem key={sub.id} value={sub.id}>
                      {sub.name}
                    </MenuItem>
                  ))}
                </TextField>
              </Grid>

              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  label="Service Rate (₹)"
                  type="number"
                  value={formData.serviceRate}
                  onChange={(e) => handleChange('serviceRate', e.target.value)}
                />
              </Grid>

              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  label="Rate Description"
                  placeholder="per hour / per visit"
                  value={formData.rateDescription}
                  onChange={(e) => handleChange('rateDescription', e.target.value)}
                />
              </Grid>

              {/* Address */}
              <Grid item xs={12}>
                <Typography variant="h6" gutterBottom fontWeight="bold" mt={2}>
                  Address
                </Typography>
              </Grid>

              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  label="Street Address"
                  multiline
                  rows={2}
                  value={formData.address}
                  onChange={(e) => handleChange('address', e.target.value)}
                  InputProps={{
                    startAdornment: <LocationOnIcon sx={{ mr: 1, color: 'action.active' }} />,
                  }}
                />
              </Grid>

              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  required
                  label="City"
                  value={formData.city}
                  onChange={(e) => handleChange('city', e.target.value)}
                />
              </Grid>

              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  required
                  label="State"
                  value={formData.state}
                  onChange={(e) => handleChange('state', e.target.value)}
                />
              </Grid>

              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  required
                  label="Pincode"
                  value={formData.pincode}
                  onChange={(e) => handleChange('pincode', e.target.value)}
                />
              </Grid>

              {/* Submit */}
              <Grid item xs={12}>
                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  onClick={handleSubmit}
                  disabled={submitting}
                  sx={{ py: 1.5, mt: 2 }}
                >
                  {submitting ? (
                    <>
                      <CircularProgress size={24} color="inherit" sx={{ mr: 1 }} />
                      Submitting...
                    </>
                  ) : (
                    'Submit Application'
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
