'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Container, Box, CircularProgress } from '@mui/material';
import { useAuthStore } from '@/store/authStore';

export default function Home() {
  const router = useRouter();
  const { user, loading } = useAuthStore();

  useEffect(() => {
    if (!loading) {
      if (user) {
        router.push('/dashboard');
      } else {
        router.push('/welcome');
      }
    }
  }, [user, loading, router]);

  return (
    <Container>
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
      >
        <CircularProgress size={60} />
      </Box>
    </Container>
  );
}
