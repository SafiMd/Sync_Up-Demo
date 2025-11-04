# SyncUp API

Demo API for SyncUp financial management application built with TypeScript and Express.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
# Edit .env if needed
```

3. Run the development server:
```bash
npm run dev
```

The API will be available at `http://localhost:4000`

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Run production build

## API Endpoints

All endpoints are prefixed with `/v1`:

- `GET /v1/health` - Health check
- `GET /v1/accounts` - List all accounts
- `GET /v1/transactions` - List transactions (supports query params: `accountId`, `category`, `from`, `to`)
- `GET /v1/budgets?month=YYYY-MM` - Get budget for a month
- `PUT /v1/budgets` - Update budget
- `GET /v1/insights?month=YYYY-MM` - Get budget insights for a month
- `POST /v1/plaid/link/token/create` - Create Plaid link token (mock)
- `POST /v1/plaid/item/public_token/exchange` - Exchange public token (mock)

## Testing

```bash
# Health check
curl http://localhost:4000/v1/health

# List accounts
curl http://localhost:4000/v1/accounts

# List transactions
curl "http://localhost:4000/v1/transactions?category=Entertainment"

# Get insights
curl "http://localhost:4000/v1/insights?month=2025-10"
```

## Project Structure

```
syncup-api/
├── src/
│   ├── config/       # Configuration (env variables)
│   ├── lib/          # Shared utilities
│   ├── middleware/   # Express middleware
│   ├── models/       # TypeScript types/interfaces
│   ├── services/     # Business logic
│   ├── routes/       # Route definitions
│   ├── v1/           # API v1 endpoints
│   │   ├── accounts/
│   │   ├── transactions/
│   │   ├── budgets/
│   │   ├── insights/
│   │   └── plaid/
│   └── data/         # Sample data (JSON)
├── dist/             # Compiled JavaScript (generated)
└── package.json
```

## Notes

- This is a demo API with mock data stored in `src/data/sample.json`
- Authentication is open in development mode
- Plaid integration is mocked for demonstration purposes

