// Zero Defect Programming Patterns - TypeScript Examples
// These patterns enforce error-free programming through type safety and validation

import { z } from 'zod';

// 1. INPUT VALIDATION PATTERN - All external data must be validated
const UserInputSchema = z.object({
  id: z.string().uuid('Invalid user ID format'),
  email: z.string().email('Invalid email format'),
  age: z.number().int().min(0).max(150, 'Invalid age range'),
  role: z.enum(['admin', 'user', 'guest'], {
    errorMap: () => ({ message: 'Invalid role specified' }),
  }),
  preferences: z.object({
    notifications: z.boolean(),
    theme: z.enum(['light', 'dark']).default('light'),
  }).optional(),
});

type User = z.infer<typeof UserInputSchema>;

// 2. RESULT PATTERN - No exceptions, explicit error handling
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E };

// 3. TYPE GUARD PATTERN - Runtime type checking
function isValidUser(data: unknown): data is User {
  try {
    UserInputSchema.parse(data);
    return true;
  } catch {
    return false;
  }
}

// 4. ASSERTION FUNCTION - Fail fast with type narrowing
function assertIsValidUser(data: unknown): asserts data is User {
  const result = UserInputSchema.safeParse(data);
  if (!result.success) {
    throw new Error(`Invalid user data: ${result.error.message}`);
  }
}

// 5. DEFENSIVE FUNCTION - Complete validation and error handling
function createUser(input: unknown): Result<User, string> {
  // Input validation first
  const parseResult = UserInputSchema.safeParse(input);
  if (!parseResult.success) {
    return {
      success: false,
      error: `Validation failed: ${parseResult.error.issues
        .map(issue => issue.message)
        .join(', ')}`,
    };
  }

  const user = parseResult.data;

  // Business logic validation
  if (user.role === 'admin' && user.age < 18) {
    return {
      success: false,
      error: 'Admin users must be at least 18 years old',
    };
  }

  // Success case
  return {
    success: true,
    data: user,
  };
}

// 6. BOUNDARY CHECKING - Assert invariants
function assertPositiveNumber(value: number): asserts value is number {
  if (value <= 0 || !Number.isFinite(value)) {
    throw new Error(`Expected positive number, got: ${value}`);
  }
}

function calculateDiscount(price: number, discountPercentage: number): Result<number> {
  try {
    // Boundary checks
    assertPositiveNumber(price);
    assertPositiveNumber(discountPercentage);
    
    if (discountPercentage > 100) {
      return {
        success: false,
        error: 'Discount percentage cannot exceed 100%',
      };
    }

    const discount = (price * discountPercentage) / 100;
    return {
      success: true,
      data: discount,
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}

// 7. EXHAUSTIVE CHECKING - Handle all cases
type ApiResponse = 'success' | 'error' | 'loading' | 'timeout';

function handleApiResponse(response: ApiResponse): string {
  switch (response) {
    case 'success':
      return 'Operation completed successfully';
    case 'error':
      return 'An error occurred';
    case 'loading':
      return 'Operation in progress';
    case 'timeout':
      return 'Operation timed out';
    default:
      // TypeScript will error if we miss a case
      const exhaustiveCheck: never = response;
      throw new Error(`Unhandled response: ${exhaustiveCheck}`);
  }
}

// 8. SAFE ARRAY ACCESS - No unchecked indexing
function safeArrayAccess<T>(array: T[], index: number): Result<T> {
  if (index < 0 || index >= array.length) {
    return {
      success: false,
      error: `Index ${index} is out of bounds for array of length ${array.length}`,
    };
  }

  const item = array[index];
  if (item === undefined) {
    return {
      success: false,
      error: 'Item is undefined',
    };
  }

  return {
    success: true,
    data: item,
  };
}

// 9. SAFE OBJECT ACCESS - No unchecked property access
function safeObjectAccess<T>(
  obj: Record<string, T>,
  key: string
): Result<T> {
  if (!Object.prototype.hasOwnProperty.call(obj, key)) {
    return {
      success: false,
      error: `Property '${key}' does not exist`,
    };
  }

  const value = obj[key];
  if (value === undefined) {
    return {
      success: false,
      error: `Property '${key}' is undefined`,
    };
  }

  return {
    success: true,
    data: value,
  };
}

// 10. ASYNC ERROR HANDLING - No unhandled promise rejections
async function safeAsyncOperation(url: string): Promise<Result<unknown>> {
  try {
    // Validate input
    const urlSchema = z.string().url();
    const validUrl = urlSchema.parse(url);

    const response = await fetch(validUrl);
    
    if (!response.ok) {
      return {
        success: false,
        error: `HTTP ${response.status}: ${response.statusText}`,
      };
    }

    const data = await response.json();
    return {
      success: true,
      data,
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown network error',
    };
  }
}

// 11. FAIL-SAFE DEFAULTS - Always have a safe fallback
function getConfigValue(config: Record<string, unknown>, key: string): string {
  const value = config[key];
  
  // Safe default instead of undefined/null
  if (typeof value !== 'string' || value.trim() === '') {
    return 'default-value';
  }
  
  return value;
}

// 12. COMPOSITION WITH VALIDATION - Chain operations safely
function processUserData(rawInput: unknown): Result<string> {
  // Step 1: Validate input
  const userResult = createUser(rawInput);
  if (!userResult.success) {
    return userResult;
  }

  const user = userResult.data;

  // Step 2: Process with boundary checks
  try {
    assertPositiveNumber(user.age);
    
    // Step 3: Business logic with validation
    const processedData = `User: ${user.email}, Age: ${user.age}, Role: ${user.role}`;
    
    return {
      success: true,
      data: processedData,
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Processing failed',
    };
  }
}

// 13. ZERO DEFECT CLASS PATTERN - Defensive object-oriented programming
class SafeBankAccount {
  private _balance: number = 0;
  private readonly _accountId: string;

  constructor(accountId: string, initialBalance?: number) {
    // Validate constructor inputs
    const idSchema = z.string().min(1, 'Account ID cannot be empty');
    this._accountId = idSchema.parse(accountId);

    if (initialBalance !== undefined) {
      const result = this.deposit(initialBalance);
      if (!result.success) {
        throw new Error(`Invalid initial balance: ${result.error}`);
      }
    }
  }

  get balance(): number {
    return this._balance;
  }

  get accountId(): string {
    return this._accountId;
  }

  deposit(amount: number): Result<number> {
    try {
      assertPositiveNumber(amount);
      
      const newBalance = this._balance + amount;
      
      // Check for overflow
      if (!Number.isFinite(newBalance) || newBalance < this._balance) {
        return {
          success: false,
          error: 'Deposit would cause numeric overflow',
        };
      }

      this._balance = newBalance;
      return {
        success: true,
        data: this._balance,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Invalid deposit amount',
      };
    }
  }

  withdraw(amount: number): Result<number> {
    try {
      assertPositiveNumber(amount);
      
      if (amount > this._balance) {
        return {
          success: false,
          error: 'Insufficient funds',
        };
      }

      this._balance -= amount;
      return {
        success: true,
        data: this._balance,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Invalid withdrawal amount',
      };
    }
  }
}

// USAGE EXAMPLES - How to use these patterns

// Example 1: Safe user processing
const rawUserData = {
  id: '123e4567-e89b-12d3-a456-426614174000',
  email: 'user@example.com',
  age: 25,
  role: 'user',
};

const userResult = processUserData(rawUserData);
if (userResult.success) {
  console.log('User processed:', userResult.data);
} else {
  console.error('User processing failed:', userResult.error);
}

// Example 2: Safe array operations
const numbers = [1, 2, 3, 4, 5];
const itemResult = safeArrayAccess(numbers, 2);
if (itemResult.success) {
  console.log('Item at index 2:', itemResult.data);
} else {
  console.error('Array access failed:', itemResult.error);
}

// Example 3: Safe bank operations
try {
  const account = new SafeBankAccount('ACC-001', 100);
  
  const depositResult = account.deposit(50);
  if (depositResult.success) {
    console.log('New balance after deposit:', depositResult.data);
  }
  
  const withdrawResult = account.withdraw(200); // This will fail
  if (!withdrawResult.success) {
    console.error('Withdrawal failed:', withdrawResult.error);
  }
} catch (error) {
  console.error('Account creation failed:', error);
}

export {
  UserInputSchema,
  type User,
  type Result,
  isValidUser,
  assertIsValidUser,
  createUser,
  calculateDiscount,
  handleApiResponse,
  safeArrayAccess,
  safeObjectAccess,
  safeAsyncOperation,
  processUserData,
  SafeBankAccount,
};