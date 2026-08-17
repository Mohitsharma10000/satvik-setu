'use client';

import { useEffect, useState } from 'react';
import {
  Container,
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Chip,
  Button,
  Tabs,
  Tab,
  Avatar,
  Divider,
} from '@mui/material';
import Navbar from '@/components/layout/Navbar';
import { ServiceRequest } from '@/types';
import { format } from 'date-fns';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;
  return (
    <div hidden={value !== index} {...other}>
      {value === index && <Box sx={{ pt: 3 }}>{children}</Box>}
    </div>
  );
}

export default function ProviderDashboardPage() {
  const [tabValue, setTabValue] = useState(0);
  const [requests, setRequests] = useState<ServiceRequest[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRequests();
  }, []);

  const loadRequests = async () => {
    // TODO: Load provider's requests from Firestore
    setLoading(false);
  };

  const handleAccept = async (requestId: string) => {
    // TODO: Update request status to 'accepted'
  };

  const handleReject = async (requestId: string) => {
    // TODO: Update request status to 'cancelled'
  };

  const handleComplete = async (requestId: string) => {
    // TODO: Navigate to completion proof screen
  };

  const newRequests = requests.filter((r) => r.status === 'requested');
  const activeRequests = requests.filter((r) => ['accepted', 'in_progress'].includes(r.status));
  const completedRequests = requests.filter((r) => r.status === 'completed');

  return (
    <>
      <Navbar />
      <Container maxWidth="xl" sx={{ py: 4 }}>
        {/* Header */}
        <Box mb={4}>
          <Typography variant="h3" gutterBottom fontWeight="bold">
            Provider Dashboard
          </Typography>
          <Typography variant="h6" color="text.secondary">
            Manage your service requests
          </Typography>
        </Box>

        {/* Stats Cards */}
        <Grid container spacing={3} mb={4}>
          <Grid item xs={12} sm={4}>
            <Card elevation={3}>
              <CardContent>
                <Typography variant="h6" color="text.secondary">
                  New Requests
                </Typography>
                <Typography variant="h3" fontWeight="bold" color="warning.main">
                  {newRequests.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={4}>
            <Card elevation={3}>
              <CardContent>
                <Typography variant="h6" color="text.secondary">
                  Active Jobs
                </Typography>
                <Typography variant="h3" fontWeight="bold" color="info.main">
                  {activeRequests.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={4}>
            <Card elevation={3}>
              <CardContent>
                <Typography variant="h6" color="text.secondary">
                  Completed
                </Typography>
                <Typography variant="h3" fontWeight="bold" color="success.main">
                  {completedRequests.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Tabs */}
        <Card elevation={3}>
          <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
            <Tabs value={tabValue} onChange={(e, val) => setTabValue(val)}>
              <Tab label={`New (${newRequests.length})`} />
              <Tab label={`Active (${activeRequests.length})`} />
              <Tab label={`Completed (${completedRequests.length})`} />
            </Tabs>
          </Box>

          {/* New Requests Tab */}
          <TabPanel value={tabValue} index={0}>
            {newRequests.length === 0 ? (
              <Box textAlign="center" py={8}>
                <Typography variant="h6" color="text.secondary">
                  No new requests
                </Typography>
              </Box>
            ) : (
              <Grid container spacing={2} p={2}>
                {newRequests.map((request) => (
                  <Grid item xs={12} key={request.requestId}>
                    <Card variant="outlined">
                      <CardContent>
                        <Grid container spacing={2} alignItems="center">
                          <Grid item xs={12} md={6}>
                            <Typography variant="h6" fontWeight="bold">
                              {request.category} - {request.subcategory}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                              Customer: {request.userName}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                              Phone: {request.userPhone}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                              Location: {request.serviceLocation}
                            </Typography>
                          </Grid>
                          <Grid item xs={12} md={3}>
                            <Typography variant="body2" color="text.secondary">
                              Requested on:
                            </Typography>
                            <Typography variant="body1">
                              {format(new Date(request.requestedAt), 'PPp')}
                            </Typography>
                          </Grid>
                          <Grid item xs={12} md={3}>
                            <Button
                              fullWidth
                              variant="contained"
                              color="success"
                              onClick={() => handleAccept(request.requestId!)}
                              sx={{ mb: 1 }}
                            >
                              Accept
                            </Button>
                            <Button
                              fullWidth
                              variant="outlined"
                              color="error"
                              onClick={() => handleReject(request.requestId!)}
                            >
                              Reject
                            </Button>
                          </Grid>
                        </Grid>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            )}
          </TabPanel>

          {/* Active Requests Tab */}
          <TabPanel value={tabValue} index={1}>
            {activeRequests.length === 0 ? (
              <Box textAlign="center" py={8}>
                <Typography variant="h6" color="text.secondary">
                  No active jobs
                </Typography>
              </Box>
            ) : (
              <Grid container spacing={2} p={2}>
                {activeRequests.map((request) => (
                  <Grid item xs={12} key={request.requestId}>
                    <Card variant="outlined">
                      <CardContent>
                        <Grid container spacing={2} alignItems="center">
                          <Grid item xs={12} md={8}>
                            <Box display="flex" alignItems="center" gap={1} mb={1}>
                              <Typography variant="h6" fontWeight="bold">
                                {request.category} - {request.subcategory}
                              </Typography>
                              <Chip
                                label={request.status.toUpperCase()}
                                color="info"
                                size="small"
                              />
                            </Box>
                            <Typography variant="body2">
                              Customer: {request.userName} ({request.userPhone})
                            </Typography>
                            <Typography variant="body2">
                              Location: {request.serviceLocation}
                            </Typography>
                          </Grid>
                          <Grid item xs={12} md={4}>
                            <Button
                              fullWidth
                              variant="contained"
                              onClick={() => handleComplete(request.requestId!)}
                            >
                              Mark as Complete
                            </Button>
                          </Grid>
                        </Grid>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            )}
          </TabPanel>

          {/* Completed Requests Tab */}
          <TabPanel value={tabValue} index={2}>
            {completedRequests.length === 0 ? (
              <Box textAlign="center" py={8}>
                <Typography variant="h6" color="text.secondary">
                  No completed jobs yet
                </Typography>
              </Box>
            ) : (
              <Grid container spacing={2} p={2}>
                {completedRequests.map((request) => (
                  <Grid item xs={12} key={request.requestId}>
                    <Card variant="outlined">
                      <CardContent>
                        <Box display="flex" justifyContent="space-between" alignItems="start">
                          <Box>
                            <Typography variant="h6" fontWeight="bold">
                              {request.category} - {request.subcategory}
                            </Typography>
                            <Typography variant="body2">
                              Customer: {request.userName}
                            </Typography>
                            <Typography variant="body2" color="success.main">
                              ✓ Completed
                            </Typography>
                          </Box>
                          <Chip label="COMPLETED" color="success" />
                        </Box>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            )}
          </TabPanel>
        </Card>
      </Container>
    </>
  );
}
