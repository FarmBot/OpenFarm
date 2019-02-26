# If you don't do this, serializing models to JSON will give you goofy primary
# keys that look like this: {"_id":{"$oid":"53702cfc5269632ff6000000"}} which is
# just odd. Man, I wish this was just a Mongoid config.
# More info: http://stackoverflow.com/a/20813109/1064917
module BSON
  class ObjectId
    def to_json(*)
      to_s.to_json
    end

    def as_json(*)
      to_s.as_json
    end
  end
end

# https://github.com/mongoid/mongoid-history/issues/169
Mongoid.belongs_to_required_by_default = false
Mongoid::History.tracker_class_name = :history
