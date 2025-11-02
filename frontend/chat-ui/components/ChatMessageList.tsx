export default function ChatMessageList() {
  return (
    <div className="mx-auto max-w-4xl w-full px-4 pt-6 pb-40">
      <div className="rounded-xl border border-[#111] bg-[#0a0a0a] p-6">
        <h1 className="text-3xl font-bold text-[#e5e7eb]">Chat</h1>
        <p className="mt-4 text-sm text-[#a5b4fc]">
          Your true-black UI with deep-blue accents is live.
        </p>
        <p className="mt-2 text-sm text-[#9ca3af]">
          Wire your API at <code className="text-[#c7d2fe]">/app/api/chat/route.ts</code> when ready.
        </p>
      </div>
    </div>
  );
}
