#! /usr/bin/env ruby

require 'rally_api'
require 'pp'
require 'date'

# @config[:workspace]  = "Hellfish DemoData Only"
# @config[:project]    = "AlanDemoData"

@config = {:base_url => "https://.testn.f4tech.com/slm"}
@config[:username]   = ""
@config[:password]   = ""
@config[:workspace]  = ""
@config[:project]    = "Proof"

def show_some_values(title, builddef)
  values = ["Name", "Description", "Project", "CreationDate"]
  format = "%-12s : %s"

  puts "-" * 80
  puts title
  values.each do |field_name|
    puts format % [field_name, builddef[field_name]]
  end
end

def find_build_def()
  query = RallyAPI::RallyQuery.new()
  query.type = "builddefinition"
  query.fetch = "Name,CreationDate,Description,Project"
  query.limit      = 10 
  query.page_size  = 10
  query.project_scope_up = false
  query.project_scope_down = false
  query.order = "CreationDate Desc"
  query.query_string = "(Name = \"Tally Builds\")"
  bd = ""

  results = @rally_api.find(query)
  builddef = results[0]
  builddef.read

  #results.each do |builddef|
  #  bd = builddef["_ref"]
  #  builddef.read
  # end

  builddef

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
  for i in 9..26 do
     
    fields = {}
    fields["BuildDefinition"] = builddef["_ref"]
    fields["Duration"] = i * 0.5
    fields["Start"] = DateTime.new(2022, 5, i-2, 4, 10, 9).iso8601
    if i % 3 == 1
      fields["Status"] = "SUCCESS"
    elsif i % 3 == 2
      fields["Status"] = "FAILURE"
    else
      fields["Status"] = "UNKNOWN"
    end
    
    new_build = @rally_api.create("build", fields)
    puts new_build["_ref"] + " ... " + new_build["BuildDefinition"]._ref     
  end
end

begin
  @rally_api = RallyAPI::RallyRestJson.new(@config)
  @workspace = @rally_api.find_workspace(@config[:workspace])
  @project   = @rally_api.find_project(@workspace, @config[:project])
  puts @workspace._ref
  puts @project._ref

  #builddef = create_build_defs
  builddef = find_build_def

  create_builds(builddef)

  puts "-------------------------------"
  builddef.Builds.each do |build|
    puts build._ref
    puts build.Status
  end

rescue Exception => boom
  puts "Rescued #{boom.class}"
  puts "Error Message: #{boom}"
end
