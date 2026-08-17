'use client';

import { useState } from 'react';
import {
  Container,
  Box,
  Typography,
  TextField,
  InputAdornment,
  Grid,
  Card,
  CardContent,
  CardActionArea,
  Avatar,
  Chip,
  Button,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import PhoneIcon from '@mui/icons-material/Phone';
import Navbar from '@/components/layout/Navbar';
import { useRouter } from 'next/navigation';

export default function SearchPage() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [results, setResults] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  const handleSearch = async () => {
    if (!searchQuery.trim()) return;
    
    setLoading(true);
    // TODO: Implement Firestore search
    // For now, placeholder
    setTimeout(() => {
      setLoading(false);
    }, 1000);
  };

  return (
    <>
      <Navbar />
      <Container maxWidth="xl" sx={{ py: 4 }}>
        {/* Header */}
        <Box mb={4}>
          <Typography variant="h3" gutterBottom fontWeight="bold">
            Search Services
          </Typography>
          <Typography variant="h6" color="text.secondary">
            Find providers by name, category, or location
          </Typography>
        </Box>

        {/* Search Bar */}
        <Box mb={4}>
          <TextField
            fullWidth
            variant="outlined"
            placeholder="Search for services, providers, or categories..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
          />
          <Button
            variant="contained"
            size="large"
            startIcon={<SearchIcon />}
            onClick={handleSearch}
            disabled={loading}
          >
            {loading ? 'Searching...' : 'Search'}
          </Button>
        </Box>

        {/* Results */}
        {results.length > 0 ? (
          <Grid container spacing={3}>
            {results.map((result, index) => (
              <Grid item xs={12} md={6} key={index}>
                <Card elevation={3}>
                  <CardActionArea>
                    <CardContent sx={{ p: 3 }}>
                      <Box display="flex" gap={2} mb={2}>
                        <Avatar src={result.profileImage} sx={{ width: 64, height: 64 }} />
                        <Box flex={1}>
                          <Typography variant="h5" fontWeight="bold">
                            {result.name}
                          </Typography>
                          <Chip label="✓ Verified" color="success" size="small" />
                        </Box>
                      </Box>
                      <Typography variant="body2" color="text.secondary">
                        {result.category} - {result.subcategory}
                      </Typography>
                    </CardContent>
                  </CardActionArea>
                </Card>
              </Grid>
            ))}
          </Grid>
        ) : searchQuery ? (
          <Box textAlign="center" py={8}>
            <Typography variant="h5" color="text.secondary">
              No results found for "{searchQuery}"
            </Typography>
          </Box>
        ) : (
          <Box textAlign="center" py={8}>
            <SearchIcon sx={{ fontSize: 80, color: 'text.secondary', mb: 2 }} />
            <Typography variant="h5" color="text.secondary">
              Start searching for services
            </Typography>
          </Box>
        )}
      </Container>
    </>
  );
}
