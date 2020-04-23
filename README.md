# Download F5 Automation Tool Chain Components

## Introduction

The F5 Networks ATC (Automation Tool Chain) components are hosted on Github. In order the be able to use them in Cloud Init scripts and alike, one needs to have the full URL of the RPM download in the release sections of the following Github repos

 - https://github.com/F5Networks/f5-declarative-onboarding
 - https://github.com/F5Networks/f5-appsvcs-extension
 - https://github.com/F5Networks/f5-telemetry-streaming
 - https://github.com/F5Networks/f5-cloud-failover-extension

In order to make this more easy, this bash script has been created, which includes some pre-checks and does the fetch and download steps in a loop to mitigate network failures. It uses the Github API to fetch the correct release URL and downloads the RPM in a specified target location

## Usage

In order to use this script, you can just run it. If the necessary input parameters are not provided correctly, it will give a helper message

```console
# ./fetch_atc_rpm.sh                    
Usage: fetch_atc_rpm.sh <atc_component> <component_version> <output_file>
    <atc_component> should be one of the following:
        DO/do   : Declarative Onboarding
        AS3/as3 : Application Services 3
        TS/ts   : Telemetry Streaming
        CFE/cfe : Cloud Failover Extension
    <component_version> the version like a.b.c (with a b and c numbers only)
    <output_file> absolute output file path in a pre-existing folder
```

To download a specific RPM for one of the ATC components

```console
# ./fetch_atc_rpm.sh do 1.12.0 /tmp/do.rpm
Curl Github API on https://api.github.com/repos/F5Networks/f5-declarative-onboarding/releases/tags/v1.12.0 for do release information
Downloading do RPM file from Github into /tmp/do.rpm
Downloaded do Github release : https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.12.0/f5-declarative-onboarding-1.12.0-1.noarch.rpm
Resulting do RPM file stored : /tmp/do.rpm

# ./fetch_atc_rpm.sh as3 3.19.0 /tmp/as3.rpm
Curl Github API on https://api.github.com/repos/F5Networks/f5-appsvcs-extension/releases/tags/v3.19.0 for as3 release information
Downloading as3 RPM file from Github into /tmp/as3.rpm
Downloaded as3 Github release : https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.19.0/f5-appsvcs-3.19.0-4.noarch.rpm
Resulting as3 RPM file stored : /tmp/as3.rpm

# ./fetch_atc_rpm.sh ts 1.11.0 /tmp/ts.rpm
Curl Github API on https://api.github.com/repos/F5Networks/f5-telemetry-streaming/releases/tags/v1.11.0 for ts release information
Downloading ts RPM file from Github into /tmp/ts.rpm
Downloaded ts Github release : https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.11.0/f5-telemetry-1.11.0-1.noarch.rpm
Resulting ts RPM file stored : /tmp/ts.rpm

# ./fetch_atc_rpm.sh cfe 1.2.0 /tmp/cfe.rpm
Curl Github API on https://api.github.com/repos/F5Networks/f5-cloud-failover-extension/releases/tags/v1.2.0 for cfe release information
Downloading cfe RPM file from Github into /tmp/cfe.rpm
Downloaded cfe Github release : https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.2.0/f5-cloud-failover-1.2.0-0.noarch.rpm
Resulting cfe RPM file stored : /tmp/cfe.rpm

# ls -la /tmp/*.rpm
-rw-r--r--  1 me  wheel  14764987 Apr 23 18:42 /tmp/as3.rpm
-rw-r--r--  1 me  wheel  25238206 Apr 23 18:43 /tmp/cfe.rpm
-rw-r--r--  1 me  wheel   1594337 Apr 23 18:42 /tmp/do.rpm
-rw-r--r--  1 me  wheel   9625313 Apr 23 18:43 /tmp/ts.rpm
```

## Extra Information
More information on the F5 Automation Tool Chain Components can be found on

 - DO  : https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest
 - AS3 : https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/
 - TS  : https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest
 - CFE : https://clouddocs.f5.com/products/extensions/f5-cloud-failover/latest

## Note
This script is purely used for demo purposes and not meant for production environments at all
