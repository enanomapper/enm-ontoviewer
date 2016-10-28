require 'json'
require 'rest-client'
require 'rdiscount'
require_relative "./service.rb"

configure :development do
  $logger = Logger.new(STDOUT)
end

before do
  @version = File.read("VERSION").chomp
  @accepted_select = [
    "text/plain",
    "text/csv",
    "text/html",
    "text/n3",
    "text/turtle",
    "text/tab-separated-values",
    "application/json",
    "application/rdf+xml",
    "application/sparql-results+xml",
    "application/sparql-results+json",
    "application/vnd.ms-excel"
  ]
  @accepted_construct = [
    "text/rdf+n3",
    "text/rdf+ttl",
    "text/rdf+turtle",
    "text/turtle",
    "text/n3",
    "application/turtle",
    "application/x-turtle",
    "text/ntriples",
    "application/rdf+xml",
    "text/csv",
    "application/odata+json",
    "application/microdata+json",
    "application/rdf+json",
    "application/ld+json"
  ]
  @examples = [
    ["example1", "Particle Size (Distribution)"],
    ["example2", "All ENMs have at least one chemical component"],
    ["example3", "Surface charge"]
  ]
end

get '/?' do
  redirect to('/enm-viewer') 
end

get '/enm-viewer/?' do
  haml :query
end

# visualization route
# while xhr response gets 'null' for js function this needs an extra handling without response code
get '/search/:query?' do
  sparqlstring = params["query"]
  halt 400, "Not allowed SPARQL keyword.\n" if !!(sparqlstring =~ /\b(delete|insert|load|clear)\b/i)
  response = RestClient::Resource.new(URI.encode("#{$service_uri}/sparql/?query=#{sparqlstring}"), :verify_ssl => 0, :headers => {:accept => "application/sparql-results+json"}).get do |response, request, result|
    if response.code == 400
      return "malformed query"
    elsif response.code > 400
      return "error processing query or fetching data"
    else
      return response.body
    end
  end
end

# sparql endpoint access
#get '/sparql/:query?' do
get '/sparql/?' do
  halt 400, "Missing query parameter.\n" unless params[:query]
  halt 400, "Missing query parameter.\n" if params[:query].empty?
  sparqlstring = params[:query]
  halt 400, "Not allowed SPARQL keyword.\n" if !!(sparqlstring =~ /\b(delete|insert|load|clear)\b/i)
  type = request.env["HTTP_ACCEPT"]
  
  #if (sparqlstring =~ /^select/i ? @accepted_select.include?(type) : @accepted_construct.include?(type) )
  if ( @accepted_select.include?(type) || @accepted_construct.include?(type) )
    RestClient::Resource.new(URI.encode("#{$service_uri}/sparql/?query=#{sparqlstring}"), :verify_ssl => 0, :headers => {:accept => type } ).get do |response,request,result|
      if response.code == 400
        halt response.code, "malformed query\n"
      elsif response.code > 400
        halt response.code "error processing query or fetching data\n"
      else
        response+"\n"
      end
    end
  else
    halt 400, "#{type} is not supported content type.\n"
  end
end

# sparql result as file download in various formats
get "/download" do
  type = params[:queryType]
  sparqlstring = params[:queryField]
  halt 400, "Not allowed SPARQL keyword.\n" if !!(sparqlstring =~ /\b(delete|insert|load|clear)\b/i)
  file = Tempfile.new("enm")
  #TODO check for SELECT keyword else return a message instead wrong type
  if ( @accepted_select.include?(type) || @accepted_construct.include?(type) )
    RestClient::Resource.new(URI.encode("#{$service_uri}/sparql/?query=#{sparqlstring}"), :verify_ssl => 0, :headers => {:accept => type}).get do |response, request, result|
      if response.code == 400
        halt response.code, "malformed query\n"
      elsif response.code > 400
        halt response.code, "error processing query or fetching data\n"
      elsif response.code == 200
        file.write(response)
        file.rewind
        if params[:renderType]
          send_file(file, :disposition => params[:renderType], :filename => File.basename(file), :type => type)
        else
          return response
        end
      end
      file.close
      file.unlink
    end
  else
    return "#{type} is not supported content type.\n"
  end
end

get '/license' do
  haml :license
end
