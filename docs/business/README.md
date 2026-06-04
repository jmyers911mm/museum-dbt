# Start Here — Museum Data Platform (for business users)

Welcome. This page is written for everyone **outside** the data team — Development, Membership, Marketing, Operations, Education, and Finance. No technical background needed.

If you've ever asked *"how many people visited last weekend?"*, *"how is the spring campaign performing?"*, or *"are we retaining members?"* — the answers live here, and this page tells you exactly where to find them.

---

## What this platform is, in one paragraph

The Museum Data Platform brings together information from our ticketing, retail, donor, membership, and email systems into **one trusted place**. Instead of pulling separate reports from each system (and getting numbers that don't match), everyone now works from the same, consistent set of numbers — refreshed automatically every day. The dashboards you use are all built on top of this single foundation, so a "member" or a "visitor" or "revenue" means the same thing no matter which report you open.

---

## What questions can it answer?

The platform is organized into six areas. Each area has certified metrics and at least one dashboard.

| Area | Example questions it answers |
| --- | --- |
| **Attendance & Visitation** | How many people visited? When are our busiest hours and gates? How full are we against capacity? |
| **Revenue & Fundraising** | What did we earn from tickets, retail, and donations? What's the average transaction? |
| **Membership** | How many active members do we have? Who's lapsing? What's a member worth over time? |
| **Donor Relations** | Are we retaining donors? Which cohorts are at risk of churning? Who's ready to upgrade? |
| **Digital & Marketing** | How did the last email campaign perform — opens, clicks, unsubscribes? |
| **Operations** | What does a typical day/month look like across all revenue streams? |

---

## Find your dashboard

Match your question to the dashboard that answers it. If you don't have access, see [How to get access](#how-to-get-access) below.

| Your question | Dashboard | Best for |
| --- | --- | --- |
| "How did today/this week go across tickets, retail, and visitors?" | **Daily Operations** | Operations, leadership |
| "Where and when are visitors coming in? Are we near capacity?" | **Capacity Planning** | Operations, Visitor Experience |
| "How are members and donors trending? Who's lapsing or at risk?" | **Membership & Donors** | Membership, Development |
| "How is the gift shop / retail performing?" | **Retail Performance** | Retail, Operations |
| "How did our email campaign perform?" | **Campaign Analytics** | Marketing |
| "I have a question no dashboard answers" | **Ask the data team** (see below), or use the natural-language assistant | Everyone |

> **Natural-language option:** for ad-hoc questions, the platform includes an AI assistant (Cortex Agent) that answers questions in plain English against certified data. It only answers using *approved* definitions, so the numbers stay trustworthy. Ask the data team for access.

---

## How fresh is the data?

- **Dashboards refresh daily**, overnight, so when you arrive in the morning you're looking at yesterday's complete numbers.
- Incoming data is **monitored every hour** for freshness; if a source system is late or missing, the team is alerted automatically before stale numbers reach you.
- If something looks off, it may be a known issue already being tracked. Check with the data team rather than reconciling by hand — see [Who to ask](#who-to-ask).

*Need a faster-than-daily refresh for a specific report? That's possible for some sources — raise it with the data team.*

---

## What the numbers mean

Every metric on every dashboard has a **single, approved definition**. "Active member," "lifetime value," "valid scan rate," and "retention rate" all mean one specific thing, documented in plain language here:

➡️ **[Metric Glossary](METRIC_GLOSSARY.md)**

If a number on your dashboard doesn't match a number somewhere else, the glossary is the tie-breaker — and if the glossary doesn't settle it, that's a data-quality question for the team.

---

## How to get access

1. Identify which dashboard(s) you need (use the [report finder](#find-your-dashboard) above).
2. Request access through your manager or the data team. Access is granted by role, so you'll get the dashboards appropriate to your work.
3. Dashboards open in Power BI. The data team can point you to the workspace.

---

## Who to ask

Each area has a **business owner** (who decides what the metrics should mean) and the **data team** (who builds and maintains them).

| Area | Business owner | 
| --- | --- |
| Visitor Experience & Attendance | Sarah Chen |
| Development & Fundraising | Diane Foster |
| Membership | Rachel Torres |
| Marketing & Digital | Anna Kim |
| Operations | James Okafor |
| Education | Marcus Williams |
| Finance / executive framing | CFO |
| Platform & technology (overall) | Michael Cartier (CIO) |

For anything about how a number is built, whether data looks wrong, or requesting a new report: **contact the data team** (Jeremy Myers and the analytics team).

---

## I need a new metric or report

New metrics and reports are welcome — there's just one rule that keeps everyone's numbers trustworthy:

> **A metric's definition must be agreed and approved *before* it's built.** This prevents two dashboards from showing two different "membership counts."

The short version of the process:
1. Describe what you want to measure and why.
2. The data team drafts a precise definition.
3. The business owner for that area approves it.
4. Only then is it built and added to the [Metric Glossary](METRIC_GLOSSARY.md) and a dashboard.

This is governed formally by ADR-005 (see the [ADR Log](../adr/README.md)) — but as a business user, all you need to do is start the conversation with the data team.

---

## Where everything lives

This page is part of a larger documentation set. For the full map — including engineering docs and the Platform Hub — see the [Documentation Map](../README.md).