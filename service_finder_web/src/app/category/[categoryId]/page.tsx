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
  CardActionArea,
  Button,
  Skeleton,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import Navbar from '@/components/layout/Navbar';
import { getCategoryById, getSubcategories } from '@/lib/firebase/firestore';
import { Category, Subcategory } from '@/types';
import { toast } from 'react-toastify';

export default function CategoryPage() {
  const router = useRouter();
  const params = useParams();
  const categoryId = params.categoryId as string;

  const [category, setCategory] = useState<Category | null>(null);
  const [subcategories, setSubcategories] = useState<Subcategory[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (categoryId) {
      loadData();
    }
  }, [categoryId]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [categoryData, subcategoriesData] = await Promise.all([
        getCategoryById(categoryId),
        getSubcategories(categoryId),
      ]);
      setCategory(categoryData);
      setSubcategories(subcategoriesData);
    } catch (error: any) {
      console.error('Error loading data:', error);
      toast.error('Failed to load subcategories');
    } finally {
      setLoading(false);
    }
  };

  const handleSubcategoryClick = (subcategory: Subcategory) => {
    router.push(`/category/${categoryId}/subcategory/${subcategory.id}`);
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
            {loading ? <Skeleton width={300} /> : category?.name || 'Category'}
          </Typography>
          <Typography variant="h6" color="text.secondary">
            Choose a specific service
          </Typography>
        </Box>

        {/* Subcategories Grid */}
        <Grid container spacing={3}>
          {loading ? (
            Array.from({ length: 6 }).map((_, index) => (
              <Grid item xs={12} sm={6} md={4} key={index}>
                <Card>
                  <CardContent>
                    <Skeleton variant="rectangular" height={60} sx={{ mb: 2 }} />
                    <Skeleton variant="text" width="60%" />
                  </CardContent>
                </Card>
              </Grid>
            ))
          ) : subcategories.length === 0 ? (
            <Grid item xs={12}>
              <Box textAlign="center" py={8}>
                <Typography variant="h5" color="text.secondary">
                  No services available in this category
                </Typography>
              </Box>
            </Grid>
          ) : (
            subcategories.map((subcategory) => (
              <Grid item xs={12} sm={6} md={4} key={subcategory.id}>
                <Card
                  elevation={3}
                  sx={{
                    height: '100%',
                    transition: 'transform 0.2s, box-shadow 0.2s',
                    '&:hover': {
                      transform: 'translateY(-4px)',
                      boxShadow: 6,
                    },
                  }}
                >
                  <CardActionArea
                    onClick={() => handleSubcategoryClick(subcategory)}
                    sx={{ height: '100%', p: 3 }}
                  >
                    <CardContent>
                      <Typography variant="h5" fontWeight="bold" gutterBottom>
                        {subcategory.name}
                      </Typography>
                      <Typography variant="body2" color="primary">
                        View Providers →
                      </Typography>
                    </CardContent>
                  </CardActionArea>
                </Card>
              </Grid>
            ))
          )}
        </Grid>
      </Container>
    </>
  );
}
