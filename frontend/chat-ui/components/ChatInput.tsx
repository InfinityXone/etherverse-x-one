'use client';

import { useState } from 'react';

export default function ChatInput({
  onSend,
}: {
  onSend?: (text: string) => void;
}) {
  const [text, setText] = useState('');
  const [sending, setSending] = useState(false);

  async function submit(e?: React.FormEvent) {
    e?.preventDefault();
    const t = text.trim();
    if (!t || sending) return;
    setSending(true);
    try {
      onSend?.(t);
      // TODO: wire to /app/api/chat/route.ts
      // await fetch('/api/chat', { method: 'POST', body: JSON.stringify({ message: t }) });
    } finally {
      setSending(false);
      setText('');
    }
  }

  return (
    <div className="fixed inset-x-0 bottom-0 z-20">
      <div className="mx-auto max-w-4xl px-4 pb-4">
        <form
          onSubmit={submit}
          className="rounded-2xl border border-[#1a1a1a] bg-[#0a0a0a] shadow-[0_0_40px_rgba(30,58,255,0.08)]"
        >
          <div className="flex items-end gap-2 p-3">
            <button
              type="button"
              title="Attach"
              className="h-9 w-9 shrink-0 rounded-lg border border-[#1a1a1a] bg-black/50"
              onClick={() => alert('Wire file picker')}
            >
              ⊕
            </button>

            <textarea
              value={text}
              onChange={(e) => setText(e.target.value)}
              placeholder="Message Etherverse…"
              rows={1}
              className="min-h-[44px] max-h-[200px] flex-1 resize-none bg-transparent px-2 py-2 outline-none placeholder:text-[#6b7280] text-[#e5e7eb]"
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) submit(e);
              }}
            />

            <button
              type="submit"
              disabled={!text.trim() || sending}
              className="h-9 shrink-0 rounded-lg px-4 text-sm font-medium
                         border border-[#1a1a1a] bg-[#0b0f1f] text-[#dbe4ff]
                         disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Send
            </button>
          </div>
        </form>
        <div className="py-2 text-center text-xs text-[#6b7280]">
          Etherverse may display experimental features.
        </div>
      </div>
    </div>
  );
}
