json.array!  @buildings do |b|
  json.building_id b.id
  json.company_name b.company_name
  json.building_name b.name
end

json.array!  @apartments do |a|
  json.apartment_company_name a.company_name
  json.apartment_building_name a.building_name
  json.apartment_apartment_name a.name
  json.apartment_apartment_id a.id
end
