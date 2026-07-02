# CLAUDE.md — Best-in-Class Business Central Extension Development

This file is the operating contract for Claude Code in this repository. Every session that touches AL code MUST read this file at start and follow the rules below. The intent is to produce best-in-class Microsoft Dynamics 365 Business Central extensions by default — no guessing, no shortcuts, no silent drift from team standards.

Rule language: **MUST** / **MUST NOT** = non-negotiable. **SHOULD** / **SHOULD NOT** = strong default; deviate only with explicit user approval and a documented reason. **MAY** = permitted at Claude's discretion.

---

## 1. Project Identity

This repository is `PurisProductionLabels` — the per-tenant extension (PTE) for **Microsoft Dynamics 365 Business Central** that provides the ability to print custom production labels from released production orders at the Dawson facility for Puris Proteins, owned by Puris. AL source lives under `app/`. Test code lives under `test/` as a separate AL project.

| Field        | Value                                            |
| ------------ | ------------------------------------------------ |
| App name     | PurisProductionLabels                            |
| Publisher    | Puris                                            |
| Application  | 26.0.0.0                                         |
| Platform     | 1.0.0.0                                          |
| Runtime      | 15.0                                             |
| ID range     | 50200-50210                                      |
| Features     | `NoImplicitWith`                                 |
| Dependencies | Barcode Generator (Insight Works)                |

Manifest source of truth: `app/app.json`. Feature/API documentation: `app/readme.md`. Read both at session start.

---

## 2. Documentation Hierarchy — the core rule

Before recommending any non-trivial AL pattern, object property, API behavior, or platform feature, Claude MUST consult sources in strict tier order. "Non-trivial" means anything beyond pure AL syntax basics (variable declaration, loops, simple `if`).

### Local Project Reference — bc_documentation.pdf

Before consulting any external source, Claude MUST read relevant sections of `bc_documentation.pdf` (located at the repo root) when any of the following apply:

- Writing or modifying AL code for any object in this extension (tables, pages, codeunits, reports, enums, permission sets, table extensions, page extensions).
- Implementing or changing business logic related to production label printing, data matrix barcode generation, production order data validation, warehouse scanner integration, or company-scoped access control within Puris Proteins.
- Uncertain about how a feature should behave or how data should flow within this extension.
- Diagnosing a bug or regression in existing extension behavior.

`bc_documentation.pdf` is the primary local reference for domain-specific behavior and internal design decisions. Claude MUST read it **before** fetching any external Tier 1–3 source when working on code in this repo. If the PDF does not address the question or cannot be found in the repo, proceed to Tier 1 below.


### Tier 1 — Microsoft Learn (authoritative)

Base URL: `https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/`

Claude MUST `WebFetch` the relevant Learn page before citing platform behavior. Cite the exact URL inline in responses. Verified canonical entry points (re-verified during CLAUDE.md authoring on 2026-05-05):

| Topic                       | Path (relative to base URL)                       | Last verified ms.date |
| --------------------------- | ------------------------------------------------- | --------------------- |
| Developer overview          | `developer/devenv-dev-overview`                   | 2026-04-02            |
| Events in AL                | `developer/devenv-events-in-al`                   | 2025-07-17            |
| API page type               | `developer/devenv-api-pagetype`                   | 2025-06-04            |
| Performance for developers  | `performance/performance-developer`               | 2025-05-07            |
| Code analysis tool          | `developer/devenv-using-code-analysis-tool`       | 2026-02-26            |
| Testing the application     | `developer/devenv-testing-application`            | 2026-04-01            |
| JSON files (app.json etc.)  | `developer/devenv-json-files`                     | 2026-04-01            |
| Extension types and scope   | `developer/devenv-extension-types-and-scope`      | 2026-02-26            |
| AppSource submission checklist | `developer/devenv-checklist-submission`        | 2026-02-26            |
| Object ranges               | `developer/devenv-object-ranges`                  | not yet verified      |

> **DO NOT** cite `developer/devenv-api-pages` — that URL returns 404. The canonical API page reference is `developer/devenv-api-pagetype`.

If more than 6 months have passed since the last-verified `ms.date` (visible in the article frontmatter and at the bottom of every learn.microsoft.com page), Claude MUST re-verify the URL via WebFetch before citing.

Other Tier 1 sources (use the same WebFetch-and-cite discipline):

- Official Microsoft GitHub repos: `microsoft/AL`, `microsoft/ALAppExtensions`, `microsoft/BCApps`
- Microsoft BC release notes (`learn.microsoft.com/en-us/dynamics365/release-plan/`)
- Microsoft BC admin docs (`learn.microsoft.com/en-us/dynamics365/business-central/admin-...`)

### Tier 2 — Trusted dedicated blogs

Use ONLY when Tier 1 is silent or ambiguous. Cite with author + post date.

- **vjeko.com** — Vjekoslav Babic
- **waldo.be** — Eric Wauters
- **demiliani.com** — Stefano Demiliani
- **kauffmann.nl** — AJ Kauffmann
- **techcommunity.microsoft.com** — BC team blog
- **stevenrenders.com** / **krayis.com** — Steven Renders
- **archerpoint.com/blog** — ArcherPoint
- **bismart-blog** — BiSmart
- **olofsimren.com** — Olof Simren

### Tier 3 — Forums (last resort)

Use ONLY when Tiers 1 and 2 are silent. Treat answers as hypotheses to verify, never as authority.

- `community.dynamics.com`
- `learn.microsoft.com/en-us/answers` (Microsoft Q&A)
- Stack Overflow `[dynamics-business-central]` tag

### If even Tier 3 is silent

Claude MUST report "no authoritative source found" rather than invent an answer or rely on training-knowledge guesses. Recommend the user open a Microsoft support ticket or post the question to one of the Tier 3 forums.

### Citation format

Every non-trivial recommendation includes the source URL inline. Example:

> Use `SetLoadFields` before `Find*` to limit columns retrieved [per learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/performance/performance-developer].

For Tier 2/3, include author + date:

> Vjeko recommends X for Y [vjeko.com/article-slug, Babic, 2024-09-12].

---

## 3. AL Coding Standards

- **Puris prefix**: All NEW objects MUST use the `Puris` prefix (tables, table extensions, pages, page extensions, codeunits, APIs, reports, report extensions, permission sets, enums, queries, XMLports). No suffix mandate — `Ext` is encouraged for extensions but not required.
- **One object per file**: Each `.al` file contains exactly one AL object. The file name MUST match the object name.
- **Folder layout**: All AL source lives under `app/`. Test code lives under `test/Codeunits/` as a separate AL project.
  PageExtensions MUST live in domain subfolders (`SalesOrders/`, `Customers/`, `ProductionOrders/`, etc.).
- **Object IDs**: MUST follow the bucketed numbering scheme in §4.
- **Object identifier length**: AL platform limit is **30 characters**. The `Puris` prefix consumes 5 chars, leaving 25 for the rest. Plan abbreviations (`Production` → `Prod`, `AccountManagers` → `AcctMgrs`, drop "On" prepositions) before exceeding the limit. The compiler errors with `AL0305` if violated.
- **`NoImplicitWith`**: Enabled in `app.json`. NEVER write `with` statements. Always qualify record fields with the record variable name (e.g., `SalesHeader."Document No."`, not `"Document No."`).
- **Labels**: All user-facing strings MUST use `Label` constants. Hardcoded text in `Message`, `Error`, `Confirm`, captions, and tooltips is NOT permitted in new code.
- **Captions and tooltips**: Every page field MUST declare both `Caption` and `ToolTip`. Every table field MUST declare a `Caption`. (Tooltips on table fields are permitted in BC 2024 release wave 1+ and SHOULD be used.)
- **DataClassification**: Every new table field MUST set `DataClassification` to a value other than `ToBeClassified` (per AppSource technical validation rules; good practice even for PTEs).

---

## 4. Extension Architecture & Object ID Numbering

### Architecture

`PurisProductionLabels` follows a focused, single-responsibility design: it adds a label-printing action to the standard `Released Production Order` page and generates custom production labels with data matrix barcodes for use at the Dawson facility.

**Data layer**: No custom tables or table extensions. The extension reads directly from the BC `Production Order` and related base tables. All production data is sourced from standard BC objects — no custom permanent tables are needed.

**Presentation layer**: The `PurisProductionLabels` page extension (50200) extends the BC `Released Production Order` page. It adds a "Print Production Labels" action that gives production floor users a single-click entry point to generate and print labels directly from the standard BC production order UI.

**Report layer**: The `PurisProductionLabels` report (50200) is the core output object. It reads production order data, formats it into a label layout containing data matrix barcodes (generated via the Insight Works Barcode Generator dependency), and sends output to a printer. Labels are affixed to product at the Dawson facility and scanned by warehouse devices to post production output in BC.

**Logic layer**: Two codeunits handle validation and access control:
- `CompanyScopeCheck` (50201): company name check that gates label printing to the Proteins Production legal entity; errors if run in any other company.
- `PurisProductionDataChecks` (50202): validates production order data before label generation — ensures required fields are populated and the order is in a printable state.

**Dependencies**: The Insight Works Barcode Generator extension (ID: `62080fe0-d57f-4d4c-aed1-ac539db3a244`, v1.7.9167.3) provides barcode image generation used by the label report to produce data matrix codes readable by Dawson warehouse scanners.

---

### ID Range & Bucketing

`app.json` declares `idRanges: [{"from": 50200, "to": 50210}]` — 11 IDs. AL's per-type ID namespacing means the same integer may be used by different object types without conflict (e.g., `codeunit 50200` and `report 50200` coexist legally). A given (ID, type) pair must still be unique.

PTEs may use any ID in the 50000–99999 per-tenant range without external registration.

#### Bucketed numbering scheme

| Type | Bucket | Purpose |
|------|--------|---------|
| Page Extensions | 50200 | Production order UI actions |
| Reports | 50200 | Production label printing |
| Codeunits | 50201–50202 | Business logic and utilities |
| Reserved | 50203–50210 | Future objects of any type |

#### Object ID inventory — MANDATORY reference before assigning any new ID

**Active objects:**

| ID | Type | Object Name | Notes |
|----|------|-------------|-------|
| 50200 | Page Extension | PurisProductionLabels | Adds Print Production Labels action to Released Production Order page |
| 50200 | Report | PurisProductionLabels | Prints data matrix barcode production labels for Dawson warehouse scanners |
| 50201 | Codeunit | CompanyScopeCheck | Company scope guard: restricts label printing to Proteins Production environment |
| 50202 | Codeunit | PurisProductionDataChecks | Validates production order data before label generation |

#### Allocation procedure (Claude MUST follow before assigning a new object ID)

1. Identify the object type (Table, Table Extension, Page, Page Extension, Codeunit, Report, Enum, Permission Set, etc.).
2. Determine the appropriate bucket from the bucketed scheme above.
3. Search the repo to confirm the candidate (ID, type) pair is free:
   ```
   grep -rEn '<object-type-keyword> <id>' .
   ```
   e.g., `grep -rEn 'codeunit 50203' .`
4. Use the lowest unoccupied ID in the appropriate bucket for that object type.
5. If no unoccupied (ID, type) pair remains in the target bucket, use the next available ID in the reserved bucket (50203–50210).
6. If no unoccupied (ID, type) pair remains in 50200–50210 for the needed object type, **STOP** — ask the user to expand `idRanges` in `app.json` before proceeding.
7. **MUST NOT** allocate outside the declared range (50200–50210) without explicit user approval and a corresponding `app.json` range update.

---

## 5. Performance & Data Patterns

Each rule below is grounded in `learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/performance/performance-developer`. Claude SHOULD WebFetch that page when applying any rule for the first time in a session, to ensure recommendations match the current Microsoft guidance.

- **`SetLoadFields`**: Use before any `Find*` / `Get` when only a subset of fields is needed. Reduces SQL columns read AND eliminates unnecessary table-extension joins.
- **`SetAutoCalcFields`**: Use ONLY when FlowFields will actually be consumed in the loop. Never blanket-enable.
- **`FindSet`**: Prefer `FindSet(true)` for write loops, `FindSet(false)` (or just `FindSet()`) for read-only loops. Use `Find('-')` only when iterating with modifications-during-iteration semantics.
- **Keys**: Design keys with the most-filtered fields first. Add SIFT keys ONLY on numeric columns that need `CalcSums`. Indexes have a write cost — do not over-add.
- **Transactions and locking**: Wrap multi-record writes in a clear transaction scope. Call `LockTable` only when contention risk is real, and as late as possible in the transaction (per MS guidance, `LockTable` applies `WITH (updlock)` on ALL subsequent reads of that table for the rest of the transaction).
- **FlowFields in API pages**: Avoid FlowFields on API pages without explicit `SetAutoCalcFields` — they cause N+1 queries. Per MS performance guidance, FlowFields exposed via API/web service are a known anti-pattern.
- **Table extension field count**: Avoid splitting customizations across many table extensions on a single base table — even with the BC 2023 wave 2 single-companion-table model, indexes cannot span base + extension fields.
- **Set-based methods**: Prefer `CalcSums`, `ModifyAll`, `DeleteAll`, query objects over row-by-row loops.
- **`OnAfterGetRecord`**: Keep minimal. Avoid `CalcFields`, `CurrPage.Update()`, filter changes, and any database writes.
- **External HTTP calls**: Block AL execution. NEVER place outgoing HTTP calls in `OnCompanyOpen` / `OnCompanyOpenCompleted` event subscribers — they delay every session start.

---

## 6. Extensibility & Upgrade Safety

- **Event subscribers over modification**: Prefer event subscribers; NEVER modify base-app objects directly.
- **Subscriber syntax**:
  ```al
  [EventSubscriber(ObjectType::Codeunit, Codeunit::"<base-codeunit>", '<EventName>', '<ElementName>', false, false)]
  local procedure <DescriptiveName>(...)
  ```
  Procedure names SHOULD encode source object + event (the existing `PFInvOnAfterlineOnPreDataItem` pattern is acceptable).
- **Subscriber codeunit hygiene** (per MS performance guidance):
  - Keep subscriber codeunits small.
  - Use `EventSubscriberInstance = StaticAutomatic` (default) only when needed; `Manual` binding has lower overhead but requires explicit `BindSubscription`.
  - Subscribe to table events sparingly — they force row-by-row SQL operations and disable bulk `ModifyAll`/`DeleteAll`.
- **Table extension upgrade safety**: NEVER delete or rename a field once shipped. Add only. Renaming or removing breaks data upgrade.
- **`app.json` versioning**: Four-segment version `Major.Minor.Build.Revision`.
  - Bump **revision** for non-breaking fixes.
  - Bump **build** for new features (additive).
  - Bump **minor** for user-visible behavior changes.
  - Bump **major** for breaking changes.
  - Document every bump in a `CHANGELOG.md` entry (create the file on first version bump).
- **Dependencies**: Declare every dependency explicitly in `app.json`. Never rely on transitive dependencies. If you depend on a Microsoft system-application module, confirm via `microsoft/BCApps` GitHub before adding.

---

## 7. API Design Conventions

> **Note:** This extension contains no API pages as of v1.0.0.1. The conventions below apply if API pages are added in the future.

Canonical Microsoft reference: `learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-api-pagetype`. (NOT `devenv-api-pages` — that URL 404s.)

If API pages are introduced, follow these conventions:

- `APIPublisher = 'Puris'` on all API pages.
- `APIGroup = 'purisAPIs'` on all API pages.
- `APIVersion = 'v1.0'` (initial). New API versions add to the list, e.g. `APIVersion = 'v2.0', 'v1.0'`. Do NOT remove old versions without an integration partner sign-off.
- `EntityName` is camelCase singular (e.g., `packingListHeader`).
- `EntitySetName` is camelCase plural (e.g., `packingListHeaders`).
- The AL compiler enforces camelCase via warnings and rejects naming violations.
- `ODataKeyFields = SystemId` unless integration partners require a different natural key.
- Sub-pages: `PageType = API` with `SubPageLink`.
- API field names: snake_case. Not Microsoft-mandated, but keep consistent across all API pages in this repo.
- **Etag concurrency**: Clients MUST include `If-Match` on PATCH and DELETE. Document this in `readme.md`.
- **Important**: Per MS docs, API pages CANNOT be extended via page extensions. Adding fields requires modifying the API page directly AND bumping `APIVersion`.
- New APIs require a `readme.md` section with sample GET/POST/PATCH/DELETE bodies.

### API performance guardrails

- Avoid exposing FlowFields. If unavoidable, calculate them in a separate page or move the value to a physical field.
- Do not use `SourceTable` on a temporary record for APIs returning more than ~100 records (per MS performance guidance, temp-table API sources are a known anti-pattern).
- Set `DataAccessIntent = ReadOnly` on read-only API pages and queries to enable Read-Scale-Out (offloads to the read replica).

---

## 8. Active Analyzers

> **Note:** The AL project root is `app/` (where `app/app.json` lives). The `.vscode/settings.json` file sits at `app/.vscode/settings.json` and is gitignored (developer-local). A `.vscode/ruleset.json` SHOULD be committed to govern analyzer rule overrides — it does not yet exist in this repo; create it under `app/.vscode/` when first adding a rule suppression.

Add or update `.vscode/settings.json` with the content below to enable analyzers:

`.vscode/settings.json`:

```json
{
    "al.symbolsCountryRegion": "w1",
    "al.enableCodeAnalysis": true,
    "al.codeAnalyzers": [
        "${CodeCop}",
        "${UICop}",
        "${PerTenantExtensionCop}"
    ],
    "al.ruleSetPath": "./.vscode/ruleset.json"
}
```

- **CodeCop** — official AL coding guidelines (formatting, label discipline, etc.).
- **UICop** — UI rules (tooltips, page UX).
- **PerTenantExtensionCop** — rules specific to per-tenant extensions.
- **AppSourceCop** is NOT enabled (this app is not destined for AppSource). Add only if marketplace publication is planned.

### Ruleset

`.vscode/ruleset.json` (to be committed when first needed) should suppress rules globally with documented justifications inline. Anticipated suppressions for this repo:

| Rule | Reason to suppress |
|------|-------------------|
| AA0215 | File names not matching `<Object>.<Type>.al` convention; this repo uses descriptive `<Object>.al` naming (e.g., `ProductionLabels.al`, `CompanyScopeCheck.al`). |
| AA0218 | Page extension fields on list pages have no tooltip requirement per UICop; existing extensions predate the tooltip mandate. |

Add new suppressions to the ruleset file (not as inline `#pragma` comments) unless the suppression is truly one-off in a single legacy location.

Reference: `learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-using-code-analysis-tool`.

---

## 9. Testing

Test code lives at `test/` in this repo as a separate AL project. See `test/README.md` for setup instructions, how to run tests, and full coverage documentation.

### The cardinal rule

**Before making any code change, write a failing test for it first.** Only then make the change. A passing test suite with no new test is not an acceptable outcome for a non-trivial change.

### Gate behavior

**Before any non-trivial change to a feature that has NO existing tests**, Claude MUST:

1. Propose authoring tests for that feature in `test/Codeunits/` first.
2. Ask the user whether to proceed without them.

"Non-trivial" excludes: typo fixes, caption tweaks, single-line tooltip changes, `readme.md`-only edits, `.vscode/` settings adjustments.

### Test project identity

| Field | Value |
|-------|-------|
| App name | PurisProductionLabelsTests |
| Publisher | Puris |
| App ID | `b3f2a1c4-7e8d-4f9a-bc12-3d4e5f6a7b8c` |
| ID range | 50211–50260 |
| Depends on | PurisProductionLabels, Barcode Generator |

### Test codeunit conventions

- Place in `test/Codeunits/Puris<Feature>Tests.al`.
- Use namespace `Puris.Tests`.
- Add `using` directives for any BC namespace whose objects are referenced (e.g. `using Microsoft.Manufacturing.Document;`, `using Microsoft.Manufacturing.Routing;`). Without these, objects in named BC namespaces will not resolve from within `Puris.Tests`.
- `Subtype = Test`, max 100 test methods per codeunit, target <2 minutes runtime per codeunit.
- Follow arrange → act → assert pattern in every test method.
- Use `AssertError` for negative tests (expected `Error()` calls).
- Write `[MessageHandler]`, `[ConfirmHandler]`, and `[ReportHandler]` procedures instead of leaving UI calls unhandled — unhandled dialogs hang the test runner.
- Avoid hardcoded values — use `Any` library from `microsoft/BCApps` for random data when feasible.

### Test data policy

- **NEVER touch existing sandbox data.** All test data MUST use reserved test order numbers (`TEST-0001` for routing validation tests, `TEST-PA-001` for page action tests) that will never collide with real production orders.
- Each test codeunit calls `Initialize()` at the start of every test method. `Initialize()` deletes all records with the test order number before inserting fresh data — this is the cleanup mechanism.
- Insert test records directly (without triggers) using `Record.Init()` + field assignment + `Record.Insert()`. Do not use `Insert(true)` unless trigger execution is specifically required by the test.
- Codeunit 50102 (`PurisProdOrderActionTests`) MUST be run from a company whose name contains 'proteins' (e.g. `PURIS Proteins`). The page action is hidden in all other companies. Codeunits 50100 and 50101 can run from any company.

### Object ID inventory — test project

| ID | Type | Object Name |
|----|------|-------------|
| 50211 | Codeunit | PurisCompanyScopeCheckTests |
| 50212 | Codeunit | PurisProductionDataChecksTests |
| 50213 | Codeunit | PurisProdOrderActionTests |
| 50214–50260 | — | Reserved for future test codeunits |

---

## 10. Known Legacy Deviations — DO NOT silently fix

Items below are deliberately retained as-is. Claude MUST NOT modify any of them as a side effect of an unrelated task. Cleanup happens ONLY when the user explicitly requests it.

### Object IDs
none

### Code
none

### Resolved (historical reference)
none

---

## 11. Workflow Rules for Claude

- **Session start**: Always read `app/app.json` and `app/readme.md` when working on this repo. Re-read CLAUDE.md if the user references conventions. Read `test/README.md` when working on tests.
- **Verify before recommending**: Never quote AL syntax, object property semantics, or platform behavior from training memory alone for non-trivial topics. WebFetch the relevant Microsoft Learn page first (§2).
- **Edit over Write**: For existing `.al` files, prefer the `Edit` tool. Only use `Write` for genuinely new files.
- **Ask before**:
  - Deleting or renaming any object or field (upgrade-breaking).
  - Bumping `app.json` version.
  - Modifying `.vscode/settings.json` or `.vscode/ruleset.json`.
  - Modifying `idRanges` in `app/app.json` (currently 50200–50210) or `test/app.json` (currently 50211–50260).
  - Creating any new test codeunit (per §9 gate).
  - Touching legacy items listed in §10.
- **Do not run the AL compiler**: Claude does not invoke `AL: Package` or build the `.app` file. After AL changes, suggest the user run `Ctrl+Shift+B` in VS Code (or `AL: Package` from the command palette) to verify symbols resolve.
- **Do not modify `.snapshots/`, `.alpackages/`, or the compiled `.app` file**: those are build artifacts. These live at the repo root and must not be moved into `app/`.
- **`rad.json` and `snapshots.json`**: per Microsoft, these MUST NOT be edited manually.