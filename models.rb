require 'bundler/setup'
Bundler.require
if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  validates :name,
    presence: true,
    format: { with: /\A\w+\z/ }
  validates :password,
   presence: true,
    length: { in: 5..10 }
  has_many :scripts
end

class Script < ActiveRecord::Base
  validates :title,
    presence: true,
    format: { with: /\A\w+\z/ }
  validates :description,
    presence: true
  validates :keyword,
    presence: true,
    length: { in: 5..10 }
  validates :slides_url,
    presence: true
  belongs_to :user
  has_many :contributors
  has_many :lines
end

class Contributor < ActiveRecord::Base
  belongs_to :script
  has_many :lines
end

class Line < ActiveRecord::Base
  belongs_to :contributor
  belongs_to :script
end
