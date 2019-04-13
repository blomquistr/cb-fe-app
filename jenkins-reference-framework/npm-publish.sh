#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
curDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    cat <<END
	npm-publish [-h] job_url branch_name build_name build_number artifactory_usr artifcatory_psw

	bumps npm version by patch
	tags the artifact
	publish to artifactory (jfrog)
	push version change to github with tag and link to job in commit message

	e.g. ./npm-publish 'http://jenkins-templates.test.run/job/Merrill%20Corporation/job/angular2-seed/job/develop/' "develop" "Merrill Corporation/angular2-seed-jm/jenkins-migration" "1234" "awesome-username" "awesome-psw"

	Possible failures:
	git tag exists. solution: git tag -d {tag_name}
	artifactory connection failure. solution: validate .npmrc exists and is correct
	artifact version exists. solution: delete existing artifact in jfrog or bump version again
END
}

while getopts ":h" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
    esac
done

[[ ! $1 ]] && echo "Missing first argument for job_url" >&2 && exit 1
[[ ! $2 ]] && echo "Missing first argument for branch_name" >&2 && exit 1
[[ ! $3 ]] && echo "Missing first argument for build_name" >&2 && exit 1
[[ ! $4 ]] && echo "Missing first argument for build_number" >&2 && exit 1
[[ ! $5 ]] && echo "Missing first argument for artifactory_repo" >&2 && exit 1
[[ ! $6 ]] && echo "Missing first argument for artifactory_usr" >&2 && exit 1
[[ ! $7 ]] && echo "Missing first argument for artifactory_psw" >&2 && exit 1
[[ ! $8 ]] && echo "Missing first argument for github_url" >&2 && exit 1

job_url="${1}"
branch_name="${2}"
build_name="${3}"
build_number="${4}"
artifactory_repo="${5}"
artifactory_usr="${6}"
artifactory_psw="${7}"
github_url="${8}"

cd "${curDir}/.."

git checkout -- .

echo ---- github testing ----
git remote -v
echo $github_url
echo ---- github testing ----

npm version patch -m "CICD-173: ${job_url}"
version=$(cat package.json | grep version | sed 's/.*: "\(.*\)",/\1/')

#jfrog cli
jfrog rt config merrillcorp --url=https://merrillcorp.jfrog.io/merrillcorp --user="${artifactory_usr}" --apikey="${artifactory_psw}"

jfrog rt build-add-git "${build_name}" "v${build_number}"
jfrog rt build-collect-env "${build_name}" "v${build_number}"
jfrog rt npm-publish ${artifactory_repo} --build-name="${build_name}" --build-number="v${build_number}"

jfrog rt build-publish "${build_name}" "v${build_number}" --build-url="${job_url}"
jfrog rt build-promote "${build_name}" "v${build_number}" ${artifactory_repo}

# testing github

git add .
git commit -m "CICD-173: ${job_url}"
git push $github_url #origin HEAD:"${branch_name}"
git push --force-with-lease origin $github_url # "+v${version}"
