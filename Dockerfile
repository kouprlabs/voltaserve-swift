# Copyright (c) 2024 Anass Bouassaba.
#
# This software is licensed under the MIT License.
# You can find a copy of the license in the LICENSE file
# included in the root of this repository or at
# https://opensource.org/licenses/MIT.

FROM swift:5.10

WORKDIR /app

COPY . .

CMD ["swift", "test"]