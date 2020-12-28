#   Copyright IBM Corporation 2020
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

FROM registry.access.redhat.com/ubi8-minimal as build_base

# allows microdnf to install yarn
RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
RUN microdnf -y install yarn nodejs
COPY package.json /app/
COPY yarn.lock /app/
WORKDIR /app
RUN yarn
COPY . /app
RUN yarn build

FROM registry.access.redhat.com/ubi8-minimal

# reads from environment variable first, otherwise fall back to move2kubeapi value
ARG MOVE2KUBEAPI
ENV MOVE2KUBEAPI=${MOVE2KUBEAPI:-http://move2kubeapi:8080}

RUN microdnf -y install nodejs && microdnf clean all
WORKDIR /app
COPY --from=build_base /app /app

CMD ["npm","start"]
EXPOSE 8080
