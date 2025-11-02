import { NextRequest } from "next/server";

export const runtime = "nodejs"; // easy mode

export async function POST(req: NextRequest) {
  const { message } = await req.json();

  const GATEWAY = process.env.IX1_GATEWAY_URL;   // e.g. https://memory-gateway-.../chat
  const OPENAI  = process.env.OPENAI_API_KEY;    // fallback

  let reply = "No backend available. Set IX1_GATEWAY_URL or OPENAI_API_KEY.";

  try {
    if (GATEWAY) {
      const r = await fetch(GATEWAY, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ message }),
      });
      if (!r.ok) throw new Error(await r.text());
      const data = await r.json();
      reply = data.reply ?? JSON.stringify(data);
    } else if (OPENAI) {
      const r = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "authorization": `Bearer ${OPENAI}`,
        },
        body: JSON.stringify({
          model: process.env.OPENAI_MODEL || "gpt-4o-mini",
          messages: [{ role: "user", content: message }],
          temperature: 0.3,
        }),
      });
      if (!r.ok) throw new Error(await r.text());
      const data = await r.json();
      reply = data.choices?.[0]?.message?.content ?? "…";
    }
  } catch (e: any) {
    reply = `Error: ${e.message || e}`;
  }

  return new Response(JSON.stringify({ reply }), {
    headers: { "content-type": "application/json" },
  });
}
