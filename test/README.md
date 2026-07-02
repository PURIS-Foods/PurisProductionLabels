# PurisProductionLabels — Test Suite

This folder is a separate AL test application that targets the main `PurisProductionLabels` extension. Tests are run from the VS Code Testing panel against a Business Central sandbox.

**App ID:** `b3f2a1c4-7e8d-4f9a-bc12-3d4e5f6a7b8c`  
**ID range:** 50100–50149  
**Depends on:** PurisProductionLabels (Puris), Barcode Generator (Insight Works)

---

## Setup and running tests

### Prerequisites

- A Business Central sandbox environment with the AL development environment configured in VS Code.
- The Insight Works Barcode Generator extension installed in the sandbox.
- The main `PurisProductionLabels` app (`app/app.json`) already published and installed in the sandbox. If you have not done this yet, open the `app/` folder in VS Code and run `AL: Publish` (`Ctrl+Shift+B`) first.
- For codeunit 50102 (`PurisProdOrderActionTests`): the test extension must be published to a company whose name contains 'proteins' (e.g. `PURIS Proteins`). The Print Production Labels action is hidden in all other companies. Codeunits 50100 and 50101 can run from any company.

### One-time setup

1. Open the `test/` folder as the active AL project in VS Code (or add it as a second workspace folder alongside `app/`).
2. Confirm that `.vscode/launch.json` in the `test/` folder points to your sandbox environment. The `"environmentName"` value must match your target sandbox and `"environmentType"` must be `"Sandbox"`.
3. Download symbols: `AL: Download Symbols` from the command palette. This pulls in the main app's symbols so the test codeunits can reference its objects.

### Publishing and running

1. With the `test/` folder as the active project, publish the test app: `AL: Publish` (`Ctrl+Shift+B`). This deploys the test codeunits to the sandbox without touching the main app.
2. Open the Testing panel in VS Code: **View → Testing** (or click the Testing icon in the sidebar).
3. Click **Run Tests** at the top of the panel to execute all tests.
4. Each test shows a pass (green checkmark) or fail (red X). Click a failed test to see the error message and the line in the test codeunit where it failed.

### Re-running after code changes

- If you change only test files (under `test/`): republish the test app (`Ctrl+Shift+B`) and click **Run Tests** again.
- If you change main app files (under `app/`): republish the main app first, then republish the test app, then re-run.
- Tests clean up their own data via `Initialize()` at the start of each test, so there is no manual data cleanup required between runs.

---

## Automated test coverage

### `PurisCompanyScopeCheckTests.al` — codeunit 50100

Tests the `CompanyScopeCheck` codeunit (50201). All tests run as negative-path checks from within the test company. Positive-path tests (where `isProteins()`, `isGrains()`, or `isAllowed()` return true) cannot be written here because `CompanyName()` is a session-level built-in that cannot be overridden mid-test — see **What requires manual testing** below.

| Test | What it verifies |
|------|-----------------|
| `isProteins_WhenCompanyNotProteins_ReturnsFalse` | `isProteins()` returns false when company name does not contain 'proteins' |
| `isGrains_WhenCompanyNotGrains_ReturnsFalse` | `isGrains()` returns false when company name does not contain 'Grains' |
| `isAllowed_WhenCompanyNotPurisGrains_ReturnsFalse` | `isAllowed()` returns false when company name is not exactly 'PURIS Grains' |
| `isProteins_CaseInsensitive_ReturnsFalse` | `isProteins()` uses `ToLower().Contains('proteins')` — confirms no accidental case-insensitive match |

---

### `PurisProductionDataChecksTests.al` — codeunit 50101

Tests the `PurisProductionDataChecks` codeunit (50202). Each test inserts `Prod. Order Routing Line` records directly under order number `TEST-0001` and cleans them up at the start of the next test via `Initialize()`.

| Test | Type | What it verifies |
|------|------|-----------------|
| `AllLinesValid_ReturnsZero` | Positive | All routing lines have Work Center No. and Operation No. → returns 0 |
| `MissingWorkCenter_ThrowsError` | Negative | A routing line with blank Work Center No. → `Error()` thrown |
| `MissingOperationNo_ThrowsError` | Negative | A routing line with blank Operation No. → `Error()` thrown |
| `NoRoutingLines_ReturnsZero` | Positive | No routing lines for the order → returns 0 (nothing to validate) |

---

### `PurisProdOrderActionTests.al` — codeunit 50102

Tests the validation logic inside the `OnAction` trigger of the `PurisProductionLabels` page extension. Must be run from the `PURIS Proteins` company — the action is hidden via `ShowProteinsFields` in all other companies.

Test data is inserted directly under order number `TEST-PA-001` and cleaned up at the start of each test. `[MessageHandler]` and `[ReportHandler]` are used to absorb dialogs and suppress actual report rendering.

| Test | Type | What it verifies |
|------|------|-----------------|
| `PrintAction_MissingRoutingNo_ShowsMessage` | Negative | A prod line with no Routing No. → warning message shown, report not run |
| `PrintAction_MissingWorkCenter_ShowsMessage` | Negative | A routing line with no Work Center No. → warning message shown, report not run |
| `PrintAction_RoutingCountLessThanLineCount_ShowsMessage` | Negative | Fewer routing lines than prod lines → warning message shown, report not run |
| `PrintAction_AllDataValid_RunsReport` | Positive | All routing data populated → report invoked (rendering suppressed by handler) |

---

## What requires manual testing

### CompanyScopeCheck positive paths

`isProteins()`, `isGrains()`, and `isAllowed()` can only return true when `CompanyName()` matches. Since `CompanyName()` is session-level and cannot be overridden in AL test code, positive-path coverage requires running the tests from a company with the appropriate name:

| Method | Requires company name |
|--------|----------------------|
| `isProteins()` → true | Contains 'proteins' (case-insensitive), e.g. `PURIS Proteins` |
| `isGrains()` → true | Contains 'Grains' (case-sensitive), e.g. `PURIS Grains` |
| `isAllowed()` → true | Exactly `PURIS Grains` |

### Page action in non-proteins companies

Codeunit 50102 cannot be run outside of a proteins company. The action is not visible (and therefore not invokable) when `isProteins()` returns false. There is no workaround without refactoring `CompanyScopeCheck` to accept a company name parameter.

### Report rendering

`PrintAction_AllDataValid_RunsReport` confirms the report is invoked but suppresses rendering via `[ReportHandler]`. The actual label layout, barcode generation, and printer output must be verified manually by printing from a Released Production Order in the `PURIS Proteins` sandbox.
