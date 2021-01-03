json.array!  @buildings do |b|
  json.building_id b.id
  json.company_name b.company_name
  json.building_name b.name
end

json.array!  @tenants do |t|
  json.tenant_building_name t.building_name
  json.tenant_company_name t.company_name
  json.tenant_id t.id
  json.name t.name
  json.rent t.rent
  json.service_charge t.service_charge
end
