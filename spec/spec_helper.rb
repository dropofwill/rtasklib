# Copyright (c) 2015 Will Paul (whp3652@rit.edu)
# All rights reserved.
#
# This file is distributed under the MIT license. See LICENSE.txt for details.

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'coveralls'

Coveralls.wear!
require 'rtasklib'
