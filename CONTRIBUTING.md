# Maintaining this portfolio

## Project documentation

Use these sections: purpose, status, architecture, implementation, prerequisites, deployment order, validation, cleanup and next steps. Link to real files using relative Markdown links. Explain each important trade-off and distinguish a planned component from a deployed one.

## Evidence for a completed milestone

- Record the test date, Azure CLI/PowerShell versions and the environment used, excluding sensitive IDs.
- Verify resource creation, access restrictions, DNS and the application flow relevant to the project.
- Capture screenshots or redacted command output. Include negative tests, such as an unauthorised connection being denied.
- Confirm teardown and list anything intentionally retained.
- For resilience claims, include a failure/recovery test and observed results. An availability set alone does not demonstrate application failover.

## Script changes

Use explicit scopes, parameters and checked native-command exit codes. Read credentials at runtime. Avoid subscription-wide mutations or cleanup based only on broad display-name matching. Make teardown deliberate and scope it to the resources created by the lab.

Run `./tools/Test-Repository.ps1` before a change is shared. This is an offline check; validate CLI arguments and deployment behaviour separately in an isolated Azure environment.
