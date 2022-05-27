#! /usr/bin/env ruby

require 'rally_api'
require 'pp'
require 'date'

# @config[:workspace]  = "Hellfish DemoData Only"
# @config[:project]    = "AlanDemoData"

@config = {:base_url => "https://abrockett.testn.f4tech.com/slm"}
@config[:username]   = "abrockett@rallydev.com"
@config[:password]   = "Password"
@config[:workspace]  = "Rally"
@config[:project]    = "Tally"

def show_some_values(title, builddef)
  values = ["Name", "Description", "Project", "CreationDate"]
  format = "%-12s : %s"

  puts "-" * 80
  puts title
  values.each do |field_name|
    puts format % [field_name, builddef[field_name]]
  end
end

def find_build_defs()
  query = RallyAPI::RallyQuery.new()
  query.type = "builddefinition"
  query.fetch = "Name,CreationDate,Description,Project"
  query.limit      = 10 
  query.page_size  = 10
  query.project_scope_up = false
  query.project_scope_down = false
  query.order = "CreationDate Desc"
  query.query_string = "(Name = \"Tally Builds\")"

  results = @rally_api.find(query)
  results.each do |result|
    puts result["_ref"]
  end
end

def create_build_defs
  fields = {}
  fields["Name"] = "Tally Builds"
  fields["Description"] = "Builds for Tally"
  fields["Project"] = @project

  new_builddef = @rally_api.create("builddefinition", fields)
  show_some_values("Created new build definition", new_builddef)

  return new_builddef
end

def create_builds(builddef)
  fields = {}
  fields["BuildDefinition"] = builddef["_ref"]
  fields["Duration"] = 1.5
  fields["Start"] = DateTime.new(2019, 8, 10, 4, 10, 9).iso8601
  fields["Status"] = "SUCCESS"

  new_build = @rally_api.create("build", fields)
  puts new_build["_ref"] + " ... " + new_build["BuildDefinition"]._ref
end

begin
  @rally_api = RallyAPI::RallyRestJson.new(@config)
  @workspace = @rally_api.find_workspace(@config[:workspace])
  @project   = @rally_api.find_project(@workspace, @config[:project])
  #puts @workspace._ref
  #puts @project._ref

  builddef = create_build_defs
  create_builds(builddef)
  find_build_defs

rescue Exception => boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end
