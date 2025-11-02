import './globals.css';
import Sidebar from '../components/Sidebar';

export const metadata = {
  title: 'Etherverse Chat',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-black text-[#e5e7eb]">
        <div className="flex min-h-screen">
          <Sidebar />
          <main className="flex-1 relative">{children}</main>
        </div>
      </body>
    </html>
  );
}
