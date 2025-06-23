---
title: Automating Microsoft Fabric Capacity Suspension
description: A PowerShell script to suspend Microsoft Fabric capacities using Azure Automation
---

# Automating Microsoft Fabric Capacity Suspension

## Overview

This article explains how to automate the suspension of Microsoft Fabric capacities using PowerShell and Azure Automation. This helps reduce costs by stopping unused capacities during off-hours.

## What the Script Does

- Authenticates with Azure using `Get-AzAccessToken`
- Iterates over multiple Fabric capacity resource IDs
- Sends a POST request to suspend each capacity
- Logs success, skip, and error messages

## Required Permissions

- **Contributor** role on the Fabric capacity
- If using Azure Automation, the **Managed Identity** must have the same permissions

## Prerequisites

- Azure subscription
- PowerShell 7.2+ (for local testing)
- Az PowerShell module (v11.2+)
- Azure Automation account (optional)

## Azure Automation Setup

1. **Create an Automation Account**
2. **Enable Managed Identity**
3. **Assign Contributor role to the identity**
4. **Import Az modules** (`Az.Accounts`, `Az.Resources`)
5. **Create a Runbook** and paste the script
6. **Test and schedule** the runbook

## Script File

The script is available here:  
📁 [suspend-fabric.ps1](/suspend-fabric.ps1)

## License

MIT License
