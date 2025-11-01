export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).send("Method Not Allowed");
  if (req.headers['x-vercel-signature'] !== process.env.VERCEL_AUTOMATION_BYPASS_SECRET) {
    return res.status(401).send("Unauthorized");
  }

  console.log("✅ Webhook received:", req.body);
  res.status(200).json({ ok: true, received: req.body });
}
