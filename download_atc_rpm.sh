#!/bin/bash
#
# Helper script that downloads ATC RPM components.
#

DO_BASE="https://api.github.com/repos/F5Networks/f5-declarative-onboarding/releases/tags/v"
AS3_BASE="https://api.github.com/repos/F5Networks/f5-appsvcs-extension/releases/tags/v"
TS_BASE="https://api.github.com/repos/F5Networks/f5-telemetry-streaming/releases/tags/v"
CFE_BASE="https://api.github.com/repos/F5Networks/f5-cloud-failover-extension/releases/tags/v"

VALID_COMPONENTS="do DO as3 AS3 ts TS cfe CFE"

function print-help {
  echo "Usage: fetch_atc_rpm.sh <atc_component> <component_version> <output_file>"
  echo "    <atc_component> should be one of the following:"
  echo "        DO/do   : Declarative Onboarding"
  echo "        AS3/as3 : Application Services 3"
  echo "        TS/ts   : Telemetry Streaming"
  echo "        CFE/cfe : Cloud Failover Extension"
  echo "    <component_version> the version like a.b.c (with a b and c numbers only)"
  echo "    <output_file> absolute output file path in a pre-existing folder"
  exit 0
}

# Check if necessary input params are set
if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then
  print-help
fi

# Check of component has been set correctly
if ! [[ ${VALID_COMPONENTS} == *${1}* ]]; then
  echo "Wrong component value '${1}', valid value are [${VALID_COMPONENTS}]"
  print-help
fi

# Check if the version matches expected format
if ! [[ "${2}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then 
  echo "Wrong version value '${2}', valid format is a.b.c (a b c are numbers only)"
  print-help
fi

OUTPUT_FOLDER=$(dirname ${3})
OUTPUT_FILE=$(basename ${3})

# Check if the output folder exists 
if ! [[ -d ${OUTPUT_FOLDER} ]] ; then
  echo "Output folder ${OUTPUT_FOLDER} does not exist on your filesystem"
  print-help
fi

# Check if the output folder is writable 
if ! [[ -w ${OUTPUT_FOLDER} ]] ; then
  echo "Output folder ${OUTPUT_FOLDER} is not writable on your filesystem"
  print-help
fi

# Check if the output file is valid 
if [[ -z ${OUTPUT_FILE} ]] ; then
  echo "Output file ${OUTPUT_FILE} is not valid"
  print-help
fi

# Compose the download URL
case ${1} in 
  DO | do)
    URL="${DO_BASE}${2}" ;;
  AS3 | as3)
    URL="${AS3_BASE}${2}" ;;
  TS | ts)
    URL="${TS_BASE}${2}" ;;
  CFE | cfe)
    URL="${CFE_BASE}${2}" ;;
  *)
    print-help ;;
esac

# Do the release fetching information in a loop
while [[ -z ${RPM_URL} ]] ; do
  echo "Curl Github API on ${URL} for ${1} release information"
  RPM_URL=$(curl -s ${URL} | grep -oh "https.*noarch.rpm" | head -1)
  sleep 1
done

# Do the rpm download in a loop
while ! [[ -f ${3} ]] ; do
  echo "Downloading ${1} RPM file from Github into ${3}"
  curl -s -L -o ${3} ${RPM_URL}
  sleep 1
done

# Print the final results
echo "Downloaded ${1} Github release : ${RPM_URL}"
echo "Resulting ${1} RPM file stored : ${3}"