'use client';

import { createTheme } from '@mui/material/styles';

// Exact colors from Flutter app (app_colors.dart)
const AppColors = {
  primary: '#1E88E5',
  secondary: '#42A5F5',
  tertiary: '#90CAF9',
  success: '#4CAF50',
  warning: '#FFC107',
  error: '#E53935',
  info: '#29B6F6',
  verifiedBadge: '#009688',
  surfaceLight: '#FFFFFF',
  backgroundLight: '#F5F5F5',
  surfaceDark: '#1E1E1E',
  backgroundDark: '#121212',
};

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: AppColors.primary,
      light: AppColors.secondary,
      dark: '#1565C0',
    },
    secondary: {
      main: AppColors.secondary,
      light: AppColors.tertiary,
      dark: AppColors.primary,
    },
    success: {
      main: AppColors.success,
    },
    error: {
      main: AppColors.error,
    },
    warning: {
      main: AppColors.warning,
    },
    info: {
      main: AppColors.info,
    },
    background: {
      default: AppColors.backgroundLight,
      paper: AppColors.surfaceLight,
    },
  },
  typography: {
    // Using system fonts to match Inter (body) and Poppins (headings)
    fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, sans-serif',
    h1: {
      fontFamily: 'Poppins, sans-serif',
      fontWeight: 700,
      fontSize: '2.5rem',
    },
    h2: {
      fontFamily: 'Poppins, sans-serif',
      fontWeight: 700,
      fontSize: '2rem',
    },
    h3: {
      fontFamily: 'Poppins, sans-serif',
      fontWeight: 700,
      fontSize: '1.75rem',
    },
    h4: {
      fontFamily: 'Poppins, sans-serif',
      fontWeight: 600,
      fontSize: '1.5rem',
    },
    h5: {
      fontFamily: 'Poppins, sans-serif',
      fontWeight: 600,
      fontSize: '1.25rem',
    },
    h6: {
      fontFamily: 'Poppins, sans-serif',
      fontWeight: 600,
      fontSize: '1rem',
    },
    body1: {
      fontFamily: 'Inter, sans-serif',
    },
    body2: {
      fontFamily: 'Inter, sans-serif',
    },
  },
  shape: {
    borderRadius: 12, // Matching Flutter's 12px border radius
  },
  components: {
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 16, // Matching Flutter's card border radius
          elevation: 2,
          boxShadow: '0 2px 8px rgba(0,0,0,0.08)',
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          textTransform: 'none',
          padding: '12px 24px',
          fontWeight: 600,
          boxShadow: 'none',
          '&:hover': {
            boxShadow: 'none',
          },
        },
        contained: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: 'none',
          },
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: 12,
            backgroundColor: '#F5F5F5',
            '& fieldset': {
              border: 'none',
            },
            '&:hover fieldset': {
              border: 'none',
            },
            '&.Mui-focused fieldset': {
              border: `2px solid ${AppColors.primary}`,
            },
          },
          '& .MuiInputBase-input': {
            padding: '16px',
          },
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          boxShadow: 'none',
          borderBottom: '1px solid rgba(0,0,0,0.08)',
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          fontWeight: 600,
        },
      },
    },
  },
});

export default theme;
