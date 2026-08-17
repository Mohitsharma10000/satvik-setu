import type { Metadata } from 'next';
import ClientProviders from '@/components/providers/ClientProviders';
import './globals.css';

export const metadata: Metadata = {
  title: 'Service Finder - Verified Local Service Providers',
  description: 'Connect with verified local service providers for all your needs',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'system-ui, -apple-system, sans-serif' }}>
        <ClientProviders>{children}</ClientProviders>
      </body>
    </html>
  );
}
