'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  IconButton,
  Menu,
  MenuItem,
  Avatar,
  Box,
  Container,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import HomeIcon from '@mui/icons-material/Home';
import SearchIcon from '@mui/icons-material/Search';
import RequestPageIcon from '@mui/icons-material/RequestPage';
import { useAuthStore } from '@/store/authStore';
import { signOut } from '@/lib/firebase/auth';
import { toast } from 'react-toastify';

export default function Navbar() {
  const router = useRouter();
  const { user, logout } = useAuthStore();
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [mobileMenuAnchor, setMobileMenuAnchor] = useState<null | HTMLElement>(null);

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleMobileMenu = (event: React.MouseEvent<HTMLElement>) => {
    setMobileMenuAnchor(event.currentTarget);
  };

  const handleMobileMenuClose = () => {
    setMobileMenuAnchor(null);
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

  const navigateTo = (path: string) => {
    router.push(path);
    handleClose();
    handleMobileMenuClose();
  };

  return (
    <AppBar position="sticky" elevation={2}>
      <Container maxWidth="xl">
        <Toolbar disableGutters>
          {/* Logo */}
          <Typography
            variant="h6"
            component="div"
            sx={{ flexGrow: { xs: 1, md: 0 }, mr: 4, cursor: 'pointer', fontWeight: 'bold' }}
            onClick={() => navigateTo('/dashboard')}
          >
            Service Finder
          </Typography>

          {/* Desktop Menu */}
          <Box sx={{ flexGrow: 1, display: { xs: 'none', md: 'flex' }, gap: 2 }}>
            <Button
              color="inherit"
              startIcon={<HomeIcon />}
              onClick={() => navigateTo('/dashboard')}
            >
              Home
            </Button>
            <Button
              color="inherit"
              startIcon={<SearchIcon />}
              onClick={() => navigateTo('/search')}
            >
              Search
            </Button>
            <Button
              color="inherit"
              startIcon={<RequestPageIcon />}
              onClick={() => navigateTo('/my-requests')}
            >
              My Requests
            </Button>
            <Button
              color="inherit"
              onClick={() => navigateTo('/register')}
            >
              Become Provider
            </Button>
            <Button
              color="inherit"
              onClick={() => navigateTo('/donation')}
            >
              Donate ❤️
            </Button>
          </Box>

          {/* Mobile Menu Icon */}
          <Box sx={{ display: { xs: 'flex', md: 'none' } }}>
            <IconButton
              size="large"
              aria-label="menu"
              onClick={handleMobileMenu}
              color="inherit"
            >
              <MenuIcon />
            </IconButton>
          </Box>

          {/* User Menu */}
          {user && (
            <Box>
              <IconButton onClick={handleMenu} sx={{ p: 0 }}>
                <Avatar
                  alt={user.displayName || 'User'}
                  src={user.photoUrl}
                  sx={{ width: 40, height: 40 }}
                />
              </IconButton>
              <Menu
                anchorEl={anchorEl}
                open={Boolean(anchorEl)}
                onClose={handleClose}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
                transformOrigin={{ vertical: 'top', horizontal: 'right' }}
              >
                <MenuItem disabled>
                  <Typography variant="body2" fontWeight="bold">
                    {user.displayName || 'User'}
                  </Typography>
                </MenuItem>
                <MenuItem onClick={() => navigateTo('/profile')}>Profile</MenuItem>
                <MenuItem onClick={() => navigateTo('/my-requests')}>My Requests</MenuItem>
                <MenuItem onClick={handleSignOut}>Sign Out</MenuItem>
              </Menu>
            </Box>
          )}

          {/* Mobile Menu */}
          <Menu
            anchorEl={mobileMenuAnchor}
            open={Boolean(mobileMenuAnchor)}
            onClose={handleMobileMenuClose}
          >
            <MenuItem onClick={() => navigateTo('/dashboard')}>
              <HomeIcon sx={{ mr: 1 }} /> Home
            </MenuItem>
            <MenuItem onClick={() => navigateTo('/search')}>
              <SearchIcon sx={{ mr: 1 }} /> Search
            </MenuItem>
            <MenuItem onClick={() => navigateTo('/my-requests')}>
              <RequestPageIcon sx={{ mr: 1 }} /> My Requests
            </MenuItem>
            <MenuItem onClick={() => navigateTo('/register')}>
              Become Provider
            </MenuItem>
            <MenuItem onClick={() => navigateTo('/donation')}>
              Donate ❤️
            </MenuItem>
          </Menu>
        </Toolbar>
      </Container>
    </AppBar>
  );
}
