#!/bin/bash
#
# Helper script that downloads ATC RPM components.
#

DO_BASE="https://api.github.com/repos/F5Networks/f5-declarative-onboarding/releases/"
AS3_BASE="https://api.github.com/repos/F5Networks/f5-appsvcs-extension/releases/"
TS_BASE="https://api.github.com/repos/F5Networks/f5-telemetry-streaming/releases/"
CFE_BASE="https://api.github.com/repos/F5Networks/f5-cloud-failover-extension/releases/"

VALID_COMPONENTS="do DO as3 AS3 ts TS cfe CFE"

function printhelp {
  echo "Usage: download_atc_rpm.sh <atc_component> <component_version> <output_file>"
  echo "    <atc_component> should be one of the following:"
  echo "        DO/do   : Declarative Onboarding"
  echo "        AS3/as3 : Application Services 3"
  echo "        TS/ts   : Telemetry Streaming"
  echo "        CFE/cfe : Cloud Failover Extension"
  echo "    <component_version> the version like a.b.c (with a b and c numbers only) or 'latest'"
  echo "    <output_file> absolute output file path in a pre-existing folder (eg. /fullpath/filename.rpm)"
  echo "Return values:"
  echo "    0 : succesfull"
  echo "    1 : missing or invalid arguments"
  echo "    2 : <component_version> does not exist"
  exit 1
}

# Check if necessary input params are set
if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then
  printhelp
else
  # Increase readability of the rest of the script
  ATC_COMPONENT=${1}
  COMPONENT_VERSION=${2}
  OUTPUT_FULLPATH_FILE=${3}
fi

# Check of component has been set correctly
if ! [[ ${VALID_COMPONENTS} == *${ATC_COMPONENT}* ]]; then
  echo "Wrong component value '${ATC_COMPONENT}', valid value are [${VALID_COMPONENTS}]"
  printhelp
fi

# Check if the version matches expected format
if ! [[ "${COMPONENT_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ || "${COMPONENT_VERSION}" == "latest" ]]; then
  echo "Wrong version value '${COMPONENT_VERSION}', valid format is a.b.c (a b c are numbers only) or 'latest'"
  printhelp
fi

# Split the absolute output file path in filename and folderpath
OUTPUT_FOLDER=$(dirname ${OUTPUT_FULLPATH_FILE})
OUTPUT_FILE=$(basename ${OUTPUT_FULLPATH_FILE})

# Check if the output folder exists 
if ! [[ -d ${OUTPUT_FOLDER} ]] ; then
  echo "Output folder ${OUTPUT_FOLDER} does not exist on your filesystem"
  printhelp
fi

# Check if the output folder is writable 
if ! [[ -w ${OUTPUT_FOLDER} ]] ; then
  echo "Output folder ${OUTPUT_FOLDER} is not writable on your filesystem"
  printhelp
fi

# Check if the output file is valid 
if [[ -z ${OUTPUT_FILE} ]] ; then
  echo "Output file ${OUTPUT_FILE} is not valid"
  printhelp
fi

# Check if the output file is not already an existing directory
if [[ -d ${OUTPUT_FULLPATH_FILE} ]] ; then
  echo "Output file ${OUTPUT_FILE} is an existing directory"
  printhelp
fi

# Latest version is available on a different REST URL then other versions
if [ "${COMPONENT_VERSION}" = "latest" ] ; then
  VERSION_PREPEND=""
else
  VERSION_PREPEND="tags/v"
fi
 
# Compose the download URL
case ${ATC_COMPONENT} in
  DO | do)
    RELEASE_INFO_URL="${DO_BASE}${VERSION_PREPEND}${COMPONENT_VERSION}" ;;
  AS3 | as3)
    RELEASE_INFO_URL="${AS3_BASE}${VERSION_PREPEND}${COMPONENT_VERSION}" ;;
  TS | ts)
    RELEASE_INFO_URL="${TS_BASE}${VERSION_PREPEND}${COMPONENT_VERSION}" ;;
  CFE | cfe)
    RELEASE_INFO_URL="${CFE_BASE}${VERSION_PREPEND}${COMPONENT_VERSION}" ;;
  *)
    printhelp ;;
esac

# Resetting variables to empty string when multiple calls are made
# to this script within another script (eg cloud-init)
RPM_URL=""
NOT_FOUND=""
FOUND=""

# Verify if the requested release is actually available
while [[ -z ${FOUND} && -z ${NOT_FOUND} ]] ; do
  echo "Curl Github API on ${RELEASE_INFO_URL} for ${ATC_COMPONENT} release information"
  FOUND=$(curl -s ${RELEASE_INFO_URL} | grep "created_at" | head -1)
  NOT_FOUND=$(curl -s ${RELEASE_INFO_URL} | grep "Not Found" | head -1)
  sleep 1
done

# Fail with exit status 2 if release not found
if [[ -n ${NOT_FOUND} ]] ; then
  echo "Version ${COMPONENT_VERSION} of component ${ATC_COMPONENT} does not exist"
  exit 2
fi

# Do the release fetching information in a loop
while [[ -z ${RPM_URL} ]] ; do
  echo "Curl Github API on ${RELEASE_INFO_URL} for ${ATC_COMPONENT} release information"
  RPM_URL=$(curl -s ${RELEASE_INFO_URL} | grep -oh "https.*noarch.rpm" | head -1)
  sleep 1
done

# Do the rpm download in a loop
while ! [[ -f ${OUTPUT_FULLPATH_FILE} ]] ; do # This creates a bug if the file exists in wich curl wont overwrite
  echo "Downloading ${ATC_COMPONENT} RPM file from Github into ${OUTPUT_FULLPATH_FILE}"
  curl -s -L ${RPM_URL} > ${OUTPUT_FULLPATH_FILE}
  sleep 1
done

# Print the final results
echo "Downloaded ${ATC_COMPONENT} Github release : ${RPM_URL}"
echo "Resulting ${ATC_COMPONENT} RPM file stored : ${OUTPUT_FULLPATH_FILE}"
exit 0
