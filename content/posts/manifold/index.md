---
title: I really like Manifold library.
date: 2026-04-28
description: Choosing a better stack for parametric 3d modeling
---

Is it me or is it just a fantasy? With `let joke = 67;`

```rust
let foo: 5;

fn add(a: f64, b: f64) -> f64 {
  a + b
}
```

Let's quote an author:

> Who is right here **bold** _italic_

## Subtitle

This is a table:

| Product ID | Item Name           | Price  | Stock Status |
| :--------- | :------------------ | :----- | :----------- |
| #1024      | Wireless `Mouse`    | $25.00 | In Stock     |
| #1025      | Mechanical Keyboard | $89.99 | Low Stock    |
| #1026      | USB-C Cable (1m)    | $9.50  | Out of Stock |

## Paragraph

If you are designing a mobile app or website and want to use Figma’s native
Variables feature to automatically flip your UI mockups from light to dark mode
with a single click, this is locked behind a paid plan.

## SPF

sender policy framework

> "Is this server allowed to send for this domain?"

- Lists valid send servers for the domain
- Format: `v=spf1 [mechanisms] [qualifier]~all`

## DKIM

domain keys identified mail

> Is this email authentic and unmodified?

- Contains sending servers public key, which is used to sign mails
- Can be pointed to via CNAME record
- Format: `v=DKIM1; k=rsa; p=[base_64_public_key]`

## DMARC

domain-based message authentication reporting and conformance

> What to do, if it fails?

- Contains policy for handling failures
- Format: `v=DMARC1; p=[none|quarantine|reject>; rua=mailto:abuse@example.com`
- Forbid `user@subdomain.example.com` for _SPF_ and _DKIM_ by setting
  `adkim=[s|r]; aspf=[s|r]` to strict `s`. Default is `r` - relaxed
