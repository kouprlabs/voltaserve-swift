# Copyright (c) 2024 Anass Bouassaba.
#
# This software is licensed under the MIT License.
# See the LICENSE file in the root of this repository for details,
# or visit <https://opensource.org/licenses/MIT>.

FROM swift:5.10

WORKDIR /app

COPY . .

CMD ["swift", "test"]