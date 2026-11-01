# Repository review · 1 November 2026

## Scope and evidence

Reviewed all project READMEs, PowerShell scripts, JSON/Bicep files and the seven original architecture PNGs. Existing staged and unstaged work was preserved; a pre-review copy of text assets was captured outside the repository. No Azure resources were created, changed or deleted during this review.

Local syntax, JSON, Markdown links and Bicep compilation are useful checks, but do not establish Azure CLI compatibility, permissions or working cloud deployments. Original compute screenshots are historical evidence, not evidence for the revised scripts. No image was altered or represented as a new deployment result.

## Corrections made

| Area | Finding | Change |
| --- | --- | --- |
| Repository | Seven-area index omitted workplace work and linked a nonexistent storage subfolder | Eight-area map, real links, evidence-based status and concise skills table |
| Documentation | Production-ready and complete-security claims exceeded implementation evidence | Replaced with specific scope, validation steps and remaining milestones |
| Compute | Windows creation used SSH-key arguments; RDP rule lacked a source restriction | Runtime Windows password, explicit NICs, subnet NSG and optional administrator /32 |
| Compute diagram | Availability set was drawn as a routing hop behind a shared public IP | Editable diagram shows individual IPs and explains the missing load-balancer milestone |
| Networking | Bastion /27, ambiguous backend-pool names, one-string tags and VM creation races | /26 subnet, backend-pool IDs, tag arrays and synchronous creation |
| Networking | App probe targeted 8080 while default IIS listened on 80 | Explicit IIS app-tier binding; guest output still needs verification |
| Networking | SQL password embedded in source; Blob anonymous-access flag confused with public network access | Runtime SQL password and explicit Storage public network disablement |
| Networking | Invalid Firewall collection command shape | Updated command name and required collection/rule arguments against CLI documentation |
| Routing | Default UDR claimed all traffic inspection and risked asymmetric public-LB return routing | Explained route limitations and blocked the draft association entry point pending integration design |
| Storage | Four overlapping/broad roles were assigned together | Explicit selected role; read-only Blob role is the default |
| Storage | Lifecycle depended on the caller's working directory; SAS example fetched keys and printed several broad tokens | Script-relative policy file; one short-lived read-only user-delegation token |
| Storage cleanup | Removed holds and data before asking about group removal | Explicit account target, ShouldProcess confirmation, no automatic hold removal |
| Identity | Owner was assigned as part of the normal loop; placeholders could reach CLI calls | Owner removed from defaults and subscription placeholders rejected |
| Monitoring | Invalid onboarding command, stray executable token and unclear agent setup | Explicit resource group, AMA install, system identity and existing-DCR destination check |
| Monitoring | Workspace script claimed legacy solution creation enabled VM Insights | Workspace creation separated from DCR/agent configuration |
| Governance | Locks targeted subscription-wide inventories and applied ReadOnly broadly | One explicit resource scope and CanNotDelete lock with WhatIf support |
| Governance audit | PSCustomObject tags treated as a hashtable | Null-safe property lookup; direct lock ID matching |
| Automation | Basic/Dynamic public IP and unrestricted RDP/SSH template rules | Standard/Static, private templates by default, explicit RDP source, no SSH rule on Windows template |
| Guest configuration | Unencrypted Basic WinRM and domain credentials embedded in Run Command | Those options blocked pending a secure implementation |
| Intune | Friendly design JSON presented like deployable policy exports | Clearly labelled design examples; export pagination/depth and directory creation corrected |

## Remaining engineering work

| Area | Required before a completed deployment claim |
| --- | --- |
| Compute | Rerun deployment, verify extension/guest outcomes and HTTP access, implement load balancing and test failover |
| Networking | Test CLI extensions and resource IDs; implement restrictive NSG rules with probe/Bastion allowances; enforce endpoint access on the correct subnet; resolve Firewall/public-LB return routes; deploy actual web/app logic and SQL access |
| Storage | Parameterise deployment inputs; validate private-network data commands, DNS, Kerberos client prerequisites and lifecycle/retention interaction |
| Identity | Shared explicit scope configuration; object-ID ownership manifest; service-principal-aware audit; scoped teardown |
| Monitoring | Tested DCR for counters, storage service diagnostic settings, valid log-alert conditions and workspace scope, absent-heartbeat test, byte-based capacity thresholds, resource-bound dashboard tiles and manifest-based cleanup |
| Governance | Missing policy JSON definitions and parameter schemas; consistent management-group scope; valid initiative JSON; one assignment strategy; tenant-root ID and approved placement; owned-resource cleanup |
| Automation | Native exit-code checks across old scripts; clear plaintext credentials on failure; validate post-configuration dependencies/reboots; manifest-based teardown; test CLI/template equivalence |
| Intune | Real Graph policy schema mappings, supported category assignment, test-group deployment and effective-setting evidence |

Known incomplete mutation/cleanup entry points fail immediately with a reason, retaining their draft implementation below the guard. This prevents an incomplete example from claiming success or deleting unrelated resources. Re-enable an entry point only after its documented issue is resolved and validated. These guardrails do not mean the other scripts have been cloud-tested.

## Architecture review

The editable Mermaid diagrams in each README describe the reviewed design and its boundaries. Original PNGs are retained as history:

- Compute: availability set is placement, not traffic distribution.
- Networking: Bastion requires /26 here; SQL endpoint is in `private-endpoints`, not `db-subnet`; Firewall is not automatically in every traffic path.
- Storage: DFS endpoint in the image has no corresponding script.
- Identity: diagram assumes separate subscriptions, while the helper also offers a resource-group lab fallback.
- Monitoring: original image duplicates its stack and reverses telemetry flow.
- Governance: conceptual compliance dashboard is not implemented evidence.
- Automation: CLI and template are separate paths, not one chained workflow.

## Primary references

- [Bastion configuration and subnet requirements](https://learn.microsoft.com/en-us/azure/bastion/configuration-settings)
- [Bastion network security groups](https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg)
- [Azure VM CLI reference](https://learn.microsoft.com/en-us/cli/azure/vm)
- [Firewall policy filter collections](https://learn.microsoft.com/en-us/cli/azure/network/firewall/policy/rule-collection-group/collection)
- [Azure Monitor Agent migration and DCRs](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-migration-tools)
- [DCR association CLI](https://learn.microsoft.com/en-us/cli/azure/monitor/data-collection/rule/association)

## Verification completed

- All 44 PowerShell files parsed without syntax errors.
- All 7 JSON files parsed successfully.
- Local Markdown targets checked across 15 README/documentation files.
- Bicep compiled successfully with no warnings after correcting the conditional public-IP reference.
- Git whitespace checks passed.
- Mocked execution verified two Windows compute VMs, no default RDP opening, app-tier backend-pool resource IDs, port 8080 configuration, and rejection of placeholder subscription IDs before any Azure call.

No live Azure deployment or tenant policy test was performed. Several draft entry points remain intentionally blocked for the reasons above.