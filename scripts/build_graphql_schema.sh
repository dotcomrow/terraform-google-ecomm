#!/bin/sh
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node

cd scripts
npm install


curl https://sdk.cloud.google.com > install.sh
bash install.sh --disable-prompts --install-dir=./$dirstring >/dev/null 
PATH=$PATH:./$dirstring/google-cloud-sdk/bin
printf '%s' "$GOOGLE_CREDENTIALS" > key.json
gcloud auth activate-service-account --key-file=key.json

node schema_builder.sh

SHA="test"

cat <<EOF
{
  "sha": "$SHA"
}
EOF