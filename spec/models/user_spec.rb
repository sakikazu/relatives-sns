# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  authentication_token   :string(255)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  deleted_at             :datetime
#  email                  :string(255)      default("")
#  encrypted_password     :string(255)      default(""), not null
#  familyname             :string(255)
#  generation             :integer
#  givenname              :string(255)
#  last_request_at        :datetime
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  password_salt          :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role                   :integer          default(2), not null
#  root11                 :integer
#  sign_in_count          :integer          default(0)
#  username               :string(255)      default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  parent_id              :integer
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

require 'spec_helper'

describe User do
  pending "add some examples to (or delete) #{__FILE__}"
end
