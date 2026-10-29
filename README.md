# Binary options platform: architecture notes

A short reference for the parts of a fixed-payout (binary options) trading platform that must be built carefully: the trade record, the price feed, the ledger and the risk controls. It is a design reference, not a product.

Maintained by [Brandzivio](https://brandzivio.com), a software company in Gurugram, India.

> Compliance: binary options are not authorised by SEBI in India. Build only for a jurisdiction where you hold or are pursuing the licence, and confirm that with a securities lawyer. This repository is software design only, not legal advice, and promises no returns.

## Components

- **Trade engine**: accepts asset, direction, stake and expiry, fixes the payout percentage at entry, settles each trade at the recorded expiry price.
- **Price feed layer**: connects a licensed market-data provider, timestamps every tick and stores it, so any entry or expiry price can be audited.
- **Wallet and ledger**: double-entry ledger so balances always reconcile.
- **KYC and AML workflow**: vendor connection, account limits, flags for unusual activity.
- **Responsible-trading tools**: deposit and loss limits, cool-off periods, self-exclusion.
- **Admin back-office**: users, assets, payout percentages, exposure limits, reports, audit logs.

## The trade record

Disputes in a fixed-payout product are settled by data. The engine writes the same fields for every trade and never edits them afterwards. Corrections are new ledger entries.

| Stage | What happens | Fields recorded |
|---|---|---|
| Order accepted | User picks asset, direction, stake, expiry | user ID, asset, direction, stake, expiry time, payout percentage, accepted-at time |
| Entry price fixed | Last valid feed tick at acceptance | entry price, tick timestamp, feed source |
| Stake held | Wallet reserves the stake before the trade goes live | ledger entry ID, balance before and after |
| Expiry | First valid tick at or after expiry | expiry price, tick timestamp, feed source |
| Settlement | Result computed by the written rule, payout credited or stake released | result, payout amount, settlement ledger entry ID |
| Feed failure | No valid tick within the allowed gap; trading on the asset pauses | pause reason, affected open trades, resolution rule applied |

[`schema.sql`](schema.sql) is a PostgreSQL sketch of this record.

## Price feed

The price shown to the user and the price used at entry must come from the same source and the same tick. Taking the feed from a single source avoids the two drifting apart. Redundant feeds are an option where the budget allows, with latency monitoring and tick storage.

## Risk controls

- Exposure limit per asset and per user, with an automatic stop at the limit.
- Maximum stake and payout caps per trade.
- A circuit breaker that pauses an asset when the feed lags or stops, with a documented rule for open trades.
- Role-based admin access, two-factor authentication, encrypted data and an activity log.

## Full guide

Custom build versus white label, cost and timeline drivers, and what the client provides versus what the developer delivers: [binary options trading platform development guide](https://brandzivio.com/solutions/binary-trading-platform-development). The wider trading work is on the [trading app development](https://brandzivio.com/services/trading-app-development) page.

MIT licensed.
