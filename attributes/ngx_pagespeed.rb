#
# Cookbook Name:: nginx
# Attributes:: ngx_pagespeed
#
# Author:: Joseph Passavanti (<gottaloveit@gmail.com>)
#
# Copyright 2014, Joseph Passavanti
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['nginx']['ngx_pagespeed']['version']         = '1.8.31.2-beta'

# PSOL binary version, should be the same as above version, without the '-beta'
default['nginx']['ngx_pagespeed']['psol_version']    = '1.8.31.2'

default['nginx']['ngx_pagespeed']['conf_enable'] = true
default['nginx']['ngx_pagespeed']['conf_filecachepath'] = '/var/ngx_pagespeed_cache'
default['nginx']['ngx_pagespeed']['conf_tmpfs_filecachepath'] = true

# not used if above is false
# system must have enough available memory for this tmpfs partition
# use mount options for size:  512k 1m 1024m 1g etc.
default['nginx']['ngx_pagespeed']['conf_tmpfs_filecachepath_size'] = '512m'

# add any ip ranges to allowed list for accessing pagespeed console, admin, stats
# 127.0.0.1 is always included
default['nginx']['ngx_pagespeed']'allow_ips'] = []
