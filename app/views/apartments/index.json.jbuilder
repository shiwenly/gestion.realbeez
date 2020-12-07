json.array!  @buildings do |b|
  json.building b
  json.name b.name
  json.company b.company_name
end
