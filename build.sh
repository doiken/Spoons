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
    out=$(hs -c "hs.doc.builder.genJSON('${d}')" | grep -v "^--" | /usr/local/bin/jq --sort-keys)
    if [ $(echo "$out" | md5) != "$(md5 -q ${d}/docs.json)" ]; then
        echo $out > ${d}/docs.json
    fi
    json="${json} ${out}"

    (
        zip -Xr ../Spoons/${source}.zip ./${source}
    )
done
echo $json | /usr/local/bin/jq --sort-keys --slurp . > "${root_dir}/docs/docs.json"