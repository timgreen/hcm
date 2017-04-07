# Home Config Manager (hcm) Advanced Topics

## What Happens After I Run `hcm install`

For each of the

## What's a Managed Configs Directory (MCD) and Config Module (CM)

### Managed Configs Directory (MCD)

TBD

### Config Module (CM)

TBD

## What's HCM\_MCD\_ROOT and MODULE Files

### HCM\_MCD\_ROOT

For each of the Managed Configs Directory, hcm except to find a HCM\_MCD\_ROOT file in the root.
Otherwise hcm will refuse to continue.

WHY? First, this provents user accidently execute hcm in unexpected directory, especially for huge
directory if might take a long time for hcm to finish navigating. Second, in the future version of
hcm, the content of HCM\_MCD\_ROOT might be used as config.

### MODULE

TBD
