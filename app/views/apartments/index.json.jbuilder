json.array!  @buildings do |b|
  json.building_id b.id
  json.company_name b.company_name
  json.building_name b.name
end
