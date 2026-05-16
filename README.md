# Intermediate Developer Assessment

## Instructions

- Answer all questions.
- You may use either Pascal-style pseudocode or SQL for coding questions.
- **IMPORTANT:** Every answer must include detailed reasoning and trade-off analysis.
- This test assesses advanced logic, debugging, and troubleshooting skills.
- **Part 1:** the function/method in C#, C++, Java, JavaScript or TypeScript
- **Part 2:** the SQL scripts and submit it in either a sql or text file
- **Part 3:** pseudocode or SQL (as requested) in word file along with explanations
- **Part 4:** pseudocode or SQL (as requested) in word file along with explanations
- **Part 5:** pseudocode or SQL (as requested) in word file along with explanations

**Candidate Name:** <u>Miles Buckton</u>

**Date:** <u>16/05/2026</u>

---

## Part 1 — Encryption

Encryption is the process of encoding information, in our case a message, to make it unreadable without special knowledge. This knowledge consists of the method of encryption and something called a key. We shall use a very simple method of encrypting a message. The message we will encrypt will only contain the 26 capital alphabetic letters and spaces. There is no punctuation in the messages. The key is a sequence of distinct letters. The method of encryption is as follows: Look at each letter of the message. If the letter is in the key, replace it with the letter following it in the key. If it is the last letter in the key, replace it with the first letter in the key. If the letter is not in the key, don't change it. Leave spaces unchanged.

### Task

Your task will be to encrypt a message. You will be supplied with the unencrypted message and the key.

- The unencrypted message will contain capital letters and spaces, and will be at most 255 characters long.
- The key will be at most 13 characters long. Letters will not be repeated in the key.

### Sample Run

Given the message `COMPUTER OLYMPIAD`, and the key `MOPED`, we can do the following:

- **C** is not in the key. It is left unchanged.
- **O** is in the key. Replace it with the letter after O, **P**.
- **D** is in the key. It is the last letter in the key. Replace it with the first letter of the key, **M**.

The full encrypted message will be: `CPOEUTDR PLYOEIAM`

**Input**
```
Message: COMPUTER OLYMPIAD
Key: MOPED
```

**Output**
```
CPOEUTDR PLYOEIAM
```

### Answer

**Code reference:** `Part 1\Encryption\Helpers\EncryptionHelper.cs` (algorithm), `Part 1\Encryption\Program.cs` (console entry point), `Part 1\Encryption.Tests\EncryptMessageTests.cs` (xUnit tests).

The encryption algorithm iterates over each character of the message. If the character exists in the key, it is replaced by the next character in the key (wrapping around to the first character if it's at the end). Spaces and characters not in the key remain unchanged. The key is supplied as a parameter so the helper is reusable across different keys.

```csharp
internal static string EncryptMessage(string message, string key)
{
    ValidateKey(key);
    ValidateMessage(message);

    StringBuilder encryptedMessage = new(message.Length);
    foreach (char letter in message)
    {
        int index = key.IndexOf(letter);
        char encryptedLetter = index >= 0 ? key[(index + 1) % key.Length] : letter;
        encryptedMessage.Append(encryptedLetter);
    }

    return encryptedMessage.ToString();
}
```

**Trade-offs:**
- `StringBuilder` (pre-sized to `message.Length`) is used for O(n) concatenation rather than string `+=` which would be O(n²).
- A single `IndexOf` per character avoids the redundant scan of `Contains` + `IndexOf`.
- The `% key.Length` modulo gives elegant wrap-around without conditional checks.
- The key is passed as a parameter rather than hardcoded, making the helper reusable and easy to test against multiple keys.
- Validation enforces the spec on both inputs:
  - **Message** (max 255 chars, capital letters and spaces only): `ArgumentNullException` for null, `ArgumentException` for empty or over-length, `FormatException` for non-letters or lowercase.
  - **Key** (max 13 chars, distinct uppercase letters): `ArgumentNullException` for null, `ArgumentException` for empty / over-length / repeated letters, `FormatException` for non-letters or lowercase.
- `Program.Main` returns an exit code (0 success, 1 failure) and routes validation failures vs. unexpected errors to `Console.Error` with different prefixes (`Invalid input:` vs. `Unexpected error:`).
- A dedicated xUnit test project (`Encryption.Tests`) covers the sample input, wrap-around, pass-through of letters not in the key, the "key is actually used" property, and every validation branch — including boundary tests at exactly the max key/message length and one character over.

---

## Part 2 — Dynamic SQL

### 2.1

Fix the following dynamic SQL to display the information from `@sLCCostTable`:

```sql
DECLARE @sLCCostTable NVARCHAR(100),
        @ServerID VARCHAR(10),
        @psProducerID NVARCHAR(10),
        @SQL NVARCHAR(100) = ''

SET @sLCCostTable = 'LCTempCostsFor' + @ServerID
SET @psProducerID = 'ALICEDAUSD' --'Testproducer'
SET @ServerID = CAST(@@SPID AS VARCHAR)

SET @SQL =
'SELECT [Sale ID], [Barcode], [Sequence Number], [Description],
        SUM([Amount]) AS Amount, SUM([VAT]) AS [VAT], SUM([Total]) AS Total
 INTO ' + @sLCCostTable + '
 FROM (SELECT V.[Sale ID],
              V.[Barcode],
              V.[Sequence Number],
              V.[Producer ID],
              V.[Commodity Code],
              V.[Variety Code],
              V.[Pack Code],
              V.[Count Code],
              V.[Grade Code],
              ''L-'' + COALESCE(C.[Group 1],'''') AS [Description],
              SUM(ISNULL(V.[Amount],0)) AS Amount,
              SUM(ISNULL(V.[VAT],0)) AS [VAT],
              SUM(ISNULL(V.[Total],0)) AS Total,
              MIN(ISNULL(CI.[Report Order],0)) AS [Report Order]
       FROM v_QXSys_Financial_ActualLocalCosts V
       LEFT OUTER JOIN CostItems C ON V.[Cost Item] = C.[Code]
       WHERE V.[Producer ID] = ''' + @psProducerID + '''
       GROUP BY V.[Sale ID], V.[Barcode], V.[Sequence Number], V.[Producer ID],
                V.[Commodity Code], V.[Variety Code], V.[Pack Code],
                V.[Count Code], V.[Grade Code],
                ''L-'' + COALESCE(CI.[Group 1],'''') SUB
 GROUP BY [Sale ID], [Barcode], [Description] '
```

### Answer

**Code reference:** `Part 2\SQL\Build_LCTempCosts_ByProducer.sql`

The original code has **6 bugs**:

1. **Variable order:** `@ServerID` is used in the assignment of `@sLCCostTable` *before* it is assigned a value. The `SET @ServerID = CAST(@@SPID AS VARCHAR)` must come first.

2. **`@SQL` size too small:** `NVARCHAR(100)` cannot hold the large dynamic query. Changed to `NVARCHAR(MAX)`.

3. **Missing subquery alias:** The subquery in the `FROM` clause lacks a proper alias. The original has `) SUB` but it was placed incorrectly and the closing parenthesis was missing. The subquery must end with `) AS SUB`.

4. **Incorrect table alias:** The `LEFT OUTER JOIN CostItems C` uses alias `C` but later references `CI.[Group 1]` and `CI.[Report Order]`. The alias must be consistent — changed to `CI`.

5. **Outer GROUP BY incomplete:** The outer query groups by `[Sale ID], [Barcode], [Description]` but should also include `[Sequence Number]` since it is in the SELECT list.

6. **No DROP TABLE guard:** `SELECT ... INTO` fails if the temp table already exists from a previous execution. Added an `IF OBJECT_ID ... DROP TABLE` guard before the main query.

**Corrected SQL:**

```sql
DECLARE @sLCCostTable NVARCHAR(100),
        @ServerID VARCHAR(10),
        @psProducerID NVARCHAR(10),
        @SQL NVARCHAR(MAX) = ''

SET @ServerID = CAST(@@SPID AS VARCHAR)
SET @sLCCostTable = 'LCTempCostsFor' + @ServerID
SET @psProducerID = 'ALICEDAUSD'

DECLARE @DropSQL NVARCHAR(200)
    = N'IF OBJECT_ID(N''' + @sLCCostTable + ''', N''U'') IS NOT NULL DROP TABLE ' + @sLCCostTable;

EXEC [Prophet].dbo.sp_executesql @DropSQL;

SET @SQL =
'SELECT [Sale ID], [Barcode], [Sequence Number], [Description],
        SUM([Amount]) AS Amount, SUM([VAT]) AS [VAT], SUM([Total]) AS Total
 INTO ' + @sLCCostTable + '
 FROM (SELECT V.[Sale ID],
              V.[Barcode],
              V.[Sequence Number],
              V.[Producer ID],
              V.[Commodity Code],
              V.[Variety Code],
              V.[Pack Code],
              V.[Count Code],
              V.[Grade Code],
              ''L-'' + COALESCE(CI.[Group 1],'''') AS [Description],
              SUM(ISNULL(V.[Amount],0)) AS Amount,
              SUM(ISNULL(V.[VAT],0)) AS [VAT],
              SUM(ISNULL(V.[Total],0)) AS Total,
              MIN(ISNULL(CI.[Report Order],0)) AS [Report Order]
       FROM v_QXSys_Financial_ActualLocalCosts V
       LEFT OUTER JOIN CostItems CI ON V.[Cost Item] = CI.[Code]
       WHERE V.[Producer ID] = ''' + @psProducerID + '''
       GROUP BY V.[Sale ID], V.[Barcode], V.[Sequence Number], V.[Producer ID],
                V.[Commodity Code], V.[Variety Code], V.[Pack Code],
                V.[Count Code], V.[Grade Code],
                ''L-'' + COALESCE(CI.[Group 1],'''')) AS SUB
 GROUP BY [Sale ID], [Barcode], [Sequence Number], [Description]'

EXEC [Prophet].dbo.sp_executesql @SQL
```

---

## Part 3 — Logic & Algorithm Design

### 3.1

**3.1.1** Given a table `FruitShipments(ShipmentID, FruitType, QuantityKg)` with approximately 5,000 rows, write pseudocode to find the second largest shipment quantity without sorting the entire dataset.

**Explanation Required:**

**3.1.2** How does your solution handle the case where the largest value appears multiple times?

**3.1.3** What happens if there are NULL quantities in the table?

**3.1.4** What is the performance advantage (Big-O notation) of your approach versus sorting?

### Answer

**Code reference:** `Part 3\SQL\Query_SecondLargestShipment.sql`

#### 3.1.1 — SQL

```sql
SELECT MAX(QuantityKg) AS SecondLargestQuantity
FROM FruitShipments
WHERE QuantityKg < (SELECT MAX(QuantityKg) FROM FruitShipments);
```

**Approach:** The subquery finds the largest value. The outer query finds the maximum among all values strictly less than the largest — i.e., the second largest.

#### 3.1.2 — Handling duplicate largest values

If the largest value appears multiple times (e.g., three rows with 500kg), the subquery still returns 500. The outer `WHERE QuantityKg < 500` excludes *all* of them, correctly returning the next distinct value below 500. This is the correct behaviour — we want the second-largest *distinct* quantity.

#### 3.1.3 — Handling NULL quantities

`NULL` values are automatically excluded by both `MAX()` (which ignores NULLs) and the `<` comparison (which yields UNKNOWN for NULLs, filtering them out). No special handling is needed — the query works correctly with NULLs present.

#### 3.1.4 — Performance advantage (Big-O)

- **This approach:** Two linear scans → O(n) + O(n) = **O(n)**
- **Sort-based approach:** Full sort → **O(n log n)**

For 5,000 rows the difference is modest, but for large datasets the linear approach is significantly faster. Additionally, this approach can leverage an index on `QuantityKg` for O(log n) performance via index seeks.

---

### 3.2

**3.2.1** Write SQL to find the most recent order per customer from the table: `Orders(OrderID, CustomerID, OrderDate, TotalAmount)`

The result should display: CustomerID, OrderID, OrderDate, TotalAmount for each customer's latest order only.

**Explanation Required:**

**3.2.2** If a customer has two orders on the same date, which one does your query return and why?

**3.2.3** Could you use a window function instead? What would be the advantage?

**3.2.4** How would you modify this to get the top 3 most recent orders per customer?

### Answer

**Code reference:** `Part 3\SQL\Query_LatestOrdersPerCustomer.sql`

#### 3.2.1 — SQL

```sql
SELECT o.CustomerID, o.OrderID, o.OrderDate, o.TotalAmount
FROM Orders o
INNER JOIN (
    SELECT CustomerID, MAX(OrderDate) AS LatestDate
    FROM Orders
    GROUP BY CustomerID
) latest ON o.CustomerID = latest.CustomerID
        AND o.OrderDate = latest.LatestDate;
```

#### 3.2.2 — Two orders on the same date

If a customer has two orders on the same date, this query returns **both rows**, because both match the `MAX(OrderDate)` join condition. If you need exactly one, you'd need a tie-breaker (e.g., `MAX(OrderID)`) or use `ROW_NUMBER()`.

#### 3.2.3 — Window function alternative

Yes, using `ROW_NUMBER()`:

```sql
SELECT CustomerID, OrderID, OrderDate, TotalAmount
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS rn
    FROM Orders
) ranked
WHERE rn = 1;
```

**Advantages:**
- Guarantees exactly one row per customer (no duplicates on ties)
- Handles tie-breaking deterministically (can add `OrderID DESC` to the ORDER BY)
- Single pass over the table (potentially better execution plan)
- Easily extensible to "top N" by changing `WHERE rn = 1` to `WHERE rn <= N`

#### 3.2.4 — Top 3 most recent orders per customer

```sql
SELECT CustomerID, OrderID, OrderDate, TotalAmount
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS rn
    FROM Orders
) ranked
WHERE rn <= 3;
```

Simply change the filter from `rn = 1` to `rn <= 3`.

---

### 3.3

**3.3.1** Your system generates delivery reference codes. Write pseudocode to check if a reference code is a palindrome (reads the same forwards and backwards) without using built-in reverse functions.

- Example: `"ABA123ABA"` → False (not palindrome)
- Example: `"A1B1A"` → True (palindrome)

**Explanation Required:**

**3.3.2** How does your solution handle spaces or special characters in the reference code?

**3.3.3** Should `"Aa"` be considered a palindrome? Why or why not, and how would you implement your choice?

**3.3.4** What is the time complexity of your solution?

### Answer

**Code reference:** `Part 3\DeliveryReference\DeliveryReference.dpr`

#### 3.3.1 — Pascal (manual reversal, no built-in reverse function)

```pascal
function IsPalindrome(const ReferenceCode: string): Boolean;
var
  i: Integer;
  reversed: string;
begin
  for i := Length(ReferenceCode) downto 1 do
    reversed := reversed + ReferenceCode[i];

  Result := ReferenceCode = reversed;
end;
```

**How it works:** A reversed copy of the string is built character by character by iterating from the last index down to the first. The original string is then compared to the reversed copy — if they are equal, the string is a palindrome.

#### 3.3.2 — Handling spaces or special characters

The current solution treats spaces and special characters as significant — they are compared just like any other character. So `"A B A"` reversed is `"A B A"`, which matches and IS a palindrome. However, `"AB A"` reversed is `"A BA"`, which does NOT match even though the letters alone (`"ABA"`) form a palindrome.

To ignore spaces/special characters, you would strip them before comparing:

```pascal
function StripNonAlphaNumeric(const S: string): string;
var
  ch: Char;
begin
  Result := '';
  for ch in S do
    if ch.IsLetterOrDigit then
      Result := Result + ch;
end;
```

Then call `IsPalindrome(StripNonAlphaNumeric(ReferenceCode))`.

#### 3.3.3 — Should "Aa" be a palindrome?

**No** — for delivery reference codes, case sensitivity should be preserved. Reference codes like `"ABA123ABA"` are formal identifiers where `A` and `a` are distinct characters. Treating them as equal could mask data-entry errors.

However, if case-insensitive comparison were desired, you'd normalize the string before comparing:

```pascal
function IsPalindromeCaseInsensitive(const ReferenceCode: string): Boolean;
var
  i: Integer;
  reversed: string;
begin
  for i := Length(ReferenceCode) downto 1 do
    reversed := reversed + ReferenceCode[i];

  Result := UpperCase(ReferenceCode) = UpperCase(reversed);
end;
```

The actual code demonstrates both: `IsPalindrome('Aa')` returns `False` (case-sensitive), while `IsPalindromeCaseInsensitive('Aa')` returns `True`.

#### 3.3.4 — Time complexity

- **Reversal approach:** **O(n)** time — the string is iterated once to build the reverse, then compared in O(n).
- **Space complexity:** **O(n)** — a full reversed copy of the string is allocated.

A two-pointer approach would achieve the same O(n) time with O(1) space, but the reversal approach is simpler and still efficient for reference codes (which are short strings).

---

## Part 4 — Debugging & Code Analysis

### 4.1

Using Pascal:

```pascal
procedure CalculateDeliveryDiscount(OrderAmount: Double);
var
  DiscountRate: Double;
begin
  if OrderAmount > 1000 then
    DiscountRate := 0.1
  else if OrderAmount > 500 then
    DiscountRate := 0.05;

  ShowMessage('Discount: R' + FloatToStr(DiscountRate * OrderAmount));
end;
```

**4.1.1** Find and explain the bug in this discount calculation procedure.

**Explanation Required:**

**4.1.2** Under what specific input conditions does the bug occur?

**4.1.3** What is the root cause (not just the symptom)?

**4.1.4** Provide the corrected code and explain why your fix solves all cases.

### Answer

**Code reference:** `Part 4\DeliveryDiscount\DeliveryDiscount.dpr`

#### 4.1.1 — The bug

There is **no `else` clause** for values ≤ 500. When `OrderAmount <= 500`, neither branch assigns `DiscountRate`, so it remains **uninitialized**. In Delphi, local variables of type `Double` are not zero-initialized — they contain whatever garbage was on the stack.

#### 4.1.2 — Input conditions that trigger the bug

Any `OrderAmount <= 500` — for example, `200`, `0`, `-50`, or `500` itself. These values skip both `if` branches, leaving `DiscountRate` uninitialized.

#### 4.1.3 — Root cause

The root cause is a **missing default assignment**. The developer assumed all cases were covered by the `if/else if` but forgot the final `else` for the remaining range (≤ 500). Delphi does not zero-initialize local variables, so the variable contains an indeterminate value.

#### 4.1.4 — Corrected code

```pascal
procedure CalculateDeliveryDiscount(OrderAmount: Double);
var
  DiscountRate: Double;
begin
  if OrderAmount > 1000 then
    DiscountRate := 0.1
  else if OrderAmount > 500 then
    DiscountRate := 0.05
  else
    DiscountRate := 0;

  ShowMessage('Discount: R' + FloatToStr(DiscountRate * OrderAmount));
end;
```

The `else DiscountRate := 0` ensures all code paths assign a deterministic value. Alternatively, initializing `DiscountRate := 0` at declaration would also work, but the explicit `else` is clearer about intent.

---

### 4.2

Using SQL:

```sql
SELECT CustomerID, COUNT(OrderID) AS TotalOrders
FROM Orders
HAVING TotalOrders > 10;
```

**4.2.1** What's wrong with this SQL and how would you fix it? Write correct SQL.

**Explanation Required:**

**4.2.2** Why does the original query fail?

**4.2.3** In what situations might you use HAVING without GROUP BY?

**4.2.4** How would you optimize this query if the Orders table has 1 million rows?

### Answer

**Code reference:** `Part 4\SQL\CustomersWithHighOrderCount.sql`

#### 4.2.1 — The bug and fix

Two problems:
1. **Missing `GROUP BY`** — `HAVING` filters groups, but no groups are defined.
2. **Column alias in HAVING** — SQL Server does not allow referencing a column alias (`TotalOrders`) in the `HAVING` clause; you must repeat the aggregate expression.

Corrected:
```sql
SELECT CustomerID, COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY CustomerID
HAVING COUNT(OrderID) > 10;
```

#### 4.2.2 — Why the original fails

`HAVING` is designed to filter *after* grouping. Without `GROUP BY`, there is only one implicit group (the entire table), so `CustomerID` in the SELECT is invalid (it's not aggregated). Additionally, SQL Server's logical query processing evaluates `HAVING` before `SELECT`, so the alias `TotalOrders` doesn't exist yet at that stage.

#### 4.2.3 — HAVING without GROUP BY

`HAVING` without `GROUP BY` treats the entire result set as a single group. It's valid for checking aggregate conditions on the whole table:

```sql
SELECT COUNT(*) AS TotalRows
FROM Orders
HAVING COUNT(*) > 1000;
```

This returns the count only if the table has more than 1000 rows; otherwise it returns no rows.

#### 4.2.4 — Optimization for 1 million rows

Create a covering index on `CustomerID` including `OrderID`:

```sql
CREATE INDEX IX_Orders_CustomerID ON Orders(CustomerID) INCLUDE (OrderID);
```

This allows an index-only scan for the GROUP BY + COUNT, avoiding a full table scan which would require reading every column of every row.

---

### 4.3

Using Pascal:

```pascal
function CalculateAverage(PalletA, PalletB, PalletC: Integer): Double;
begin
  Result := (PalletA + PalletB + PalletC) / 3;
end;

ShowMessage(FloatToStr(CalculateAverage(2, 5, 6)));
```

**4.3.1** Explain why this may not always give a precise result and provide two different ways to fix it.

**Explanation Required:**

**4.3.2** What specific input values would demonstrate the precision issue?

**4.3.3** Which fix would you prefer in a production system and why?

**4.3.4** How would you handle potential overflow if the pallet values were very large (e.g., 2 billion kg)?

### Answer

**Code reference:** `Part 4\PalletCalculator\PalletCalculator.dpr`

#### 4.3.1 — The precision issue

The division `/` in Delphi returns a `Double` (floating-point), which cannot represent all fractions exactly. For example, `(2 + 5 + 6) / 3 = 13 / 3 = 4.33333...` — this is a repeating decimal that cannot be stored precisely in binary floating-point, resulting in a small representation error.

**Fix 1 — Round to a fixed number of decimal places (with Int64 for overflow safety):**
```pascal
function CalculateAverage(PalletA, PalletB, PalletC: Int64): Double;
begin
  Result := RoundTo((PalletA + PalletB + PalletC) / 3, -2);
end;
```
This is the approach used in the actual code (`Part 4\PalletCalculator\PalletCalculator.dpr`). It combines precision control (`RoundTo`) with overflow protection (`Int64`).

**Fix 2 — Use Currency type (fixed-point, 4 decimal places):**
```pascal
function CalculateAverage(PalletA, PalletB, PalletC: Int64): Currency;
begin
  Result := (PalletA + PalletB + PalletC) / 3;
end;
```

#### 4.3.2 — Input values that demonstrate the issue

- `(2, 5, 6)` → 13/3 = 4.3333... (repeating — cannot be exact in binary)
- `(1, 1, 2)` → 4/3 = 1.3333... (repeating — precision loss)
- `(1, 1, 1)` → 3/3 = 1.0 (exact — no issue)
- `(1, 2, 3)` → 6/3 = 2.0 (exact — no issue)

Any sum not evenly divisible by 3 will exhibit the issue.

#### 4.3.3 — Preferred fix for production

**`RoundTo` (Fix 1)** is preferred because:
- You explicitly control the precision (e.g., 2 decimal places for kg)
- It communicates intent: "we accept this level of precision"
- `Currency` is limited to 4 decimal places and has a narrower range
- Business rules typically define acceptable precision (e.g., "round weights to 2 decimal places")

#### 4.3.4 — Handling overflow with very large values

With `Integer` (32-bit, max ~2.1 billion), adding three values near the max causes overflow. Use `Int64` parameters (64-bit integers, max ~9.2 × 10¹⁸) to extend the safe range without losing integer precision:

```pascal
function CalculateAverage(PalletA, PalletB, PalletC: Int64): Double;
```

This is the approach used in the actual code.

---

## Part 5 — Real-World Troubleshooting

### 5.1

After a database schema update, the Fruit Inventory Form displays an error: `"Invalid field name 'ExpiryDate'"` when loading existing records. The form worked fine before the update.

**5.1.1** List three systematic steps to diagnose and resolve this issue, explaining what each step reveals.

**Explanation Required:**

**5.1.2** How would you prevent this type of issue in future deployments? Describe one process improvement.

### Answer

#### 5.1.1 — Three diagnostic steps

**Step 1: Check the database schema**
```sql
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FruitInventory' AND COLUMN_NAME = 'ExpiryDate';
```
*Reveals:* Whether the column was renamed, dropped, or altered during the schema update. If no result, the column doesn't exist with that name.

**Step 2: Review the schema migration/update script**
Examine the DDL changes applied in the update. Look for `ALTER TABLE ... DROP COLUMN ExpiryDate`, `RENAME COLUMN`, or a change to `Expiry_Date` / `BestBeforeDate`.
*Reveals:* Exactly what changed and the correct new column name.

**Step 3: Search the application code for the field reference**
Grep the form's source code, queries, and dataset field definitions for `ExpiryDate`. Check persistent field definitions in the form designer (`.dfm` / `.fmx` files).
*Reveals:* Where the application references the old name, allowing you to update it to match the new schema.

#### 5.1.2 — Preventing this in future deployments

**Process improvement:** Implement a **schema migration versioning system** using a tool like **DbUp** — a .NET library that runs SQL migration scripts in order and tracks which scripts have been applied in a `SchemaVersions` table. Each database change is a numbered script paired with the corresponding application release, ensuring schema and code changes are always deployed together as an atomic unit.

---

### 5.2

A background Windows service that processes fruit delivery files every 10 minutes has stopped working. The service shows as "Running" in Windows Services, but no files have been processed for 2 hours. The last successful processing was at 08:00, and it's now 10:15.

**5.2.1** Describe your step-by-step diagnostic approach (minimum 4 steps).

**Explanation Required:**

**5.2.2** What's the difference between the service being "Running" versus actually processing files?

**5.2.3** If you find the service is attempting to process files but failing silently, where would you look next?

**5.2.4** How would you temporarily test if the issue is with the timer or the processing logic itself?

### Answer

#### 5.2.1 — Diagnostic steps

**Step 1: Check application/event logs**
Open Windows Event Viewer → Application log. Look for errors, warnings, or informational messages from the service between 08:00 and now.
*Reveals:* Unhandled exceptions, access denied errors, or configuration issues logged by the service.

**Step 2: Check the file input directory**
Verify that new delivery files actually exist in the input folder, that file permissions haven't changed, and that files aren't locked by another process.
*Reveals:* Whether the problem is "no files to process" vs. "can't access files."

**Step 3: Check resource availability**
Verify database connectivity, disk space, network shares, and memory. Try connecting to the database manually from the server.
*Reveals:* Whether an external dependency (DB, disk, network) is unavailable, causing the service to fail silently.

**Step 4: Check the service's internal state**
Look at any service-specific log files (not just Windows Event Log). Check if the timer/scheduler thread is still alive. Attach a debugger or add diagnostic logging if necessary.
*Reveals:* Whether the timer has stopped firing, the processing thread is deadlocked, or an unhandled exception killed the worker thread while the service host remains alive.

#### 5.2.2 — "Running" vs. actually processing

The Windows Service Control Manager (SCM) only monitors the **host process** — if the process is alive and responds to service control requests, it reports "Running." However, the actual *work* (file processing) happens on internal threads. A worker thread can crash, deadlock, or have its timer stop without affecting the host process. The service is "Running" (process alive) but not "working" (no files processed).

#### 5.2.3 — Where to look if failing silently

1. **Exception handling:** The processing code likely catches exceptions and swallows them (empty `catch` blocks). Check for `try/catch` blocks that don't log.
2. **Output/error directories:** Check if files are moved to an error/quarantine folder.
3. **Database state:** Check for locked transactions, deadlocks, or connection pool exhaustion.
4. **File format/corruption:** The files arriving after 08:00 may have a different format or encoding causing parse failures.
5. **Return values:** Check if a "success" flag is being set without verifying the actual operation completed.

#### 5.2.4 — Testing timer vs. processing logic

**Temporarily trigger the processing logic manually:**

1. Create a small test console application (or expose a debug endpoint) that calls the same processing method directly, bypassing the timer.
2. Place a known-good test file in the input directory and run the processing method.
3. **If it succeeds:** The timer/scheduler is the problem (thread died, interval misconfigured, etc.).
4. **If it fails:** The processing logic itself is broken (data issue, dependency failure, etc.).

Alternatively, restart the service and observe whether it processes the first batch successfully (which would confirm the timer eventually stops after a period of running).

---

### 5.3

The following SQL returns NULL when calculating the total cost of a fruit order.

```sql
DECLARE @BasePrice FLOAT = NULL, @VATAmount FLOAT = NULL;
SET @BasePrice = 10.90;
SELECT (@BasePrice + @VATAmount) AS TotalCost;
```

**5.3.1** Explain why this happens and provide two different solutions.

**Explanation Required:**

**5.3.2** Which solution would you prefer for a production pricing system and why?

**5.3.3** How would you handle the case where `@BasePrice` itself might be NULL?

**5.3.4** In what business scenario might you actually want NULL as the result?

### Answer

**Code reference:** `Part 5\SQL\Test_TotalCost_NullPropagation.sql`

#### 5.3.1 — Why it returns NULL and two solutions

**Why:** In SQL, any arithmetic operation involving NULL yields NULL. Since `@VATAmount` is NULL, `@BasePrice + @VATAmount` = `10.90 + NULL` = `NULL`. NULL represents "unknown" — adding a known value to an unknown value produces an unknown result.

**Solution 1 — ISNULL (T-SQL specific):**
```sql
SELECT (@BasePrice + ISNULL(@VATAmount, 0)) AS TotalCost;
```

**Solution 2 — COALESCE (ANSI SQL standard):**
```sql
SELECT (@BasePrice + COALESCE(@VATAmount, 0)) AS TotalCost;
```

Both replace NULL with 0 before the addition, yielding `10.90 + 0 = 10.90`.

#### 5.3.2 — Preferred solution for production pricing

**COALESCE** is preferred because:
1. **Portability** — ANSI standard, works across all database systems (SQL Server, PostgreSQL, Oracle, MySQL).
2. **Extensibility** — Accepts multiple fallback values: `COALESCE(@VATAmount, @DefaultVAT, 0)`.
3. **Type safety** — Uses the highest-precedence data type, avoiding silent truncation (unlike `ISNULL` which uses the first argument's type).

#### 5.3.3 — Handling NULL @BasePrice

If `@BasePrice` itself might be NULL, wrap both variables:

```sql
SELECT (COALESCE(@BasePrice, 0) + COALESCE(@VATAmount, 0)) AS TotalCost;
```

The choice depends on business rules: should a missing price produce 0 or signal an error? In a production system you'd likely want to raise an error or log a warning rather than silently defaulting to 0.

#### 5.3.4 — When NULL as result is desirable

**Scenario:** In a **draft/provisional order** system where VAT has not yet been calculated (e.g., awaiting tax jurisdiction determination). Returning NULL signals "total cost is not yet determinable" rather than misleadingly showing a partial amount. Downstream systems can then display "Pending" instead of an incorrect subtotal, and reports can filter `WHERE TotalCost IS NOT NULL` to only show finalized orders.
