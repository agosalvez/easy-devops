# Security Policy

## Reporting a vulnerability

Please report vulnerabilities privately to the maintainer through the contact
details in the README. Do not open a public issue containing credentials,
private keys, personal data, or an unpatched exploit.

## Secret handling

Easy DevOps never tracks generated environment files, ACME state, certificates,
private keys, logs, or backups. Runtime data is stored below ignored directories.

## Historical ACME key

An ACME account key was previously committed in
`swarm/https/letsencrypt/acme.json`. Treat that key as compromised if the
repository was ever shared. The account owner must rotate it. Removing it from
the current tree does not remove it from Git history; history rewriting must be
coordinated separately because it changes published commit identifiers.
