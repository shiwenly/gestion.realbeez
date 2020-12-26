json.array!  @buildings do |b|
  json.company_name b.company_name
  json.building_name b.name
end

# json.array!  @apartments do |a|
#   json.company_name a.company_name
#   json.building_name a.building_name
#   json.apartment_name a.name
# end
