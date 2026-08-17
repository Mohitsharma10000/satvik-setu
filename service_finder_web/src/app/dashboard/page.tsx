'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  Container,
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  CardActionArea,
  CircularProgress,
  Skeleton,
  AppBar,
  Toolbar,
  IconButton,
  Avatar,
  Menu,
  MenuItem,
  TextField,
  InputAdornment,
  Button,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LightModeIcon from '@mui/icons-material/LightMode';
import AssignmentIcon from '@mui/icons-material/Assignment';
import WorkIcon from '@mui/icons-material/Work';
import StorefrontIcon from '@mui/icons-material/Storefront';
import FavoriteIcon from '@mui/icons-material/Favorite';
import { getCategories } from '@/lib/firebase/firestore';
import { Category } from '@/types';
import { toast } from 'react-toastify';
import { useAuthStore } from '@/store/authStore';
import { signOut } from '@/lib/firebase/auth';

export default function DashboardPage() {
  const router = useRouter();
  const { user, logout } = useAuthStore();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);

  useEffect(() => {
    loadCategories();
  }, []);

  const loadCategories = async () => {
    try {
      setLoading(true);
      const data = await getCategories();
      setCategories(data);
    } catch (error: any) {
      console.error('Error loading categories:', error);
      toast.error('Failed to load categories');
    } finally {
      setLoading(false);
    }
  };

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleSignOut = async () => {
    try {
      await signOut();
      logout();
      toast.success('Signed out successfully');
      router.push('/welcome');
    } catch (error) {
      toast.error('Failed to sign out');
    }
    handleClose();
  };

  const handleCategoryClick = (category: Category) => {
    router.push(`/category/${category.id}`);
  };

  return (
    <Box sx={{ flexGrow: 1 }}>
      {/* AppBar - Exact Flutter Style */}
      <AppBar 
        position="sticky" 
        elevation={0} 
        sx={{ 
          bgcolor: 'background.paper',
          borderBottom: '1px solid rgba(0,0,0,0.08)',
        }}
      >
        <Toolbar>
          <Avatar 
            src="/app_logo.png" 
            alt="Logo" 
            sx={{ width: 40, height: 40, mr: 2 }}
          />
          <Typography 
            variant="h6" 
            sx={{ flexGrow: 1, fontWeight: 'bold', color: 'text.primary' }}
          >
            Service Finder
          </Typography>
          <IconButton color="default">
            <LightModeIcon />
          </IconButton>
          {user && (
            <>
              <IconButton onClick={handleMenu}>
                <Avatar src={user.photoUrl} alt={user.displayName || 'User'} />
              </IconButton>
              <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={handleClose}>
                <MenuItem onClick={() => { router.push('/profile'); handleClose(); }}>
                  Profile
                </MenuItem>
                <MenuItem onClick={handleSignOut}>Sign Out</MenuItem>
              </Menu>
            </>
          )}
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 2, mb: 4 }}>
        {/* Search Bar - Exact Flutter Style */}
        <Box 
          onClick={() => router.push('/search')}
          sx={{
            p: 2,
            bgcolor: '#F5F5F5',
            borderRadius: '12px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            mb: 3,
            '&:hover': {
              bgcolor: '#EEEEEE',
            },
          }}
        >
          <SearchIcon sx={{ color: 'grey.600', mr: 1.5 }} />
          <Typography sx={{ color: 'grey.600' }}>
            Search for services, providers...
          </Typography>
        </Box>

        {/* Categories Header */}
        <Typography variant="h5" fontWeight="bold" sx={{ mb: 2, ml: 0.5 }}>
          Categories
        </Typography>

        {/* Categories Grid - 3 columns like Flutter */}
        <Grid container spacing={2}>
          {loading ? (
            // Skeleton Loaders
            Array.from({ length: 9 }).map((_, index) => (
              <Grid item xs={4} sm={4} md={4} key={index}>
                <Card sx={{ borderRadius: '16px' }}>
                  <CardContent sx={{ textAlign: 'center', py: 2.5 }}>
                    <Skeleton variant="rectangular" width={60} height={60} sx={{ mx: 'auto', mb: 1, borderRadius: '12px' }} />
                    <Skeleton variant="text" width="80%" sx={{ mx: 'auto' }} />
                  </CardContent>
                </Card>
              </Grid>
            ))
          ) : categories.length === 0 ? (
            <Grid item xs={12}>
              <Box textAlign="center" py={6}>
                <Typography variant="h6" color="text.secondary">
                  No categories found
                </Typography>
              </Box>
            </Grid>
          ) : (
            categories.map((category) => (
              <Grid item xs={4} sm={4} md={4} key={category.id}>
                <Card
                  elevation={2}
                  sx={{
                    borderRadius: '16px',
                    transition: 'transform 0.2s, box-shadow 0.2s',
                    '&:hover': {
                      transform: 'scale(1.02)',
                      boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                    },
                  }}
                >
                  <CardActionArea
                    onClick={() => handleCategoryClick(category)}
                    sx={{ p: 2 }}
                  >
                    <CardContent sx={{ textAlign: 'center', p: 0 }}>
                      <Box
                        sx={{
                          fontSize: '3rem',
                          mb: 1,
                          height: 60,
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                        }}
                      >
                        {category.icon}
                      </Box>
                      <Typography
                        variant="body2"
                        fontWeight="600"
                        sx={{
                          fontSize: '0.875rem',
                          lineHeight: 1.3,
                          minHeight: 32,
                        }}
                      >
                        {category.name}
                      </Typography>
                    </CardContent>
                  </CardActionArea>
                </Card>
              </Grid>
            ))
          )}
        </Grid>

        {/* Action Buttons - Exact Flutter Style */}
        <Box sx={{ mt: 4 }}>
          <Button
            fullWidth
            variant="outlined"
            startIcon={<AssignmentIcon />}
            onClick={() => router.push('/my-requests')}
            sx={{
              mb: 1.5,
              py: 1.5,
              borderRadius: '16px',
              textTransform: 'none',
              fontSize: '1rem',
              justifyContent: 'flex-start',
              pl: 2.5,
            }}
          >
            My Service Requests
          </Button>

          <Button
            fullWidth
            variant="contained"
            startIcon={<WorkIcon />}
            onClick={() => router.push('/register')}
            sx={{
              mb: 1.5,
              py: 1.5,
              borderRadius: '16px',
              textTransform: 'none',
              fontSize: '1rem',
            }}
          >
            Become a Service Provider
          </Button>

          <Button
            fullWidth
            variant="outlined"
            startIcon={<StorefrontIcon />}
            onClick={() => router.push('/provider/dashboard')}
            sx={{
              mb: 1.5,
              py: 1.5,
              borderRadius: '16px',
              textTransform: 'none',
              fontSize: '1rem',
              justifyContent: 'flex-start',
              pl: 2.5,
              color: 'teal',
              borderColor: 'teal',
            }}
          >
            Provider Portal Login
          </Button>

          <Button
            fullWidth
            variant="outlined"
            startIcon={<FavoriteIcon />}
            onClick={() => router.push('/donation')}
            sx={{
              py: 1.75,
              borderRadius: '16px',
              textTransform: 'none',
              fontSize: '1rem',
              justifyContent: 'flex-start',
              pl: 2.5,
              color: 'error.main',
              borderColor: 'error.main',
            }}
          >
            Support Us
          </Button>
        </Box>
      </Container>
    </Box>
  );
}
