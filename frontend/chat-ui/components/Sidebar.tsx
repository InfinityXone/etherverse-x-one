"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

const links = [
  { href: "/", label: "Chat" },
  { href: "/p/dev-handoff", label: "Dev Handoff" },
  { href: "/p/github-auth", label: "GitHub Auth" },
  { href: "/p/github-integration", label: "GitHub Integration" },
  { href: "/p/fix-chat-ui", label: "Fix Chat UI" },
];

export default function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="sidebar">
      <div className="brand">
        <img src="/logo.png" alt="" width={22} height={22} />
        <div>
          <div className="title">Etherverse</div>
          <div className="subtitle">Agent Infinity Console</div>
        </div>
      </div>
      <nav>
        {links.map(l => {
          const active = pathname === l.href;
          return (
            <Link key={l.href} href={l.href} className={active ? "active" : ""}>
              {l.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
