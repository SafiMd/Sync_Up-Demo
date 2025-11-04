export const PlaidService = {
  createLinkToken(userId: string) {
    return {
      link_token: `mock-link-token-${userId}`,
      expiration: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
    };
  },

  exchangePublicToken(publicToken: string) {
    return {
      access_token: `mock-access-${publicToken.slice(-6)}`,
      item_id: `mock-item-${publicToken.slice(-4)}`,
    };
  },
};

