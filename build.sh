#!/usr/bin/env bash
#
# NAME
#   build.sh -- create json and zip Sources
# USAGE
#   build.sh 
# DESCRIPTION
#   hs required
#   jq required
root_dir=$(cd "$(dirname "${0}")"; pwd -P)
source_dir="${root_dir}/Source"
cd $source_dir

# 1. build jsons and aggregate them
# 2. zip sources into Spoons
json=""
for source in $(ls -d */ | perl -pe 's|/$||g' | xargs echo); do
    d=${source_dir}/${source}
    json="${json} $(hs -c "hs.doc.builder.genJSON('${d}')" | grep -v "^--" | tee ${d}/docs.json)"

    (
        zip -r ../Spoons/${source}.zip ./${source}
    )
done
echo $json | /usr/local/bin/jq --sort-keys --slurp . > "${root_dir}/docs/docs.json"