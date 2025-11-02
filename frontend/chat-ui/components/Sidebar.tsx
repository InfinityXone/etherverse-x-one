import Link from 'next/link';

function SectionTitle({ children }: { children: React.ReactNode }) {
  return (
    <div className="px-3 pt-4 pb-2 text-xs uppercase tracking-wide text-[#7a88b8]">
      {children}
    </div>
  );
}

function NavItem({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="block rounded-lg px-3 py-2 text-sm text-[#e5e7eb] hover:bg-[#0f0f12] border border-transparent hover:border-[#1a1a1a]"
    >
      {children}
    </Link>
  );
}

export default function Sidebar() {
  return (
    <aside className="hidden md:flex md:w-64 lg:w-72 shrink-0 flex-col border-r border-[#111] bg-[#050505]">
      <div className="h-14 flex items-center gap-2 px-3 border-b border-[#111]">
        <div className="h-7 w-7 rounded-lg bg-gradient-to-br from-[#0b0f1f] to-black grid place-items-center text-[#9bb0ff]">∞</div>
        <div className="font-semibold text-[#e5e7eb]">Etherverse</div>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="p-3">
          <button className="w-full rounded-lg border border-[#1a1a1a] bg-black/40 px-3 py-2 text-left text-sm text-[#e5e7eb] hover:bg-[#0f0f12]">
            New chat
          </button>
        </div>

        <SectionTitle>Navigation</SectionTitle>
        <nav className="space-y-1">
          <NavItem href="/">Chat</NavItem>
          <NavItem href="/p/dev-handoff">Dev Handoff</NavItem>
          <NavItem href="/p/github-auth">GitHub Auth</NavItem>
          <NavItem href="/p/github-integration">GitHub Integration</NavItem>
          <NavItem href="/p/fix-chat-ui">Fix Chat UI</NavItem>
        </nav>

        <SectionTitle>Shortcuts</SectionTitle>
        <nav className="space-y-1">
          <NavItem href="/library">Library</NavItem>
          <NavItem href="/codex">Codex</NavItem>
        </nav>

        <SectionTitle>Projects</SectionTitle>
        <nav className="space-y-1">
          <NavItem href="/project/etherverse">Etherverse</NavItem>
          <NavItem href="/project/infinity-agent">Infinity Agent</NavItem>
        </nav>
      </div>

      <div className="border-t border-[#111] p-3 text-xs text-[#8b8b8b]">
        <div className="flex items-center justify-between">
          <span>Jeremy • Plus</span>
          <button className="rounded-md border border-[#1a1a1a] px-2 py-1 hover:bg-[#0f0f12]">⚙</button>
        </div>
      </div>
    </aside>
  );
}
