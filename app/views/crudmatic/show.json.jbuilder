
# TODO: this wont really work for includes... or somehow need to pull out all the includes
json.data([@record].map do |r|
            record_as_json(r)
end)

