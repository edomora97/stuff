class Tag < ActiveRecord::Base
    has_many :episodes, through: :assignments
    has_many :assignments
end
