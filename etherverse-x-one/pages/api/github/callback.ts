import type { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { code, installation_id } = req.query;

  console.log('🔁 GitHub OAuth Callback Hit:', req.query);

  res.status(200).send(`
    <h1>✅ GitHub App Installed</h1>
    <p>Authorization Code: ${code}</p>
    <p>Installation ID: ${installation_id}</p>
  `);
}
