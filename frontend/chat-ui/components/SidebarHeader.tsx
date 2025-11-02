"use client";
import Logo from "./Logo";

export default function SidebarHeader() {
  return (
    <div className="flex items-center gap-3 mb-4">
      <Logo size={36} />
      <div className="text-lg font-semibold neon">Agent Infinity</div>
    </div>
  );
}
