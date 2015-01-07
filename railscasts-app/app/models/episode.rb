class Episode < ActiveRecord::Base
    scope :pro, -> { where(pro: true) }
    scope :revised, -> { where(revised: true) }
    scope :free, -> { where(pro: false) }

    has_many :tags, through: :assignments
    has_many :assignments

    def self.text_search query
        rank = "ts_rank(to_tsvector(name), plainto_tsquery(#{sanitize(query)}))"
        where("to_tsvector('english', name) @@ :q OR to_tsvector('english', description) @@ :q", q: query).
            order("#{rank} desc")
    end
end
