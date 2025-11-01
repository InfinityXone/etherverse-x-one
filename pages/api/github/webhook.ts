import { NextApiRequest, NextApiResponse } from 'next';
import crypto from 'crypto';

const WEBHOOK_SECRET = process.env.GITHUB_WEBHOOK_SECRET || 'superSecretEtherverseHook99!';

function verifySignature(req: NextApiRequest): boolean {
  const signature = req.headers['x-hub-signature-256'] as string;
  const hmac = crypto.createHmac('sha256', WEBHOOK_SECRET);
  const digest = 'sha256=' + hmac.update(JSON.stringify(req.body)).digest('hex');
  return crypto.timingSafeEqual(Buffer.from(digest), Buffer.from(signature));
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end('Method Not Allowed');
  }

  if (!verifySignature(req)) {
    return res.status(401).end('Invalid signature');
  }

  const event = req.headers['x-github-event'];
  console.log(`[📦 GitHub Webhook] Event: ${event}`);
  console.log('Payload:', JSON.stringify(req.body, null, 2));

  res.status(200).json({ received: true, event });
}
