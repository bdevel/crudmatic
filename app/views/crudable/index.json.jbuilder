
#json.set! controller.model_class.name.underscore.pluralize, @records.as_json


json.links do|l|
  env = request.env
  l.self env["REQUEST_URI"]
  if next_path = (path_to_next_page(@records) rescue nil)
    l.next "#{env["rack.url_scheme"]}://#{env["HTTP_HOST"]}" + next_path
  end
end

# TODO: this wont really work for includes... or somehow need to pull out all the includes
json.data(@records.map do |r|
            record_as_json(r)
          end)



