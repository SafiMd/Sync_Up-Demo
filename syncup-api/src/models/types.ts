export type AccountType = "checking" | "savings" | "credit";

export interface Account {
  id: string;
  name: string;
  type: AccountType;
  mask: string;
  currentBalance: number;
  availableBalance?: number;
  institution?: string;
}

export type Category =
  | "Food and Drink" | "Shops" | "Recreation" | "Travel" | "Service"
  | "Transportation" | "Healthcare" | "Entertainment" | "Education"
  | "Utilities" | "Insurance" | "Personal Care" | "Other";

export interface Transaction {
  id: string;
  accountId: string;
  amount: number;   // negative = expense, positive = income
  merchant?: string;
  category: Category;
  date: string;     // ISO date
  pending?: boolean;
  note?: string;
}

export interface BudgetLine {
  category: Category;
  monthlyLimit: number; // fraction of income (0..1)
}

export interface BudgetDoc {
  id: string;
  month: string; // YYYY-MM
  lines: BudgetLine[];
}

