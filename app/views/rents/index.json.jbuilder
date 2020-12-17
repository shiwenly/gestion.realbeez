json.array!  @tenants do |t|
  json.name t.name
  json.rent t.rent
  json.service_charge t.service_charge
end
