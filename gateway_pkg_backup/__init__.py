class APIGateway:
    def __init__(self, github_webhook_url=None, vercel_url=None):
        self.github_webhook_url = github_webhook_url
        self.vercel_url = vercel_url
