import type { Metadata } from "next";
import "./globals.css";
import Sidebar from "@/components/Sidebar";

export const metadata: Metadata = {
  title: "Etherverse Chat",
  description: "True-black metallic UI with deep-blue accents",
  metadataBase: new URL(process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000"),
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="page">
        <Sidebar />
        <main className="main">{children}</main>
      </body>
    </html>
  );
}
