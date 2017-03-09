require "spec"
TEST = true
require "../app"

require "./model/associations/belongs_to/plain_spec"
require "./model/associations/belongs_to/polymorphic_spec"

require "./model/associations/has_many/as_polymorphic_spec"
require "./model/associations/has_many/plain_spec"
require "./model/associations/has_many/through_spec"

require "./model/associations/has_one/as_polymorphic_spec"
require "./model/associations/has_one/plain_spec"
require "./model/associations/has_one/through_spec"

require "./model/n_repo_spec"

require "./model/repository/**"
